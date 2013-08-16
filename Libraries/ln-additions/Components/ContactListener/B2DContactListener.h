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


typedef void (^B2DContactCallBack) (B2DContact *);

@interface B2DContactCallBackClosure : NSObject
@property(nonatomic, copy) B2DContactCallBack beginContact;
@property(nonatomic, copy) B2DContactCallBack endContact;
@property(nonatomic, copy) B2DContactCallBack preSolve;
@property(nonatomic, copy) B2DContactCallBack postSolve;

+ (id)callBackClosureWithBeginContact:(B2DContactCallBack)beginContact endContact:(B2DContactCallBack)endContact preSolve:(B2DContactCallBack)preSolve postSolve:(B2DContactCallBack)postSolve;
@end

@interface B2DContactListener : ContactListener


- (void)beginContact:(B2DContact *)contact;

- (void)endContact:(B2DContact *)contact;

- (void)preSolve:(B2DContact *)contact;

- (void)postSolve:(B2DContact *)contact;

- (void)setCallBackClosure:(B2DContactCallBackClosure *)closure forPredicate:(NSPredicate *)predicate;

- (void)setObject:(B2DContactCallBackClosure *)closure forKeyedSubscript:(NSPredicate *)predicate;

- (B2DContactCallBackClosure *)objectForKeyedSubscript:(NSPredicate *)predicate;

- (B2DContactCallBackClosure *)callBackClosureForPredicate:(NSPredicate *)predicate;
@end