/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "Body.h"
#import "World.h"

@implementation Body {

}
+ (id)bodyWithPhysicsEngine:(World *)world {
    Body *b = [self body];
    b.world = world;
    return b;
}

+ (id)body {
    return [self component];
}

- (Class)worldClass {
    return [World class];
}


- (void)setWorld:(World *)world {
    if (_world != world ) {
        NSAssert(!world || [world isKindOfClass:self.worldClass], @"incompatible world being assigned!");
        [self worldChangedFrom:_world to:world];
        _world = world;
    }
}

- (void)worldChangedFrom:(World *)ow to:(World *)nw {
    if (ow)
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[self.worldClass worldRemovedNotificationName]
                                                      object:ow];
    // need to add the observer for the new world
    if (nw)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(worldRemoved:)
                                                     name:[self.worldClass worldRemovedNotificationName]
                                                   object:nw];
}

- (void)setClosestWorld:(World *)world {
    // check if the world is closest to the current
    if (world != self.world) {
        if (!self.world.delegate) {
            self.world = world;
        } else if (world.delegate) {
            // traverse the tree up until meeting the world
            CCNode *p = self.delegate;
            while ((p = p.parent) && p != self.world.delegate) {
                if (p == world.delegate) {
                    self.world = world;
                }
            }
        }
    }
}

- (void)onAddComponent {
    // requesting world component
    [[NSNotificationCenter defaultCenter] postNotificationName:[self.worldClass bodyWorldRequestNotificationName] object:self];
    // observing for world changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(worldAdded:)
                                                 name:[self.worldClass worldAddedNotificationName]
                                               object:nil];
}

- (void)worldAdded:(NSNotification *)notification {
    World *world = notification.object;
    [self setClosestWorld:world];
}

- (void)worldRemoved:(NSNotification *)notification {
    // requesting new world to set myself
    [[NSNotificationCenter defaultCenter] postNotificationName:[self.worldClass bodyWorldRequestNotificationName] object:self];
}

- (void)onRemoveComponent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end