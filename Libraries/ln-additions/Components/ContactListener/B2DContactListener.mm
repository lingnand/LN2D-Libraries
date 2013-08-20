/*!
    @header B2DCollisionHandler
    @copyright LnStudio
    @updated 14/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DContactListener.h"

@implementation B2DContactCallbackClosure
+ (id)closureWithBeginContact:(B2DContactCallback)beginContact
                   endContact:(B2DContactCallback)endContact
                     preSolve:(B2DContactCallback)preSolve
                    postSolve:(B2DContactCallback)postSolve {
    B2DContactCallbackClosure *closure = [[self alloc] init];
    closure.beginContact = beginContact;
    closure.endContact = endContact;
    closure.preSolve = preSolve;
    closure.postSolve = postSolve;
    return closure;
}

+ (id)closureWithBeginContact:(B2DContactCallback)beginContact
                   endContact:(B2DContactCallback)endContact {
    return [self closureWithBeginContact:beginContact
                              endContact:endContact
                                preSolve:nil
                               postSolve:nil];
}

+ (id)closureWithBeginContact:(B2DContactCallback)beginContact {
    return [self closureWithBeginContact:beginContact
                              endContact:nil
                                preSolve:nil
                               postSolve:nil];
}
@end

@interface B2DContactListener ()
@property(nonatomic, strong) NSMutableDictionary *contactCallBacks;
@end

@implementation B2DContactListener {

}

+ (id)listenerWithDictionary:(NSDictionary *)dictionary {
    B2DContactListener *l = [self listener];
    [l addEntriesFromDictionary:dictionary];
    return l;
}

// the simplest instance can be just holding two blocks to
// respondsToPredicate:(predicate) withBeginContactWith:(block) endContactWith:(block)
// a set of predicate: and begin contact and end contact array..?
- (void)beginContact:(B2DContact *)contact {
    // loop through all the callback blocks
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallbackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.beginContact,contact);
    }];
}

- (void)endContact:(B2DContact *)contact {
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallbackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.endContact,contact);
    }];
}

- (void)preSolve:(B2DContact *)contact {
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallbackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.preSolve,contact);
    }];
}

- (void)postSolve:(B2DContact *)contact {
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallbackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.postSolve,contact);
    }];
}

- (void)setCallbackClosure:(B2DContactCallbackClosure *)closure
              forPredicate:(NSPredicate *)predicate {
    self.contactCallBacks[predicate] = closure;
}

- (void)setObject:(B2DContactCallbackClosure *)closure forKeyedSubscript:(NSPredicate *)predicate {
    [self setCallbackClosure:closure forPredicate:predicate];
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary {
    [self.contactCallBacks addEntriesFromDictionary:dictionary];
}

- (B2DContactCallbackClosure *)objectForKeyedSubscript:(NSPredicate *)predicate {
    return [self callbackClosureForPredicate:predicate];
}

- (B2DContactCallbackClosure *)callbackClosureForPredicate:(NSPredicate *)predicate {
    return self.contactCallBacks[predicate];
}

- (NSMutableDictionary *)contactCallBacks {
    if (!_contactCallBacks) {
        _contactCallBacks = [NSMutableDictionary dictionary];
    }
    return _contactCallBacks;
}

@end