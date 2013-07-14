//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomValueGenerator.h"
#import "RandomDoubleGenerator.h"


@interface RandomValueGenerator ()
@property(nonatomic, strong) NSArray *values;


@end

@implementation RandomValueGenerator {

}

+(id)generatorWithValues:(NSArray *)values {
    return [[self alloc] initWithValues:values];
}

// this should just create a rgen with even distribution for the values
-(id) initWithValues:(NSArray *)values {
    self = [super init];
    if (self) {
        self.values = values;
    }

    return self;
}

- (id)nextValue {
    return [self.values objectAtIndex:randomInt(self.values.count)];
}

- (NSArray *)allValues {
    /* since it's immutable, so don't care */
    return self.values;
}

- (id)valueAtIndex:(NSUInteger)index {
    return self.values[index];
}

- (NSUInteger)count {
    return self.values.count;
}


@end