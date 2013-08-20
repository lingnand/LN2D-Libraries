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

@implementation Body {

}

+ (id)body {
    return [self component];
}

- (Class)worldClass {
    // the type string is in the format of T@"<ClassName>"
    const char *type = [self typeOfPropertyNamed:@"world"];
    NSString *cn = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", cn);
    NSArray *comps = [cn componentsSeparatedByString:@"\""];
//    NSLog(@"%@", comps);
    if (comps.count != 3)
        return nil;
    NSString *className = comps[1];
    return NSClassFromString(className);
//    NSString *name = [[NSString stringWithCString:type encoding:NSASCIIStringEncoding] copy];
//    NSString *className = [NSString stringWithString:name];
//    NSLog(@"className is %@", className);
//    const char *p = strchr(type, '"');
//    NSLog(@"the string is %s", p);
//    if (p == NULL)
//        return nil;
//    p += 1;
//    const char *e = strchr(type, '"');
//    if (e == NULL || e == p)
//        return nil;
//    int len = (int)(e-p);
//    char *className = malloc(len + 1);
//    memcpy(className, p, len);
//    className[len] = '\0';
//    NSLog(@"%@", name);
//    free(className);
}


- (void)setWorld:(World *)world {
    if (_world != world) {
        NSAssert(!world || [world isKindOfClass:self.worldClass], @"incompatible world being assigned!");
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