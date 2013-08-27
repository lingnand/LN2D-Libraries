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

@implementation Body {
    Class _worldClass;
    BOOL _searchWorldAutomatically;
}

+ (id)body {
    return [self component];
}

- (Class)worldClass {
    if (!_worldClass) {
        _worldClass = [self classForPropertyNamed:@"world"];
    }
    return _worldClass;
}

- (World *)world {
    if (!_world && _searchWorldAutomatically) {
        [self setClosestWorld];
    }
    return _world;
}

/** with respect to immediate parent */
- (void)setPosition:(CGPoint)position {
    self.host.nodePosition = position;
}

- (CGPoint)position {
    return self.host.nodePosition;
}

/** with respect to the real world */

/** return the transform from the local coordinates into the world coordinates
 * if there's no world indicated (or the world is not attached in the correct hierarchy
 * , the outermost world is chosen */
- (CGAffineTransform)hostParentToWorldTransform {
    CGAffineTransform t = CGAffineTransformIdentity;

    for (CCNode *p = self.host.parent; p && p != self.world.host; p = p.parent)
        t = CGAffineTransformConcat(t, [p nodeToParentTransform]);

    return t;
}

- (CGAffineTransform)worldToHostParentTransform {
    return CGAffineTransformInvert([self hostParentToWorldTransform]);
}

/** with respect to the absolute world (the outermost world, the iPhone..?) */
- (CGAffineTransform)hostParentToAbsoluteWorldTransform {
    return [self.host.parent nodeToWorldTransform];
}

- (CGAffineTransform)absoluteWorldToHostParentTransform {
    return [self.host.parent worldToNodeTransform];
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
    if (p) {
        World *w = nil;
        while ((p = p.parent)) {
            if ((w = [p.componentManager componentForClass:self.worldClass])) {
                self.world = w;
                break;
            }
        }
        // flip the toggle
        _searchWorldAutomatically = NO;
    }
}

- (void)onAddComponent {
    [super onAddComponent];
    _searchWorldAutomatically = YES;
}

- (id)copyWithZone:(NSZone *)zone {
    Body *copy = (Body *) [super copyWithZone:zone];

    if (copy != nil) {
        copy->_worldClass = _worldClass;
        copy.velocity = self.velocity;
    }

    return copy;
}

@end