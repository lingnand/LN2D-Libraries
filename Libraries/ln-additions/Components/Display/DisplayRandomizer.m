//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "DisplayRandomizer.h"
#import "RandomGenerator.h"
#import "MaskDataCache.h"
#import "FiniteRandomGenerator.h"
#import "RandomStringGenerator.h"
#import "SequenceStringGenerator.h"
#import "NSObject+REResponder.h"
#import "CCNode+LnAdditions.h"
#import "PixelMask.h"
#import "PixelMaskData.h"
#import "CCSprite+LnAdditions.h"

@interface DisplayRandomizer ()
@property(nonatomic, strong) FiniteRandomGenerator *rStrGenerator;
@end

@implementation DisplayRandomizer {

}

+(id)randomizerWithFrameNameGenerator:(RandomStringGenerator *)rgen {
    return [[self alloc] initWithFrameNameGenerator:rgen];
}

- (id)initWithFrameNameGenerator:(RandomStringGenerator *)rgen {
    self = [super init];
    if (self) {
        self.rStrGenerator = rgen;
    }
    return self;
}

- (void)componentAdded {
    // initialize the display for the delegate
    [self setNextDisplayFrame];
}

- (void)setNextDisplayFrame {
    [self setDisplayFrameWithName:self.rStrGenerator.nextValue];
}

- (void)setDisplayFrameAtIndex:(NSUInteger)index {
    [self setDisplayFrameWithName:self.rStrGenerator[index]];
}

- (void)setDisplayFrameWithName:(NSString *)name {
    [self.host setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name]];
}

- (id)copyWithZone:(NSZone *)zone {
    DisplayRandomizer *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.rStrGenerator = self.rStrGenerator;
    }

    return copy;
}


@end