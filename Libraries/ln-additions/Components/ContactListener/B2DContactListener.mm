/*!
    @header B2DCollisionHandler
    @copyright LnStudio
    @updated 14/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "ContactListener_protected.h"
#import "B2DContactListener.h"
#import "B2DContactCallbackClosure.h"

@implementation B2DContactListener {

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

@end