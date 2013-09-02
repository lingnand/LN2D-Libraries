/*!
    @header NSPredicate(LnAdditions)
    @copyright LnStudio
    @updated 21/08/2013
    @author lingnan
*/

#import "NSPredicate+LnAdditions.h"
#import "NSCache+LnAdditions.h"


@implementation NSPredicate (LnAdditions)

/** All filters need to be:
 * - comparable (multiple calls return instances on which isEqual: returns true)
 * - provides fast access (average cost for multiple calls should be as low as
 * possible)
 * This ensures that the NSPredicate instance can be used as a key
 * */
 + (id)predicateWithKindOfClassFilter:(Class)aClass {
    return [[self predicateCacheTable] objectForKey:aClass valueGenerator:^id(id key) {
        return [NSPredicate predicateWithFormat:@"SELF isKindOfClass: %@", aClass];
    }];
}

+ (id)predicateWithRespondsToSelectorFilter:(SEL)selector {
    return [[self predicateCacheTable] objectForKey:[NSValue valueWithPointer:selector] valueGenerator:^id(id key) {
        return [NSPredicate predicateWithFormat:@"SELF respondsToSelectorName: %@", NSStringFromSelector(selector)];
    }];
}

+ (id)predicateWithConformsToProtocolFilter:(Protocol *)protocol {
    return [[self predicateCacheTable] objectForKey:protocol valueGenerator:^id(id key) {
        return [NSPredicate predicateWithFormat:@"SELF conformsToProtocol: %@", protocol];
    }];
}

+ (NSCache *)predicateCacheTable {
    static NSCache *predicateCacheTable = nil;
    if (!predicateCacheTable) {
        predicateCacheTable = [NSCache cache];
    }
    return predicateCacheTable;
}
@end