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


/**
* Note: the association of the NSPredicate follows the peculiarity of NSPredicate class
* If you'd like to retrieve/manage a NSPredicate later make sure use the format version
* of NSPredicate and not the block version
*/
typedef void (^B2DContactCallback) (B2DContact *);

@interface B2DContactCallbackClosure : NSObject
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

+ (id)closureWithBeginContact:(B2DContactCallback)beginContact;
@end

@interface B2DContactListener : ContactListener


+ (id)listenerWithDictionary:(NSDictionary *)dictionary;

- (void)beginContact:(B2DContact *)contact;

- (void)endContact:(B2DContact *)contact;

- (void)preSolve:(B2DContact *)contact;

- (void)postSolve:(B2DContact *)contact;

- (void)setCallbackClosure:(B2DContactCallbackClosure *)closure forPredicate:(NSPredicate *)predicate;

- (void)setObject:(B2DContactCallbackClosure *)closure forKeyedSubscript:(NSPredicate *)predicate;

- (void)removeCallbackClosureForPredicate:(NSPredicate *)predicate;

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

- (B2DContactCallbackClosure *)objectForKeyedSubscript:(NSPredicate *)predicate;

- (B2DContactCallbackClosure *)callbackClosureForPredicate:(NSPredicate *)predicate;
@end