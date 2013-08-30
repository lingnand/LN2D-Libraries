/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "Body_protect.h"
#import "World.h"
#include "NSObject+LnAdditions.h"
#import "CCNode+LnAdditions.h"
#import "ContactListener.h"

@implementation Body {
    Class _worldClass;
}
@dynamic position,velocity,worldPosition,worldVelocity;

+ (id)body {
    // give back a simpleBody instance if the user does not specify a
    // concrete implementing class; SimpleBody is like a default implementation
    // of Body anyway
    if (self.class == [Body class])
        return [SimpleBody body];
    return [self component];
}

/** We explicitly return a nil instance if the user tries to init this abstract class */
- (id)init {
    if (self.class == [Body class])
        return nil;
    return [super init];
}

- (Class)worldClass {
    if (!_worldClass) {
        _worldClass = [self classForPropertyNamed:@"world"];
    }
    return _worldClass;
}

// absolute position / velocity etc
- (CGPoint)absolutePosition {
    return CGPointApplyAffineTransform(self.worldPosition, self.world.host.nodeToWorldTransform);
}

- (void)setAbsolutePosition:(CGPoint)absolutePosition {
    self.worldPosition = CGPointApplyAffineTransform(absolutePosition, self.world.host.worldToNodeTransform);
}

// we should also add the velocity of the world
- (CGPoint)absoluteVelocity {
    // when the body is not wired to any world then the first argument will return 0; exactly what we are looking for
    return ccpAdd(self.world.host.body.absoluteVelocity, CGPointVectorApplyAffineTransform(self.worldVelocity, self.world.host.nodeToWorldTransform));
}

- (void)setAbsoluteVelocity:(CGPoint)absoluteVelocity {
    self.worldVelocity = CGPointVectorApplyAffineTransform(ccpSub(absoluteVelocity, self.world.host.body.absoluteVelocity), self.world.host.worldToNodeTransform);
}

/** with respect to the real world */

- (CGAffineTransform)toWorldTransformFromNode:(CCNode *)n {
    CGAffineTransform t = CGAffineTransformIdentity;

    for (CCNode *p = n; p && p != self.world.host; p = p.parent)
        t = CGAffineTransformConcat(t, p.nodeToParentTransform);

    return t;
}

/** return the transform from the local coordinates into the world coordinates
 * if there's no world indicated (or the world is not attached in the correct hierarchy
 * , the outermost world is chosen */
- (CGAffineTransform)hostParentToWorldTransform {
    return [self toWorldTransformFromNode:self.host.parent];
}

- (CGAffineTransform)worldToHostParentTransform {
    return CGAffineTransformInvert(self.hostParentToWorldTransform);
}

- (CGAffineTransform)hostToWorldTransform {
    return [self toWorldTransformFromNode:self.host];
}

- (CGAffineTransform)worldToHostTransform {
    return CGAffineTransformInvert(self.hostToWorldTransform);
}

// the contentSize box in the wired world
- (CGRect)hostContentBoxInWorld {
    return CGRectApplyAffineTransform((CGRect){{0,0},self.host.contentSize}, self.hostToWorldTransform);
}

// unionBox in the wired world
- (CGRect)hostUnionBoxInWorld {
    return CGRectApplyAffineTransform(self.host.unionBox, self.hostToWorldTransform);
}

- (void)setWorld:(World *)world {
    if (_world != world) {
        // just route the messages to the next level up
        [_world removeBody:self];
        [world addBody:self];
    }
}

- (void)setWorldDirect:(World *)world {
    _world = world;
}

/** Search for a suitable world component in the tree upwards */
- (void)setClosestWorld {
    CCNode *p = self.host;
    if (!self.world && p) {
        World *w = nil;
        while ((p = p.parent)) {
            if ((w = [p.componentManager componentForClass:self.worldClass])) {
                if ([w addBody:self])
                    return;
            } else if ([p.body.worldClass isSubclassOfClass:self.worldClass]) {
                // we can ask for the body of the parent. Since it must have already checked
                // for the whole place then it should get the correct result
                // condition: the worldClass of this body must be kind of class of that of the parent's body
                if ([p.body.world addBody:self])
                    return;
            }
        }
    }
}

/** Contact Listener */
- (ContactListener *)contactListener {
    if (!_contactListener)
        // get the class of the contactListener
        _contactListener = [[self classForPropertyNamed:@"contactListener"] listener];

    return _contactListener;
}

- (void)onAddComponent {
    [super onAddComponent];
    // we really need to add the body to the closest world to ensure consistency
    [self setClosestWorld];
}

- (id)copyWithZone:(NSZone *)zone {
    Body *copy = (Body *) [super copyWithZone:zone];

    if (copy != nil) {
        copy->_worldClass = _worldClass;
        // all other fields should be handled by the subclass
    }

    return copy;
}

@end