//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "NSArray+LnAdditions.h"


@implementation NSArray (LnAdditions)

+ (id)arrayWithRangeStartNumber:(int)start length:(NSUInteger)length {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:length];
    for (int i = start; i<start+(int)length; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    return arr;
}


/* end number is exclusive */
+(id)arrayWithRangeStartNumber:(int)start endNumber:(int)end {
    if (end < start)
        [NSException raise:@"end number is bigger than the start number!" format:@"start number is %d; end number is %d",start,end];
    return [self arrayWithRangeStartNumber:start length:(NSUInteger) (end - start)];
}

- (NSArray *)stretched {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]])
            [arr addObjectsFromArray:obj];
        else
            [arr addObject:obj];
    }
    return arr;
}

- (NSArray *)flattened {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]])
            [arr addObjectsFromArray:[obj flattened]];
        else
            [arr addObject:obj];
    }
    return arr;
}



@end