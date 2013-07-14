//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomDoubleGenerator.h"


@interface RandomDoubleGenerator ()
@property(nonatomic) double high;
@property(nonatomic) double low;
@end

@implementation RandomDoubleGenerator {

}


+ (id)generatorWithLowDouble:(double)low highDouble:(double)high {
    return [[self alloc] initWithLowDouble:low highDouble:high];
}


- (id)initWithLowDouble:(double)low highDouble:(double)high {
    if (self = [super init]) {
        self.high = high;
        self.low = low;
    }
    return self;
}

- (id)nextValue {
    return [NSNumber numberWithDouble:randomDoubleInBounds(self.low, self.high)];
}


@end