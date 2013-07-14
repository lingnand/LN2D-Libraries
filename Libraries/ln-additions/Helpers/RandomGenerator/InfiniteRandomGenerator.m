//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomValueGenerator.h"
#import "RandomGenerator.h"
#import "InfiniteRandomGenerator.h"
#import "RandomDoubleGenerator.h"
#import "RandomPointGenerator.h"


@implementation InfiniteRandomGenerator {

}
+ (id)doubleGeneratorWithLowDouble:(double)low highDouble:(double)high {
    return [RandomDoubleGenerator generatorWithLowDouble:low highDouble:high];
}

+ (id)pointGeneratorWithRect:(CGRect)rect {
    return [RandomPointGenerator generatorWithRect:rect];
}

+ (id)pointGeneratorWithPoint:(CGPoint)point {
    return [RandomPointGenerator generatorWithPoint:point];
}


- (double)nextDouble {
    id next = [self nextValue];
    if ([next respondsToSelector:@selector(doubleValue)])
        return [next doubleValue];
    else
        [NSException raise:@"Asking a double from a generator that generates objects instead" format:@"The object you get is %@", next];
}

- (float) nextFloat {
    id next = [self nextValue];
    if ([next respondsToSelector:@selector(floatValue)])
        return [next floatValue];
    else
        [NSException raise:@"Asking a float from a generator that generates objects instead" format:@"The object you get is %@", next];
}

- (CGPoint)nextPoint {
    id next = [self nextValue];
    if ([next respondsToSelector:@selector(CGPointValue)])
        return [next CGPointValue];
    else
        [NSException raise:@"Asking a point from a generator that generates objects instead" format:@"The object you get is %@", next];
}

@end