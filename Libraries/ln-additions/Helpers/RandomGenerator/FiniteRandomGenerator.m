//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomProportionGenerator.h"
#import "RandomValueGenerator.h"
#import "RandomIntGenerator.h"
#import "RandomStringGenerator.h"
#import "SequenceStringGenerator.h"


@implementation FiniteRandomGenerator {

}


+ (id)intGeneratorWithLowInt:(int)low highInt:(int)high {
    return [RandomIntGenerator generatorWithLowInt:low highInt:high];
}

+ (id)intGeneratorWithLowInt:(int)low highIntInclusive:(int)high {
    return [RandomIntGenerator generatorWithLowInt:low highIntInclusive:high];
}

+ (id)intGeneratorWithHighInt:(int)high {
    return [RandomIntGenerator generatorWithHighInt:high];
}

+ (id)intGeneratorWithHighIntInclusive:(int)high {
    return [RandomIntGenerator generatorWithHighIntInclusive:high];
}

+ (id)valueGeneratorWithValues:(NSArray *)values {
    return [RandomValueGenerator generatorWithValues:values];
}

+ (id)proportionValueGeneratorWithValues:(NSArray *)values assignedProbabilities:(NSArray *)probArray {
    return [RandomProportionGenerator generatorWithValues:values assignedProbabilities:probArray];
}

+ (id)proportionValueGeneratorWithValueProbabilityPairs:(NSDictionary *)dict {
    return [RandomProportionGenerator generatorWithValueProbabilityPairs:dict];
}

+ (id)stringGeneratorWithSequenceStringGenerator:(SequenceStringGenerator *)sequenceStringGenerator {
    return [RandomStringGenerator generatorWithSeqStrGenerator:sequenceStringGenerator];
}

-(id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self valueAtIndex:index];
}

@end