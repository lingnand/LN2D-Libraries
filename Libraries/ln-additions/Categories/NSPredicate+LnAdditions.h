/*!
    @header NSPredicate(LnAdditions)
    @copyright LnStudio
    @updated 21/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@interface NSPredicate (LnAdditions)
+ (id)predicateWithKindOfClassFilter:(Class)aClass;

+ (id)predicateWithRespondsToSelectorFilter:(SEL)selector;

+ (id)predicateWithConformsToProtocolFilter:(Protocol *)protocol;
@end