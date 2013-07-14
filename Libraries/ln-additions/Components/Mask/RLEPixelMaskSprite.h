//
// Created by knight on 26/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "cocos2d.h"

// Some useful improvements to this implementation would be:
// cache pixelMasks for the same filename, to avoid wasting memory (much like CCTextureCache)
// allow pixel mask to be created from a sprite frame
// allow collisions between SD and HD assets (atm pixelMasks must be either both SD or both HD, collision tests return wrong results otherwise)
// allow collisions if one or both sprites are rotated by exactly 90, 180 or 270 degrees

// Possible optimizations:
// reduce pixelMask size by combining the result of 2x2, 3x3, 4x4, etc pixel blocks into a single collision bit
//	such a downscaled pixelMask would still be accurate enough for most use cases but require considerably less memory and is faster to iterate
//	however picking a good algorithm that determines if a bit is set or not can be tricky
// optimizing rectangle test: read multiple bits at once (byte or int), only compare individual bits if value > 0

// Non-trivial improvement:
// move the pixelMask array to CCTexture2D, to avoid loading the same image twice and take advantage of CCTextureCache
// allow pixel perfect collisions if one or both nodes are rotated and/or scaled
//		suggest using the render texture approach instead, as described here: http://www.cocos2d-iphone.org/forum/topic/18522
// for purely "walking over landscape" type of games (think Tiny Wings but with an arbitrarily complex and rugged terrain),
//	the pixelMask could be changed to contain only the pixel height (first pixel from top that's not alpha)
//	That modification should be a separate class, labelled something like KKSpriteWithHeightMask.

/* This is an implementation of masking based on Run-Length Encoding scheme */

@interface RLEPixelMaskSprite : CCSprite

- (void)setPixelMaskForImage:(UIImage *)image withAlphaThreshold:(UInt8)alphaThreshold usingVerticleScan:(BOOL)useVScan;

- (void)setPixelMaskUsingOwnImageWithAlphaThreshold:(UInt8)alphaThreshold usingVerticalScan:(BOOL)useVScan;

- (UIImage *)convertSpriteToImage:(CCSprite *)sprite;


- (void)setPixelMaskForImage:(UIImage *)image withAlphaThreshold:(UInt8)alphaThreshold;

- (NSUInteger)getMirroredIndexForX:(NSUInteger)x y:(NSUInteger)y withWidth:(NSUInteger)width height:(NSUInteger)height;

- (void)setPixelMaskUsingOwnImageWithAlphaThreshold:(UInt8)alphaThreshold;

- (CGRect)intersectionForNodeSpaceInPixels:(CGRect)r1 otherBox:(CGRect)r2;

- (void)setPixelMaskUsingOwnImage;


-(BOOL) pixelMaskContainsPoint:(CGPoint)point;
-(BOOL) pixelMaskIntersectsNode:(CCNode *)other;

@end
