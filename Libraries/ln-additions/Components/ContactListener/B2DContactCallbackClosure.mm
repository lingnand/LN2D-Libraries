/*!
    @header B2DContactCallbackClosure
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DContactCallbackClosure.h"


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

@end

