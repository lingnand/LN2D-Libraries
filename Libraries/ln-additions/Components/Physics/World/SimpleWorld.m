/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "SimpleWorld.h"
#import "CCNode+LnAdditions.h"
#import "NSCache+LnAdditions.h"
#import "CompositeMask.h"
#import "Contact.h"
#import "ContactListener.h"

@interface SimpleWorld ()
@property(nonatomic) ccTime elapsed;
@end

@implementation SimpleWorld {

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

+ (id)worldWithGravity:(CGPoint)gravity step:(ccTime)step {
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

- (CCNode *)sortLineageHeadOfNode:(CCNode *)n usingHeadDictionary:(NSMutableDictionary *)cache lineageSet:(NSMutableSet *)set {
    if (!n)
        return nil;
    NSValue *value = [NSValue valueWithPointer:(__bridge void *) n];
    id r = cache[value];
    if (!r) {
        // set the result
        r = [self sortLineageHeadOfNode:n.parent usingHeadDictionary:cache lineageSet:set];
        if (!r && [self.allBodies containsObject:n.body])
            r = n;
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
            NSMutableDictionary *lineageHeads = [NSMutableDictionary dictionary];
            NSMutableSet *lineages = [NSMutableSet set];
            NSMutableSet *collisionSet;
            NSMutableDictionary *positionChanges = [NSMutableDictionary dictionary];
            NSMutableDictionary *collideContacts = [NSMutableDictionary dictionary];
            for (SimpleBody *b in self.allBodies)
                [self sortLineageHeadOfNode:b.host usingHeadDictionary:lineageHeads lineageSet:lineages];

            for (SimpleBody *b in activeDynamicBodies) {
                // first retrieve the head it corresponds to
                collisionSet = lineages.mutableCopy;
                [collisionSet removeObject:lineageHeads[[NSValue valueWithPointer:(__bridge void *) b.host]]];

                // the displacement of body
                CGPoint worldv = b.worldVelocity;
                CGPoint ds = ccpMult(worldv, step);
                CGPoint ds_direction = ccpDirection(ds);
                CGPoint ds_mag = ccpMagnitude(ds);

                CGPoint collideVec = ccp(0, 0);
                // save the old position
                CGPoint oldPos = b.worldPosition;

                NSMutableSet *collideContact = [NSMutableSet set];
                CCNode *collidedNode;

                // first adjust the x direction
                b.worldPosition = ccpAdd(oldPos, ccp(ds.x, 0));
                while ((collidedNode = [self node:b.host intersectsWithNodesInSet:collisionSet]) && ds_mag.x > 0) {
                    [collideContact addObject:[Contact contactWithBody:b otherBody:collidedNode.body]];
                    collideVec.x = 1;
                    b.worldPosition = ccpAdd(b.worldPosition, ccp(-ds_direction.x * b.restitution, 0));
                    ds_mag.x -= b.restitution;
                }
                // then adjust the y direction
                b.worldPosition = ccpAdd(b.worldPosition, ccp(0, ds.y));
                while ((collidedNode = [self node:b.host intersectsWithNodesInSet:collisionSet]) && ds_mag.y > 0) {
                    [collideContact addObject:[Contact contactWithBody:b otherBody:collidedNode.body]];
                    collideVec.y = 1;
                    b.worldPosition = ccpAdd(b.worldPosition, ccp(0, -ds_direction.y * b.restitution));
                    ds_mag.y -= b.restitution;
                }
                // we can modify the world velocity because we can be quite sure that
                // velocity only takes effect after next update
                b.worldVelocity = ccp(worldv.x * !collideVec.x, worldv.y * !collideVec.y);

                // save the positional changes in the dictionary and restore the old position
                NSValue *value = [NSValue valueWithPointer:(__bridge void *) b];
                positionChanges[value] = [NSValue valueWithCGPoint:b.worldPosition];
                b.worldPosition = oldPos;

                // save the collision contact set
                collideContacts[value] = collideContact;

                // we reset the world acceleration to be the gravity
                b.worldAcceleration = self.gravity;
            }

            // loop through all the dynamic bodies and apply the changes
            for (SimpleBody *b in activeDynamicBodies) {
                NSValue *value = [NSValue valueWithPointer:(__bridge void *) b];
                b.worldPosition = [positionChanges[value] CGPointValue];
                for (Contact *c in collideContacts[value]) {
                    [b.contactListener beginContact:c];
                }
            }
        }
    }
}

// A little bit like the compositemask; difference is that it returns the specific instance
// that causes the collision
- (CCNode *)node:(CCNode *)n intersectsWithNodesInSet:(NSSet *)set {
    for (CCNode *node in set) {
        if ([node.mask intersects:n])
            return node;
    }
    return nil;
}

@end