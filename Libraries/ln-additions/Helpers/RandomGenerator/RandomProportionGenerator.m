//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomProportionGenerator.h"
#import "NSArray+LnAdditions.h"

@interface RandomProportionGenerator()
@property(nonatomic, strong) NSArray *values;
@property(nonatomic, strong) NSArray *probabilities;
@end

@implementation RandomProportionGenerator {

}

+(id)generatorWithValues:(NSArray *)values assignedProbabilities:(NSArray *)probArray {
    return [[self alloc] initWithValues:values assignedProbabilities:probArray];
}

// note that in this setup you cannot have the same value twice in the config
+(id)generatorWithValueProbabilityPairs:(NSDictionary *)probDict {
    NSArray *values = probDict.allKeys;
    NSArray *probs = probDict.allValues;
    return [[self alloc] initWithValues:values assignedProbabilities:probs];
}

- (id)initWithValues:(NSArray *)values assignedProbabilities:(NSArray *)probArray {
    self = [super init];
    if (self) {
        self.values = values;
        self.probabilities = probArray;
    }

    return self;
}

- (void)setProbabilities:(NSArray *)probabilities {
    if (_probabilities != probabilities) {
        if ([[probabilities valueForKeyPath:@"@sum.floatValue"] floatValue] != 1.0) {
            [NSException raise:@"Invalid probability value" format:@"sum = %f, which is not 1", [[probabilities valueForKeyPath:@"@sum.floatValue"] floatValue]];
        }

        _probabilities = probabilities;
        [self processDict];
    }
}

- (void)processDict {
    if (self.probabilities && self.values) {
        if (self.values.count != self.probabilities.count) {
            [NSException raise:@"Invalid parameters" format:@"The number of values not matching the number of keys given in the probabilites"];
        }
        // Put the two arrays into a dictionary as keys and values
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:_probabilities forKeys:[NSArray arrayWithRangeStartNumber:0 length:self.probabilities.count] ];
        // Sort the first array
        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
        _probabilities = [_probabilities sortedArrayUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
        // Sort the second array based on the sorted first array
        NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:_values.count];
        for (NSUInteger i = 0; i < _probabilities.count; i++) {
            if (i == 0 || ![_probabilities[i] isEqual:_probabilities[i-1]]) {
                for (NSNumber *index in [dictionary allKeysForObject:_probabilities[i]]) {
                    [newValues addObject:_values[index.unsignedIntValue]];
                }
            }
        }
        _values = newValues;
    }
}

- (void)setValues:(NSArray *)values {
    if (_values != values) {
        _values = values;
        [self processDict];
    }
}

// we want a common interface to get the random value. That is nextValue. Any int will be boxed in this regard
- (id)nextValue {
    double random = randomDouble();
    // just minus throughout the array until hitting on an index
    NSUInteger i = 0;
    for (NSNumber *prob in self.probabilities) {
        random -= prob.doubleValue;
        if (random <= 0) return self.values[i];
        i++;
    }
    return self.values.lastObject;
}

- (NSArray *)allValues {
    /* since nsarray immutable, so don't care, just return the array that's working on right now */
    return self.values;
}

- (id)valueAtIndex:(NSUInteger)index {
    return self.values[index];
}

- (NSUInteger)count {
    return self.values.count;
}


@end
