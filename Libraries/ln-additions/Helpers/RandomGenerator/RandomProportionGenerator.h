//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "RandomGenerator.h"
#import "FiniteRandomGenerator.h"


@interface RandomProportionGenerator : FiniteRandomGenerator
+ (id)generatorWithValues:(NSArray *)values assignedProbabilities:(NSArray *)probArray;

+ (id)generatorWithValueProbabilityPairs:(NSDictionary *)probDict;

- (id)initWithValues:(NSArray *)values assignedProbabilities:(NSArray *)probArray;


@end