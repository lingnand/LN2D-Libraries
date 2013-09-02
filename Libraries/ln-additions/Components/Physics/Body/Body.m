/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "Body_protect.h"
#import "Space.h"
#include "NSObject+LnAdditions.h"
#import "CCNode+LnAdditions.h"
#import "TranslationalBody.h"

@implementation Body {
    Class _spaceClass;
}
@dynamic position, velocity, spacePosition, spaceVelocity;

+ (id)body {
    // give back a simpleBody instance if the user does not specify a
    // concrete implementing class; SimpleBody is like a default implementation
    // of Body anyway
    if (self.class == [Body class])
        return [TranslationalBody body];
    return [self component];
}

/** We explicitly return a nil instance if the user tries to init this abstract class */
- (id)init {
    if (self.class == [Body class])
        return nil;
    return [super init];
}

- (Class)spaceClass {
    if (!_spaceClass) {
        _spaceClass = [self classForPropertyNamed:@"space"];
    }
    return _spaceClass;
}

// absolute position / velocity etc
- (CGPoint)worldPosition {
    return CGPointApplyAffineTransform(self.spacePosition, self.space.host.nodeToWorldTransform);
}

- (void)setWorldPosition:(CGPoint)worldPosition {
    self.spacePosition = CGPointApplyAffineTransform(worldPosition, self.space.host.worldToNodeTransform);
}

// we should also add the velocity of the world
- (CGPoint)worldVelocity {
    // when the body is not wired to any world then the first argument will return 0; exactly what we are looking for
    return ccpAdd(self.space.host.body.worldVelocity, CGPointVectorApplyAffineTransform(self.spaceVelocity, self.space.host.nodeToWorldTransform));
}

- (void)setWorldVelocity:(CGPoint)worldVelocity {
    self.spaceVelocity = CGPointVectorApplyAffineTransform(ccpSub(worldVelocity, self.space.host.body.worldVelocity), self.space.host.worldToNodeTransform);
}

/** with respect to the real world */

- (CGAffineTransform)toSpaceTransformFromNode:(CCNode *)n {
    CGAffineTransform t = CGAffineTransformIdentity;

    for (CCNode *p = n; p && p != self.space.host; p = p.parent)
        t = CGAffineTransformConcat(t, p.nodeToParentTransform);

    return t;
}

/** return the transform from the local coordinates into the world coordinates
 * if there's no world indicated (or the world is not attached in the correct hierarchy
 * , the outermost world is chosen */
- (CGAffineTransform)hostParentToSpaceTransform {
    return [self toSpaceTransformFromNode:self.host.parent];
}

- (CGAffineTransform)spaceToHostParentTransform {
    return CGAffineTransformInvert(self.hostParentToSpaceTransform);
}

- (CGAffineTransform)hostToSpaceTransform {
    return [self toSpaceTransformFromNode:self.host];
}

- (CGAffineTransform)spaceToHostTransform {
    return CGAffineTransformInvert(self.hostToSpaceTransform);
}

// the contentSize box in the wired world
- (CGRect)hostContentBoxInSpace {
    return CGRectApplyAffineTransform((CGRect) {{0, 0}, self.host.contentSize}, self.hostToSpaceTransform);
}

// unionBox in the wired world
- (CGRect)hostUnionBoxInSpace {
    return CGRectApplyAffineTransform(self.host.unionBox, self.hostToSpaceTransform);
}

- (void)setSpace:(Space *)space {
    if (_space != space) {
        // just route the messages to the next level up
        [_space removeBody:self];
        [space addBody:self];
    }
}

- (void)setWorldDirect:(Space *)world {
    _space = world;
}

/** Search for a suitable world component in the tree upwards */
- (void)setClosestSpace {
    CCNode *p = self.host;
    if (!self.space && p) {
        Space *w = nil;
        while ((p = p.parent)) {
            if ((w = [p.rootComponent childForClass:self.spaceClass])) {
                if ([w addBody:self])
                    return;
            }
            // check if the parent has already wired with a space that's valid for this body as well
            Body *b = [p.rootComponent childForClass:[Body class]];
            if ([b.spaceClass isSubclassOfClass:self.spaceClass]) {
                if ([b.space addBody:self])
                    return;
            }
        }
    }
}


- (void)componentAdded {
    [super componentAdded];
    // we really need to add the body to the closest world to ensure consistency
    [self setClosestSpace];
}

- (id)copyWithZone:(NSZone *)zone {
    Body *copy = (Body *) [super copyWithZone:zone];

    if (copy != nil) {
        copy->_spaceClass = _spaceClass;
        // all other fields should be handled by the subclass
    }

    return copy;
}

@end