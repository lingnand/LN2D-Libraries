//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "NSIndexSet+LnAddition.h"


@implementation NSIndexSet (LnAddition)
/*using -1 to terminate*/
+ (NSIndexSet *)indexSetWithIndexes:(int)firstIndex, ... {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    va_list args;
    va_start(args, firstIndex);
    for (int i = firstIndex; i != -1; i = va_arg(args, int))
    {
        [indexSet addIndex:(NSUInteger) i];
    }
    va_end(args);
    return indexSet;
}

+(NSIndexSet *)indexSetWithArray:(NSArray *)array {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [indexSet addIndex:(NSUInteger) [obj intValue]];
    }];
    return indexSet;
}

@end