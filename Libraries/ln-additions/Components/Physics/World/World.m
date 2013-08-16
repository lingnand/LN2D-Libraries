/*!
    @header World
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "World.h"
#import "Body.h"

/** the format of the body, world notification contains information about the
* relevant world/body. e.g. BodyWorldRequestNotification can be SimpleBody.BodyWorldRequest
* for example. This is to prevent the components from receiving unnecessary notifications */
NSString *BodyWorldRequestNotification = @"World.BodyWorldRequest";
NSString *WorldAddedNotification = @"World.WorldAddedNotification";
NSString *WorldRemovedNotification = @"World.WorldRemovedNotification";

@implementation World

+ (id)world {
    return [self new];
}

+ (NSString *)worldAddedNotificationName {
    static NSString *not = nil;
    if (!not)
        not = [NSString stringWithFormat:@"%@.WorldAdded", NSStringFromClass(self)];
    return not;
}

+ (NSString *)worldRemovedNotificationName {
    static NSString *not = nil;
    if (!not)
        not = [NSString stringWithFormat:@"%@.WorldRemoved", NSStringFromClass(self)];
    return not;
}

+ (NSString *)bodyWorldRequestNotificationName {
    static NSString *not = nil;
    if (!not)
        not = [NSString stringWithFormat:@"%@.BodyWorldRequest", NSStringFromClass(self)];
    return not;
}

- (void)onAddComponent {
    // register for Bodies posting world request
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bodyRequestingWorld:)
                                                 name:[self.class bodyWorldRequestNotificationName]
                                               object:nil];
    // declare to the world that I have been added to a delegate
    [[NSNotificationCenter defaultCenter] postNotificationName:[self.class worldAddedNotificationName] object:self];
}

- (void)bodyRequestingWorld:(NSNotification *)notification {
    // we can telling the body directly to consider this world as the delegate
    Body *body = notification.object;
    [body setClosestWorld:self];
}

- (void)onRemoveComponent {
    // declare to the world that I'm no longer attached to a proper delegate, so
    // the bodies attached to me should probably remove themselves
    [[NSNotificationCenter defaultCenter] postNotificationName:[self.class worldRemovedNotificationName] object:self];
    // remove self as the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end