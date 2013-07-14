//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomPointGenerator.h"
#import "RandomDoubleGenerator.h"


@interface RandomPointGenerator ()
@property(nonatomic, strong) RandomDoubleGenerator *xRGen;
@property(nonatomic, strong) RandomDoubleGenerator *yRGen;
@end

@implementation RandomPointGenerator {

}

+(id)generatorWithRect:(CGRect)rect {
    return [[self.class alloc] initWithRect:rect];
}

+(id)generatorWithPoint:(CGPoint)point {
    return [[self.class alloc] initWithPoint:point];
}

-(id)initWithPoint:(CGPoint)point {
    return [self initWithRect:CGRectMake(point.x, point.y, 0, 0)];
}

- (id)initWithRect:(CGRect)rect {
    self = [super init];
    if (self) {
        self.xRGen = [RandomDoubleGenerator generatorWithLowDouble:rect.origin.x highDouble:rect.origin.x + rect.size.width];
        self.yRGen = [RandomDoubleGenerator generatorWithLowDouble:rect.origin.y highDouble:rect.origin.y + rect.size.height];
    }

    return self;
}

- (id)nextValue {
    return [NSValue valueWithCGPoint:CGPointMake(self.xRGen.nextFloat, self.yRGen.nextFloat)];
}


@end