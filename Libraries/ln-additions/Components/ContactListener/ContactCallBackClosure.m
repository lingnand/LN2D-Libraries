/*!
    @header ContactCallBackClosure
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import "ContactCallbackClosure.h"


@implementation ContactCallbackClosure {

}

+ (id)closureWithBeginContact:(ContactCallback)beginContact {
    ContactCallbackClosure *closure = [self new];
    closure.beginContact = beginContact;
    return closure;
}

@end