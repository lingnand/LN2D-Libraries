/*!
    @header B2DContactCallbackClosure
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "ContactCallbackClosure.h"
#import "B2DContactListener.h"

/**
* Note: the association of the NSPredicate follows the peculiarity of NSPredicate class
* If you'd like to retrieve/manage a NSPredicate later make sure use the format version
* of NSPredicate and not the block version
*/
typedef void (^B2DContactCallback) (B2DContact *);

@interface B2DContactCallbackClosure : ContactCallbackClosure
@property(nonatomic, copy) B2DContactCallback beginContact;
@property(nonatomic, copy) B2DContactCallback endContact;
@property(nonatomic, copy) B2DContactCallback preSolve;
@property(nonatomic, copy) B2DContactCallback postSolve;

+ (id)closureWithBeginContact:(B2DContactCallback)beginContact
                   endContact:(B2DContactCallback)endContact
                     preSolve:(B2DContactCallback)preSolve
                    postSolve:(B2DContactCallback)postSolve;

+ (id)closureWithBeginContact:(B2DContactCallback)beginContact
                   endContact:(B2DContactCallback)endContact;
@end

