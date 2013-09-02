//
// Created by knight on 29/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCDirector.h"

#define SIGN(A) (A < 0 ? -1 : (A ==0 ? 0: 1))

#define ARC4RANDOM_MAX 0x100000000
#define ARC4RANDOM_MAX_INCLUSIVE 0xFFFFFFFFu

#pragma mark - Scalar definitions
typedef struct {
    CGFloat location;
    CGFloat length;
} CGRange;

NS_INLINE

NSString * NSStringFromCGRange(CGRange range) {
    return [NSString stringWithFormat:@"{%f,%f}", range.location, range.length];
}

#pragma mark - Random generators

NS_INLINE

double randomDouble() {
    return (double) arc4random() / ARC4RANDOM_MAX;
}

/* this returns from 0 to 1 inclusive */
NS_INLINE

double randomDoubleInclusive() {
    return (double) arc4random() / ARC4RANDOM_MAX_INCLUSIVE;
}


/* low inclusive, high not inclusive*/
NS_INLINE

double randomDoubleInBounds(double low, double high) {
    return randomDouble() * (high - low) + low;
}

NS_INLINE

double randomDoubleInBoundsInclusive(double low, double high_inclusive) {
    return randomDoubleInclusive() * (high_inclusive - low) + low;
}

NS_INLINE

int randomIntInBounds(int low, int high) {
    return ((int) (randomDouble() * (high - low))) + low;
}

NS_INLINE

int randomIntInBoundsInclusive(int low, int high_inclusive) {
    return randomIntInBounds(low, high_inclusive + 1);
}

/* excluding the high */
NS_INLINE

int randomInt(int high) {
    return randomIntInBounds(0, high);
}

NS_INLINE

CGRect CGRectFromRatioRect(CGRect posRatioRect) {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    return CGRectMake(posRatioRect.origin.x * winSize.width, posRatioRect.origin.y * winSize.height, posRatioRect.size.width * winSize.width, posRatioRect.size.height * winSize.height);
}


NS_INLINE

CGPoint ccpMagnitude(CGPoint point) {
    return ccp(ABS(point.x), ABS(point.y));
}

NS_INLINE

CGPoint ccpDirection(CGPoint point) {
    return ccp(SIGN(point.x), SIGN(point.y));
}

NS_INLINE

CGPoint ccpFromRatio(CGPoint ratio) {
    return ccp(ratio.x * [CCDirector sharedDirector].winSize.width, ratio.y * [CCDirector sharedDirector].winSize.height);
}

#pragma mark - Vector and affine-related transformations

/** The basic idea is that we apply the transform to the begin and end points and take the subtraction */
NS_INLINE

CGPoint CGPointVectorApplyAffineTransform(CGPoint vector, CGAffineTransform t) {
    CGPoint orig =  CGPointApplyAffineTransform(CGPointZero, t);
    CGPoint dest =  CGPointApplyAffineTransform(vector, t);
    return ccpSub(dest, orig);
}

#pragma mark - Block definitions

#define BLOCK_SAFE_RUN(block, ...) {if (block) block(__VA_ARGS__);}
