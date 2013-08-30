/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "SimpleSpace.h"
#import "CCNode+LnAdditions.h"
#import "NSCache+LnAdditions.h"
#import "CompositeMask.h"
#import "Contact.h"
#import "ContactListener.h"
#import "BodilyMask.h"

@interface SimpleSpace ()
@property(nonatomic) ccTime elapsed;
@end

@implementation SimpleSpace {

}
@synthesize gravity = _gravity;

- (id)init {
    return [self initWithGravity:DEFAULT_GRAVITY step:DEFAULT_STEP];
}

- (id)initWithGravity:(CGPoint)gravity step:(ccTime)step {
    self = [super init];
    if (self) {
        self.gravity = gravity;
        self.step = step;
    }

    return self;
}

+ (id)spaceWithGravity:(CGPoint)gravity step:(ccTime)step {
    return [[self alloc] initWithGravity:gravity step:step];
}

- (Class)bodyClass {
    return [SimpleBody class];
}

- (void)activate {
    [super activate];
    [self scheduleUpdate];
}

- (void)deactivate {
    [super deactivate];
    [self unscheduleUpdate];
}

- (SimpleBody *)sortLineageHeadOfNode:(CCNode *)n usingLineageHeadBodyDictionary:(NSMutableDictionary *)cache lineageBodySet:(NSMutableSet *)set {
    if (!n)
        return nil;
    NSValue *value = [NSValue valueWithPointer:(__bridge void *) n];
    id r = cache[value];
    if (!r) {
        // set the result
        r = [self sortLineageHeadOfNode:n.parent usingLineageHeadBodyDictionary:cache lineageBodySet:set];
        if (!r && [self.allBodies containsObject:n.body])
            r = n.body;
        // we should accumulate the result in the lineage set
        [set addObject:r];
        cache[value] = r ? r : [NSNull null];
    }
    return r == [NSNull null] ? nil : r;
}

- (void)update:(ccTime)step {
    self.elapsed += step;
    if (self.elapsed > self.step) {
        // we should set a tick rate to avoid computing collisions, etc. too excessively
        self.elapsed = 0;
        // for each dynamic body we should first compute the set that it should be checked against
        // have a dictionary to record the position changes that should take place
        // for each body
        NSSet *activeDynamicBodies = [self.allBodies filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d && activated == YES", BodyTypeDynamic]];
        if (activeDynamicBodies.count) {
            NSMutableDictionary *lineageHeadBodies = [NSMutableDictionary dictionary];
            NSMutableSet *lineageBodies = [NSMutableSet set];
            NSMutableSet *collisionBodiesSet;
            NSMutableDictionary *positionChangesTable = [NSMutableDictionary dictionary];
            NSMutableDictionary *collidedBodiesTable = [NSMutableDictionary dictionary];
            for (SimpleBody *b in self.allBodies)
                [self sortLineageHeadOfNode:b.host usingLineageHeadBodyDictionary:lineageHeadBodies lineageBodySet:lineageBodies];


            for (SimpleBody *b in activeDynamicBodies) {
                // first retrieve the head it corresponds to
                collisionBodiesSet = lineageBodies.mutableCopy;
                [collisionBodiesSet removeObject:lineageHeadBodies[[NSValue valueWithPointer:(__bridge void *) b.host]]];

                // the displacement of body
                CGPoint worldv = b.spaceVelocity;
                CGPoint ds = ccpMult(worldv, step);
                CGPoint ds_direction = ccpDirection(ds);
                CGPoint ds_mag = ccpMagnitude(ds);

                CGPoint collideVec = ccp(0, 0);
                // save the old position
                CGPoint oldPos = b.spacePosition;

                NSMutableSet *collidedBodies = [NSMutableSet set];
                SimpleBody *collidedBody;

                // first adjust the x direction
                b.spacePosition = ccpAdd(oldPos, ccp(ds.x, 0));
                while ((collidedBody = [self body:b intersectsWithBodiesInSet:collisionBodiesSet]) && ds_mag.x > 0) {
                    [collidedBodies addObject:collidedBody];
                    collideVec.x = 1;
                    b.spacePosition = ccpAdd(b.spacePosition, ccp(-ds_direction.x * b.restitution, 0));
                    ds_mag.x -= b.restitution;
                }
                // then adjust the y direction
                b.spacePosition = ccpAdd(b.spacePosition, ccp(0, ds.y));
                while ((collidedBody = [self body:b intersectsWithBodiesInSet:collisionBodiesSet]) && ds_mag.y > 0) {
                    [collidedBodies addObject:collidedBody];
                    collideVec.y = 1;
                    b.spacePosition = ccpAdd(b.spacePosition, ccp(0, -ds_direction.y * b.restitution));
                    ds_mag.y -= b.restitution;
                }
                // we can modify the world velocity because we can be quite sure that
                // velocity only takes effect after next update
                b.spaceVelocity = ccp(worldv.x * !collideVec.x, worldv.y * !collideVec.y);

                // save the positional changes in the dictionary and restore the old position
                NSValue *value = [NSValue valueWithPointer:(__bridge void *) b];
                positionChangesTable[value] = [NSValue valueWithCGPoint:b.spacePosition];
                b.spacePosition = oldPos;

                // save the collision contact set
                collidedBodiesTable[value] = collidedBodies;

                // we reset the world acceleration to be the gravity
                b.spaceAcceleration = self.gravity;
            }

            // loop through all the dynamic bodies and apply the changes
            for (SimpleBody *b in activeDynamicBodies) {
                NSValue *value = [NSValue valueWithPointer:(__bridge void *) b];
                b.spacePosition = [positionChangesTable[value] CGPointValue];
                for (SimpleBody *o in collidedBodiesTable[value])
                    [b.contactListener beginContact:[Contact contactWithBody:b otherBody:o]];
            }
        }
    }
}

// A little bit like the compositemask; difference is that it returns the specific instance
// that causes the collision
- (SimpleBody *)body:(SimpleBody *)b intersectsWithBodiesInSet:(NSSet *)set {
    for (SimpleBody *body in set) {
        if ([body.mask intersects:b.mask])
            return body;
    }
    return nil;
}

@end