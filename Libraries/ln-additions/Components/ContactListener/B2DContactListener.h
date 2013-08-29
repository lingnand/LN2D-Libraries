/*!
    @header B2DCollisionHandler
    @copyright LnStudio
    @updated 14/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "ContactListener.h"
#import "B2DBody.h"
#import "B2DContact.h"
#import "ContactCallbackClosure.h"

@class B2DContactCallbackClosure;



@interface B2DContactListener : ContactListener


- (void)endContact:(B2DContact *)contact;

- (void)preSolve:(B2DContact *)contact;

- (void)postSolve:(B2DContact *)contact;

@end