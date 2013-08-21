/*!
    @header NSPredicate(LnAdditions)
    @copyright LnStudio
    @updated 21/08/2013
    @author lingnan
*/

#import "NSPredicate+LnAdditions.h"


@implementation NSPredicate (LnAdditions)

+ (id)predicateWithKindOfClassFilter:(Class)aClass {
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:aClass];
    }];
}

+ (id)predicateWithRespondsToSelectorFilter:(SEL)selector {
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:selector];
    }];
}
@end