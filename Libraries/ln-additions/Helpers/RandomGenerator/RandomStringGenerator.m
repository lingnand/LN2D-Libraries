//
// Created by knight on 04/02/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FiniteRandomGenerator.h"
#import "RandomStringGenerator.h"
#import "InfiniteRandomGenerator.h"
#import "SequenceStringGenerator.h"
#import "RandomIntGenerator.h"


@interface RandomStringGenerator ()
@property(nonatomic, strong) SequenceStringGenerator *sequenceStringGenerator;
@property(nonatomic, strong) RandomIntGenerator *countGenerator;
@end

@implementation RandomStringGenerator {

}

/* the format string should use %@ to specify the replacement since it's all about objects */
+ (id)generatorWithSeqStrGenerator:(SequenceStringGenerator *)sequenceStringGenerator {
    return [[self alloc] initWithSequenceStringGenerator:sequenceStringGenerator];
}

- (id)initWithSequenceStringGenerator:(SequenceStringGenerator *)sequenceStringGenerator {
    self = [super init];
    if (self) {
        self.sequenceStringGenerator = sequenceStringGenerator;
        self.countGenerator = [RandomIntGenerator intGeneratorWithHighInt:sequenceStringGenerator.count];
    }

    return self;
}

- (id)nextValue {
    return self.sequenceStringGenerator[(NSUInteger) self.countGenerator.nextInt];
}


- (NSArray *)allValues {
    return self.sequenceStringGenerator.allValues;
}

- (id)valueAtIndex:(NSUInteger)index {
    return self.sequenceStringGenerator[index];
}

- (NSUInteger)count {
    return self.sequenceStringGenerator.count;
}


@end