//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "RandomGenerator.h"
#import "FiniteRandomGenerator.h"


@interface RandomValueGenerator : FiniteRandomGenerator
+ (id)generatorWithValues:(NSArray *)values;

- (id)initWithValues:(NSArray *)values;


@end