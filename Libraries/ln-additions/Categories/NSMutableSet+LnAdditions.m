/*!
    @header NSMutableSet(LnAdditions)
    @copyright LnStudio
    @updated 21/08/2013
    @author lingnan
*/

#import "NSMutableSet+LnAdditions.h"


@implementation NSMutableSet (LnAdditions)

- (void)removeObjectsInArray:(NSArray *)arr {
    for (id obj in arr) {
        [self removeObject:obj];
    }
}
@end