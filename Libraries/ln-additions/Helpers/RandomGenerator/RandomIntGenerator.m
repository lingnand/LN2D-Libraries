//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomIntGenerator.h"
#import "NSArray+LnAdditions.h"


@interface RandomIntGenerator ()
@property (nonatomic)int low;
@property (nonatomic)int high;
@end

@implementation RandomIntGenerator {

}

+ (id)generatorWithLowInt:(int)low highInt:(int)high {
    return [[self alloc] initWithLowInt:low highInt:high];
}

+ (id)generatorWithLowInt:(int)low highIntInclusive:(int)high {
    return [[self alloc] initWithLowInt:low highIntInclusive:high];
}

+ (id)generatorWithHighInt:(int)high {
    if (high < 0)
        [NSException raise:@"high int cannot be zero when no low int is given!" format:@"The argument given is %d",high];
    return [[self alloc] initWithHighInt:high];
}

+ (id)generatorWithHighIntInclusive:(int)high {
    return [[self alloc] initWithHighIntInclusive:high];
}


-(id) initWithLowInt:(int)low highInt:(int)high {
    if (self = [super init]) {
        self.high = high;
        self.low = low;
    }
    return self;
}

-(id) initWithLowInt:(int)low highIntInclusive:(int)high {
    return [self initWithLowInt:low highInt:high+1];
}


-(id) initWithHighInt:(int)high {
    return [self initWithLowInt:0 highInt:high];
}

-(id) initWithHighIntInclusive:(int)high {
    return [self initWithLowInt:0 highIntInclusive:high];
}

- (id)nextValue {
    return [NSNumber numberWithInt:randomIntInBounds(self.low, self.high)];
}

- (NSArray *)allValues {
    return [NSArray arrayWithRangeStartNumber:self.low endNumber:self.high];
}

- (id)valueAtIndex:(NSUInteger)index {
    return @(index + self.low);
}

- (NSUInteger)count {
    return (NSUInteger) (self.high - self.low);
}


@end