/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "Body.h"
#import "World.h"
#import "NSObject+Properties.h"
#include "NSObject+LnAdditions.h"

@implementation Body {
    Class _worldClass;
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


- (void)setWorld:(World *)world {
    if (_world != world) {
        _world = world;
        [self worldChangedFrom:_world to:world];
    }
}

- (void)worldChangedFrom:(World *)ow to:(World *)nw {
    if (ow)
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[self.worldClass worldRemovedNotificationName]
                                                      object:ow];
    // need to add the observer for the new world
    if (nw)
        [[NSNotificationCenter defaultCenter] addObserverForName:[self.worldClass worldRemovedNotificationName]
                                                          object:nw
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          // requesting new world to set myself
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:[self.worldClass bodyWorldRequestNotificationName]
                                                                                                              object:self];
                                                      }];
}

- (void)setClosestWorld:(World *)world {
    // check if the world is closest to the current
    if (world != self.world) {
        if (!self.world.host) {
            self.world = world;
        } else if (world.host) {
            // traverse the tree up until meeting the world
            CCNode *p = self.host;
            while ((p = p.parent) && p != self.world.host) {
                if (p == world.host) {
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
    [[NSNotificationCenter defaultCenter] addObserverForName:[self.worldClass worldAddedNotificationName]
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self setClosestWorld:note.object];
                                                  }];
}

- (void)onRemoveComponent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end