//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"

@class RandomGenerator;
@class RandomStringGenerator;

@interface DisplayRandomizer : CCComponent

@property (nonatomic, weak) CCSprite *host;

+ (id)randomizerWithFrameNameGenerator:(RandomStringGenerator *)rgen;

- (id)initWithFrameNameGenerator:(RandomStringGenerator *)generator;

- (void)setNextDisplayFrame;

- (void)setDisplayFrameAtIndex:(NSUInteger)index1;

- (id)copyWithZone:(NSZone *)zone;

@end