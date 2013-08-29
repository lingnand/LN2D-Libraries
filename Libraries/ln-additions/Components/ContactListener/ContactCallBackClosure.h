/*!
    @header ContactCallBackClosure
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Contact.h"


typedef void (^ContactCallback) (Contact *);

@interface ContactCallbackClosure : NSObject
@property(nonatomic, copy) ContactCallback beginContact;
@end