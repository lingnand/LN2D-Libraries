//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "RandomGenerator.h"


@interface InfiniteRandomGenerator : RandomGenerator
+ (id)doubleGeneratorWithLowDouble:(double)low highDouble:(double)high;

+ (id)pointGeneratorWithRect:(CGRect)rect;

+ (id)pointGeneratorWithPoint:(CGPoint)point;

-(double)nextDouble;

- (float)nextFloat;

-(CGPoint)nextPoint;
@end