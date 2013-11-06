/*!
    @header CollisionHandler
    @copyright LnStudio
    @updated 13/07/2013
    @author lingnan
*/

#import "ContactListener_protected.h"


@implementation ContactListener {

}
+ (id)listener {
    return [self new];
}

+ (id)listenerWithDictionary:(NSDictionary *)dictionary {
    ContactListener *l = [self listener];
    [l addEntriesFromDictionary:dictionary];
    return l;
}

- (void)setCallbackClosure:(ContactCallbackClosure *)closure forPredicate:(NSPredicate *)predicate {
    self.writableContactCallBacks[predicate] = closure;
}

- (void)setObject:(ContactCallbackClosure *)closure forKeyedSubscript:(NSPredicate *)predicate {
    [self setCallbackClosure:closure forPredicate:predicate];
}

- (void)removeCallbackClosureForPredicate:(NSPredicate *)predicate {
    [self.contactCallBacks removeObjectForKey:predicate];
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary {
    [self.writableContactCallBacks addEntriesFromDictionary:dictionary];
}

- (ContactCallbackClosure *)callbackClosureForPredicate:(NSPredicate *)predicate {
    return self.contactCallBacks[predicate];
}


// the simplest instance can be just holding two blocks to
// respondsToPredicate:(predicate) withBeginContactWith:(block) endContactWith:(block)
// a set of predicate: and begin contact and end contact array..?
- (void)beginContact:(Contact *)contact {
    // loop through all the callback blocks
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, ContactCallbackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
        BLOCK_SAFE_RUN(closure.beginContact, contact);
    }];
}

- (ContactCallbackClosure *)objectForKeyedSubscript:(NSPredicate *)predicate {
    return [self callbackClosureForPredicate:predicate];
}

- (NSMutableDictionary *)writableContactCallBacks {
    if (!_contactCallBacks) {
        _contactCallBacks = [NSMutableDictionary dictionary];
    }
    return _contactCallBacks;
}

@end