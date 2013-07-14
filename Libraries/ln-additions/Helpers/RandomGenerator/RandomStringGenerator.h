//
// Created by knight on 04/02/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "RandomGenerator.h"

@class SequenceStringGenerator;


@interface RandomStringGenerator : FiniteRandomGenerator

- (id)initWithSequenceStringGenerator:(SequenceStringGenerator *)sequenceStringGenerator;

+ (id)generatorWithSeqStrGenerator:(SequenceStringGenerator *)sequenceStringGenerator;
@end