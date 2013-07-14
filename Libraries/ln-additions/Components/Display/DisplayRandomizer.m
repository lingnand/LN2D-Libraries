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
#import "BitMask.h"
#import "BitMaskData.h"
#import "CCSprite+LnAdditions.h"

@interface DisplayRandomizer ()

@property(nonatomic, strong) FiniteRandomGenerator *rStrGenerator;
@property (nonatomic)BOOL masked;

@property(nonatomic, copy) NSString *maskSuffix;
@property(nonatomic) UInt8 alphaThreshold;
@end

@implementation DisplayRandomizer {

}

+(id)randomizerWithFrameNameGenerator:(RandomStringGenerator *)rgen {
    return [[self alloc] initWithFrameNameGenerator:rgen];
}

+ (id)randomizerWithFrameNameGenerator:(RandomStringGenerator *)rgen maskSuffix:(NSString *)maskSuffix alphaThreshold:(UInt8)alpha {
    return [self randomizerWithFrameNameGenerator:rgen masked:YES maskSuffix:maskSuffix alphaThreshold:alpha];
}

- (id)initWithFrameNameGenerator:(RandomStringGenerator *)generator {
    return [self initWithFrameNameGenerator:generator masked:NO maskSuffix:nil alphaThreshold:0];
}

+ (id)randomizerWithFrameNameGenerator:(RandomStringGenerator *)rgen masked:(BOOL)masked maskSuffix:(NSString *)maskSuffix alphaThreshold:(UInt8)alpha {
    return [[self alloc] initWithFrameNameGenerator:rgen masked:masked maskSuffix:maskSuffix alphaThreshold:alpha];
}

- (id)initWithFrameNameGenerator:(RandomStringGenerator *)rgen masked:(BOOL)masked maskSuffix:(NSString *)maskSuffix alphaThreshold:(UInt8)alpha {
    self = [super init];
    if (self) {
        self.rStrGenerator = rgen;
        self.masked = masked;
        self.maskSuffix = maskSuffix;
        self.alphaThreshold = alpha;
        // load up all the masks
        if (masked) {
            MaskDataCache *cache = [MaskDataCache sharedCache];
            for (NSString *str in rgen.allValues) {
                cache[str] = [BitMaskData dataWithFrameName:str alphaThreshold:alpha maskSuffix:maskSuffix];
            }
        }
    }
    return self;
}

- (void)onAddComponent {
    NSAssert([self.delegate isKindOfClass:[CCSprite class]], @"Must be a CCSprite for a DisplayRandomizer to work!");
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
    if (self.masked)
        [(CCSprite *) self.delegate setDisplayFrameWithFrameName:name maskSuffix:self.maskSuffix maskAlphaThreshold:self.alphaThreshold];
    else
        [(CCSprite *) self.delegate setDisplayFrameWithFrameName:name];
}

- (id)copyWithZone:(NSZone *)zone {
    DisplayRandomizer *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.rStrGenerator = self.rStrGenerator;
        copy.masked = self.masked;
        copy.maskSuffix = self.maskSuffix;
        copy.alphaThreshold = self.alphaThreshold;
    }

    return copy;
}


@end