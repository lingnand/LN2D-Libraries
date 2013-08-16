/*!
    @header B2DCollisionHandler
    @copyright LnStudio
    @updated 14/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DContactListener.h"

@implementation B2DContactCallBackClosure
+ (id)callBackClosureWithBeginContact:(B2DContactCallBack)beginContact
                           endContact:(B2DContactCallBack)endContact
                             preSolve:(B2DContactCallBack)preSolve
                            postSolve:(B2DContactCallBack)postSolve {
    B2DContactCallBackClosure *closure = [[self alloc] init];
    closure.beginContact = beginContact;
    closure.endContact = endContact;
    closure.preSolve = preSolve;
    closure.postSolve = postSolve;
    return closure;
}

@end

@interface B2DContactListener ()
@property(nonatomic, strong) NSMutableDictionary *contactCallBacks;
@end

@implementation B2DContactListener {

}

// the simplest instance can be just holding two blocks to
// respondsToPredicate:(predicate) withBeginContactWith:(block) endContactWith:(block)
// a set of predicate: and begin contact and end contact array..?
- (void)beginContact:(B2DContact *)contact {
    // loop through all the callback blocks
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallBackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.beginContact,contact);
    }];
}

- (void)endContact:(B2DContact *)contact {
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallBackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.endContact,contact);
    }];
}

- (void)preSolve:(B2DContact *)contact {
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallBackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.preSolve,contact);
    }];
}

- (void)postSolve:(B2DContact *)contact {
    [self.contactCallBacks enumerateKeysAndObjectsUsingBlock:^(NSPredicate *predicate, B2DContactCallBackClosure *closure, BOOL *stop) {
        if ([predicate evaluateWithObject:contact])
            BLOCK_SAFE_RUN(closure.postSolve,contact);
    }];
}

- (void)setCallBackClosure:(B2DContactCallBackClosure *)closure
              forPredicate:(NSPredicate *)predicate {
    self.contactCallBacks[predicate] = closure;
}

- (void)setObject:(B2DContactCallBackClosure *)closure forKeyedSubscript:(NSPredicate *)predicate {
    [self setCallBackClosure:closure forPredicate:predicate];
}

- (B2DContactCallBackClosure *)objectForKeyedSubscript:(NSPredicate *)predicate {
    return [self callBackClosureForPredicate:predicate];
}

- (B2DContactCallBackClosure *)callBackClosureForPredicate:(NSPredicate *)predicate {
    return self.contactCallBacks[predicate];
}

- (NSMutableDictionary *)contactCallBacks {
    if (!_contactCallBacks) {
        _contactCallBacks = [NSMutableDictionary dictionary];
    }
    return _contactCallBacks;
}

@end