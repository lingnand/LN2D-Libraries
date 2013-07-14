//
// Created by Lingnan Dai on 25/06/2013.
//


#import <Foundation/Foundation.h>

//TODO: maybe the spriteCache can be initialized with an invariant such that it can
//be dedicated entirely to a purpose: e.g. serving for bulletCache one just needs
//to make sure that the frameName is the same

@interface CCSpriteCache : NSObject
// size is an abstract concept that evaluates to the current number of sprites in memory for this cache
// it DOES NOT necessarily equal to the number of sprites actually held in the cache itself!
// e.g. it should equal to no. of sprites lent out + no. of sprites in the cache currently
@property(nonatomic) NSUInteger size;
@end