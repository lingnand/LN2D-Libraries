//
// Created by knight on 30/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponent.h"
#import "BitMask.h"
#import "CCNode+LnAdditions.h"
#import "BitMaskData.h"


@interface BitMask ()
@property (nonatomic, strong) BitMaskData *maskData;
@end

@implementation BitMask

- (id)initWithData:(BitMaskData *)maskData {
    self = [super init];
    if (self) {
        self.maskData = maskData;
    }
    return self;
}

+ (id)maskWithData:(BitMaskData *)maskData {
    return [[self alloc] initWithData:maskData];
}


- (BOOL)contains:(CGPoint)point {
    if (!self.delegate) return NO;
    point = ccpSub(CC_POINT_POINTS_TO_PIXELS([self.delegate convertToNodeSpace:point]), self.maskData.window.origin);
    return (BOOL) CFBitVectorGetBitAtIndex(self.maskData.bitset, (CFIndex) (point.x + point.y * self.maskData.window.size.width));
}

- (BOOL)intersectsOneSide:(Mask *)other {
//    if (other.rotation != 0.0f || delegate.rotation != 0.0f || other.scale != 1.0f || delegate.scale != 1.0f) {
//        CCLOG(@"pixelMaskIntersectsNode: either or both nodes are rotated and/or scaled. This test only works with non-rotated, non-scaled nodes.");
//        return NO;
//    }
    if (!self.delegate) return NO;

    CGRect windowInWorldSpace = [self.delegate rectInWorldSpace:CC_RECT_PIXELS_TO_POINTS(self.maskData.window)];
    CGRect otherBBInWorldSpace = other.delegate.canvasBox;
    CGRect this_inter = [self intersectionInWindowSpaceOfNode:self.delegate r1:windowInWorldSpace r2:otherBBInWorldSpace];
    // no point in testing further if bounding boxes don't intersect
    if (this_inter.size.width == 0)
        return NO;
    if ([other isKindOfClass:self.class]) {
        // get the bitset of the other node
        BitMask *bms = (BitMask *) other;

        CGRect that_inter = [bms intersectionInWindowSpaceOfNode:other.delegate r1:windowInWorldSpace r2:otherBBInWorldSpace];
        UInt32 length = (UInt32) ((this_inter.size.width + 8)/8 * 8);
        UInt8 *buf = malloc(length), *buf2 = malloc(length);
        memset(buf, 0, length);
        memset(buf2, 0, length);

        // just check line by line down
        for (NSUInteger this_y = (NSUInteger) CGRectGetMinY(this_inter), that_y = (NSUInteger) CGRectGetMinY(that_inter); this_y < CGRectGetMaxY(this_inter); this_y++, that_y++) {
            CFBitVectorGetBits(self.maskData.bitset, CFRangeMake((CFIndex) (this_inter.origin.x + self.maskData.window.size.width * this_y), (CFIndex) this_inter.size.width), buf);
            CFBitVectorGetBits(bms.maskData.bitset, CFRangeMake((CFIndex) (that_inter.origin.x + bms.maskData.window.size.width * that_y), (CFIndex) that_inter.size.width), buf2);
            for (UInt32 i = 0; i < length / 8 ; i++) {
                if ((buf[i] & buf2[i]) > 0) {
                    free(buf);
                    free(buf2);
                    return YES;
                }
            }
        }
        free(buf);
        free(buf2);
        return NO;

    } else {
        NSAssert(this_inter.origin.x >= 0 && this_inter.origin.y >= 0, @"Intersection box has negative coordinates! (%f, %f)", this_inter.origin.x, this_inter.origin.y);

        // for each row just iterate through and check if there's any point
        for (NSUInteger y = (NSUInteger) CGRectGetMinY(this_inter); y < CGRectGetMaxY(this_inter); y++) {
            if (CFBitVectorContainsBit(self.maskData.bitset, CFRangeMake((CFIndex) (this_inter.origin.x + self.maskData.window.size.width * y), (CFIndex) this_inter.size.width), 1))
                return YES;
        }
        return NO;
    }
}

// box argument should be wrt. world space; the returned value is in pixels
- (CGRect)intersectionInWindowSpaceOfNode:(CCNode *)node r1:(CGRect)r1 r2:(CGRect)r2 {
    // intersection as viewed from the world space
    CGRect intersection = CGRectIntersection(r1, r2);
    // convert the intersection back to node coordinate
    CGRect intersectionWithinDelegate = CGRectApplyAffineTransform(intersection, [node worldToNodeTransform]);
    // finally convert the coordinates into window space
    intersectionWithinDelegate.origin = ccpSub(intersectionWithinDelegate.origin, self.maskData.window.origin);
    return CC_RECT_POINTS_TO_PIXELS(intersectionWithinDelegate);
}

- (id)copyWithZone:(NSZone *)zone {
    BitMask *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.maskData = self.maskData;
    }

    return copy;
}

- (MaskIntersectComplexity)complexity {
    return ComplexityHigh;
}

- (MaskIntersectPolicy)intersectPolicy {
    return IntersectAND;
}


@end