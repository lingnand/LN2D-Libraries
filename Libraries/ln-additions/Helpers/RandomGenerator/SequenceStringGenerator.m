//
// Created by knight on 20/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "SequenceStringGenerator.h"


@interface SequenceStringGenerator ()
@property(nonatomic) NSUInteger count;
@property(nonatomic) NSInteger start;
@property(nonatomic, copy) NSString *formatString;
@end

@implementation SequenceStringGenerator {

}

+(id)generatorWithFormat:(NSString *)format count:(NSUInteger)count {
    return [[self alloc] initWithFormat:format start:0 count:count];
}

+(id)generatorWithFormat:(NSString *)format start:(NSInteger)start count:(NSUInteger)count {
    return [[self alloc] initWithFormat:format start:start count:count];
}

- (id)initWithFormat:(NSString *)format start:(NSInteger)start count:(NSUInteger)count {
    self = [super init];
    if (self) {
        self.formatString = format;
        self.start = start;
        self.count = count;
    }
    return self;
}

- (NSArray *)allValues {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger j = 0; j < self.count; j++) {
        [array addObject:[self valueAtIndex:j]];
    }
    return array;
}

-(id)valueAtIndex:(NSUInteger)index {
    return [NSString stringWithFormat:self.formatString, index + self.start];
}

-(id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self valueAtIndex:index];
}


@end