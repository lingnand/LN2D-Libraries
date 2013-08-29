/*!
    @header CollisionHandler
    @copyright LnStudio
    @updated 13/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "ContactCallbackClosure.h"


@interface ContactListener : NSObject

+(id)listener;

+ (id)listenerWithDictionary:(NSDictionary *)dictionary;

- (void)beginContact:(Contact *)contact;

- (void)setCallbackClosure:(ContactCallbackClosure *)closure forPredicate:(NSPredicate *)predicate;

- (void)setObject:(ContactCallbackClosure *)closure forKeyedSubscript:(NSPredicate *)predicate;

- (void)removeCallbackClosureForPredicate:(NSPredicate *)predicate;

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

- (ContactCallbackClosure *)objectForKeyedSubscript:(NSPredicate *)predicate;

- (ContactCallbackClosure *)callbackClosureForPredicate:(NSPredicate *)predicate;
@end
