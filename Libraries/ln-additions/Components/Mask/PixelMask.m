//
// Created by knight on 30/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponent.h"
#import "PixelMask.h"
#import "CCNode+LnAdditions.h"
#import "PixelMaskData.h"


@implementation PixelMask

- (id)initWithData:(PixelMaskData *)maskData {
    self = [super init];
    if (self) {
        self.maskData = maskData;
    }
    return self;
}

+ (id)maskWithData:(PixelMaskData *)maskData {
    return [[self alloc] initWithData:maskData];
}


- (BOOL)contains:(CGPoint)point {
    if (![super contains:point] || !self.maskData) return NO;
    point = ccpSub(CC_POINT_POINTS_TO_PIXELS(CGPointApplyAffineTransform(point, self.body.worldToHostTransform)), self.maskData.window.origin);
    return (BOOL) CFBitVectorGetBitAtIndex(self.maskData.bitset, (CFIndex) (point.x + point.y * self.maskData.window.size.width));
}

- (BOOL)intersectsOneSide:(Mask *)other {
    if (![super intersectsOneSide:other] || !self.maskData) return NO;
    BodilyMask *obm = (BodilyMask *) other;

    // we will first convert both rects into world space (as this is the definite common point of the two nodes)
    CGAffineTransform hostToWorldTransform = self.body.hostToWorldTransform;
    CGRect windowInWorldSpace = CGRectApplyAffineTransform(CC_RECT_PIXELS_TO_POINTS(self.maskData.window), hostToWorldTransform);
    CGAffineTransform otherhostToWorldTransform = obm.body.hostToWorldTransform;
    CGRect otherBBInWorldSpace = CGRectApplyAffineTransform(obm.body.host.unionBox, otherhostToWorldTransform);;
    CGRect intersectionInWorld = CGRectIntersection(windowInWorldSpace, otherBBInWorldSpace);
    CGRect intersectionInHost = CC_RECT_POINTS_TO_PIXELS(CGRectApplyAffineTransform(intersectionInWorld, CGAffineTransformInvert(hostToWorldTransform)));
    // no point in testing further if bounding boxes don't intersect
    if (intersectionInHost.size.width == 0)
        return NO;
    if ([other isKindOfClass:self.class]) {
        // get the bitset of the other node
        PixelMask *bms = (PixelMask *) other;

        CGRect intersectionInOtherhost = CC_RECT_POINTS_TO_PIXELS(CGRectApplyAffineTransform(intersectionInWorld, CGAffineTransformInvert(otherhostToWorldTransform)));
        UInt32 length = (UInt32) ((intersectionInHost.size.width + 8)/8 * 8);
        UInt8 *buf = malloc(length), *buf2 = malloc(length);
        memset(buf, 0, length);
        memset(buf2, 0, length);

        // just check line by line down
        for (NSUInteger this_y = (NSUInteger) CGRectGetMinY(intersectionInHost), that_y = (NSUInteger) CGRectGetMinY(intersectionInOtherhost); this_y < CGRectGetMaxY(intersectionInHost); this_y++, that_y++) {
            CFBitVectorGetBits(self.maskData.bitset, CFRangeMake((CFIndex) (intersectionInHost.origin.x + self.maskData.window.size.width * this_y), (CFIndex) intersectionInHost.size.width), buf);
            CFBitVectorGetBits(bms.maskData.bitset, CFRangeMake((CFIndex) (intersectionInOtherhost.origin.x + bms.maskData.window.size.width * that_y), (CFIndex) intersectionInOtherhost.size.width), buf2);
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
        NSAssert(intersectionInHost.origin.x >= 0 && intersectionInHost.origin.y >= 0, @"Intersection box has negative coordinates! (%f, %f)", intersectionInHost.origin.x, intersectionInHost.origin.y);

        // for each row just iterate through and check if there's any point
        for (NSUInteger y = (NSUInteger) CGRectGetMinY(intersectionInHost); y < CGRectGetMaxY(intersectionInHost); y++) {
            if (CFBitVectorContainsBit(self.maskData.bitset, CFRangeMake((CFIndex) (intersectionInHost.origin.x + self.maskData.window.size.width * y), (CFIndex) intersectionInHost.size.width), 1))
                return YES;
        }
        return NO;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    PixelMask *copy = (PixelMask *)[super copyWithZone:zone];

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