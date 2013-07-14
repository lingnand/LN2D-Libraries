//
// Created by knight on 03/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "NSFloatSet.h"

@interface NSFloatSet ()
@property(nonatomic, strong) NSMutableIndexSet *indexSet;
@end

@implementation NSFloatSet {

}

/*using NAN to terminate */
+ (NSFloatSet *)floatSetWithFloats:(float)firstFloat, ... {
    NSFloatSet *floatSet = [[NSFloatSet alloc] init];
    va_list args;
    va_start(args, firstFloat);
    for (float i = firstFloat; i == i; i = va_arg(args, double)) {
        [floatSet addFloat:i];
    }
    va_end(args);
    return floatSet;
}

+ (NSFloatSet *)floatSetWithFloat:(float)f {
    return [[self alloc] initWithFloat:f];
}

-(NSMutableIndexSet *)indexSet {
    if (!_indexSet)
        _indexSet = [NSMutableIndexSet indexSet];
    return _indexSet;
}

- (id)initWithFloat:(float)f {
    if (self = [super init]) {
        self.indexSet = [NSMutableIndexSet indexSetWithIndex:indexFromFloat(f)];
    }
    return self;
}

- (void)addFloat:(float)f {
    [self.indexSet addIndex:indexFromFloat(f)];
}

- (void)enumerateFloatsUsingBlock:(void (^)(float f, BOOL *stop))block {
    [self.indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        block(floatFromIndex(idx), stop);
    }];
}

- (float)firstFloat {
    return floatFromIndex(self.indexSet.firstIndex);
}

- (float)lastFloat {
    return floatFromIndex(self.indexSet.lastIndex);
}

- (NSUInteger)count {
    return [self.indexSet count];
}

- (BOOL)containsFloat:(float)f {
    return [self.indexSet containsIndex:indexFromFloat(f)];
}

- (BOOL)containsFloats:(NSFloatSet *)floatSet {
    return [self.indexSet containsIndexes:floatSet.indexSet];
}

-(float)sum {
    __block float sum = 0;
    [self enumerateFloatsUsingBlock:^(float f, BOOL *stop) {
        sum+=f;
    }];
    return sum;
}


@end