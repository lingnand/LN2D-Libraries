/*!
    @header NSPredicate(LnAdditions)
    @copyright LnStudio
    @updated 21/08/2013
    @author lingnan
*/

#import "NSPredicate+LnAdditions.h"


@implementation NSPredicate (LnAdditions)

/** All filters are:
 * - comparable
 * This ensures that the NSPredicate instance can be used as a key
 * */
 + (id)predicateWithKindOfClassFilter:(Class)aClass {
    return [NSPredicate predicateWithFormat:@"SELF isKindOfClass: %@", aClass];
}

+ (id)predicateWithRespondsToSelectorFilter:(SEL)selector {
    return [NSPredicate predicateWithFormat:@"SELF respondsToSelectorName: %@", NSStringFromSelector(selector)];
}
@end