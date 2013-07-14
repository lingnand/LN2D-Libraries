//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "RandomGenerator.h"

@class SequenceStringGenerator;


@interface FiniteRandomGenerator : RandomGenerator

+ (id)intGeneratorWithLowInt:(int)low highInt:(int)high;

+ (id)intGeneratorWithLowInt:(int)low highIntInclusive:(int)high;

+ (id)intGeneratorWithHighInt:(int)high;

+ (id)intGeneratorWithHighIntInclusive:(int)high;

+ (id)valueGeneratorWithValues:(NSArray *)values;

+ (id)proportionValueGeneratorWithValues:(NSArray *)values assignedProbabilities:(NSArray *)probArray;

+ (id)proportionValueGeneratorWithValueProbabilityPairs:(NSDictionary *)dict;

+ (id)stringGeneratorWithSequenceStringGenerator:(SequenceStringGenerator *)sequenceStringGenerator;

- (id)objectAtIndexedSubscript:(NSUInteger)index1;

- (NSArray *)allValues;

- (id)valueAtIndex:(NSUInteger)index;

- (NSUInteger)count;

@end