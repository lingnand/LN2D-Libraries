//
// Created by knight on 26/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RLEPixelMaskSprite.h"

@implementation RLEPixelMaskSprite {
    NSUInteger pixelMaskWidth;
    NSUInteger pixelMaskHeight;
    NSUInteger pixelMaskSize;

    BOOL useVerticalScan;
    UInt32 pmLength;
    UInt32 *pixelMaskRunner;
}




// truth being told; I'm not a big fan of implementing complex algorithms, but this time we'll go a bit hardcore and actually implement a few ways of pixel-masking I've actually been thinking about

// the format of the saved array would be something like 0 3 5 8 ...
// this means 0[pixels that are opaque] 3[pixels that are transparent] ...
// the starting point of the scan is always at the bottomleft corner 
// vertical scan just goes up for each column
// horizontal scan just goes from left to right for each row
// usually horizontal scan should be better

- (void)setPixelMaskUsingOwnImageWithAlphaThreshold:(UInt8)alphaThreshold usingVerticalScan:(BOOL)useVScan {
    [self setPixelMaskForImage:[self convertSpriteToImage:self] withAlphaThreshold:alphaThreshold usingVerticleScan:useVScan];
}

- (void)setPixelMaskForImage:(UIImage *)image withAlphaThreshold:(UInt8)alphaThreshold {
    [self setPixelMaskForImage:image withAlphaThreshold:alphaThreshold usingVerticleScan:NO];
}

- (void)setPixelMaskForImage:(UIImage *)image withAlphaThreshold:(UInt8)alphaThreshold usingVerticleScan:(BOOL)useVScan {
    // get all the image information we need
    pixelMaskWidth = (NSUInteger) (CC_CONTENT_SCALE_FACTOR() * [image size].width);
    pixelMaskHeight = (NSUInteger) (CC_CONTENT_SCALE_FACTOR() * [image size].height);
    pixelMaskSize = pixelMaskWidth * pixelMaskHeight;

    useVerticalScan = useVScan;

    // get the pixel data (more correctly: pixels) as 32-Bit unsigned integers
    CGImageRef cgImage = [image CGImage];
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const UInt32 *imagePixels = (const UInt32 *) CFDataGetBytePtr(imageData);


    NSLog(@"image pixel size = %ld", CFDataGetLength(imageData));

    UInt8 alphaValue = 0;

    // going to implement a run-length encoding
    BOOL opaque = YES;
    UInt32 currNPixels = 0;
    NSMutableArray *rleArr = [NSMutableArray array];
    for (NSUInteger i = 0; i < pixelMaskSize; i++) {
        // mask out the colors so that only the alpha value remains (upper 8 bits)
        alphaValue = (UInt8) ((imagePixels[useVerticalScan ?
                        [self getMirroredIndexForX:i/pixelMaskHeight y:i%pixelMaskHeight withWidth:pixelMaskWidth height:pixelMaskHeight]:
                        [self getMirroredIndexForX:i%pixelMaskWidth y:i/pixelMaskWidth withWidth:pixelMaskWidth height:pixelMaskHeight]] & 0xff000000) >> 24);
        if ( opaque ? alphaValue >= alphaThreshold : alphaValue < alphaThreshold ) {
//                CCLOG(@"(%03ld, %03ld) set to opaque:%d; alphavalue = %ld",x, pixelMaskHeight -1 - y,opaque,alpha);
            currNPixels++;
//                NSLog(@"pixel (%ld, %ld) mask set to on", x, y);
        } else {
            // adding the currNPixels into the our nsarray
            [rleArr addObject:[NSNumber numberWithUnsignedInt:currNPixels]];
            currNPixels = 1;
            opaque = !opaque;
        }
    }
    [rleArr addObject:[NSNumber numberWithInt:currNPixels]];
    pmLength = rleArr.count;
    pixelMaskRunner = malloc(pmLength * sizeof(UInt32));
    int i = 0;
    for (NSNumber *n in rleArr) {
        pixelMaskRunner[i++] = n.unsignedIntValue;
    }

    CFRelease(imageData);
}

- (BOOL)pixelMaskContainsPoint:(CGPoint)point {
    NSAssert(pixelMaskRunner, @"pixel mask not set");
    // the point coordinates need to be relative to the node's space
    point = [self convertToNodeSpace:point];
    // upscale point to Retina pixels if necessary
    point = ccpMult(point, CC_CONTENT_SCALE_FACTOR());
    UInt32 dest = [self pathLengthToX:(UInt32) point.x y:(UInt32) point.y];

    UInt32 currl = 0;
    BOOL opaque = YES;
    for (UInt32 i = 0; i < pmLength; i++) {
        currl += (pixelMaskRunner[i]);
        // did I just walk past the point that's supposedToBeChecked?
        if (currl >= dest) {
            return opaque;
        } else
            opaque = !opaque;
    }
    return NO;
}

- (UInt32)pathLengthToX:(UInt32)x y:(UInt32)y {
    return useVerticalScan ? y + x * pixelMaskHeight : x + y * pixelMaskWidth;
}

- (BOOL)pathRunFromLength:(UInt32)l withDistance:(UInt32)distance passesRec:(CGRect)rect {
    return [self pathRunFromPixelPoint:useVerticalScan ? ccp(l/pixelMaskHeight, l%pixelMaskHeight) :ccp(l % pixelMaskWidth, l / pixelMaskWidth) withDistance:distance passesRec:rect];
}

- (BOOL)pathRunFromPixelPoint:(CGPoint)point withDistance:(UInt32)distance passesRec:(CGRect)rect {
    if (CGRectContainsPoint(rect, point)) return YES;
    UInt32 origin = [self pathLengthToX:(UInt32) point.x y:(UInt32) point.y];
    UInt32 dest = origin + distance;
    UInt32 rectLeftBottom = [self pathLengthToX:(UInt32) rect.origin.x y:(UInt32) rect.origin.y];
    UInt32 rectRightTop = [self pathLengthToX:(UInt32) (rect.origin.x + rect.size.width) y:(UInt32) (rect.origin.y + rect.size.height)];
    if (origin < rectLeftBottom) {
        return dest > rectLeftBottom;
    } else if (origin <= rectRightTop) {
        if(useVerticalScan) {
            // point below rect (vertical scan)
            if (point.y < rect.origin.y) return dest >  rect.origin.y + point.x * pixelMaskHeight;
            // point above rect (vertical scan)
            else return dest > rect.origin.y + (point.x + 1) * pixelMaskHeight;
        } else {
            // point on the left of rect (horizontal scan)
            if (point.x < rect.origin.x) return dest > rect.origin.x + point.y * pixelMaskWidth;
            // point on the right of rect
            else return dest > rect.origin.x + (point.y + 1) * pixelMaskWidth;
        }
    }
    return NO;
}

- (BOOL)pixelMaskIntersectsRegularNode:(CCNode *)other {
    CGRect intersectRect = [self intersectionForNodeSpaceInPixels:self.boundingBox otherBox:other.boundingBox];

    UInt32 currl = 0;
    BOOL opaque = YES;
    for (UInt32 i = 0; i < pmLength; i++) {
        // did I just walk past the point that's supposedToBeChecked?
        if (opaque && [self pathRunFromLength:currl withDistance:pixelMaskRunner[i] passesRec:intersectRect]) {
            return YES;
        } else
            opaque = !opaque;
        currl += (pixelMaskRunner[i]);
    }
    return NO;
}

- (BOOL)pixelMaskIntersectsNode:(CCNode *)other {
    NSAssert(pixelMaskRunner, @"pixel mask not set");
//    if (rotation_ != 0.0f || other.rotation != 0.0f || self.scale != 1.0f || other.scale != 1.0f) {
//        CCLOG(@"pixelMaskIntersectsNode: either or both nodes are rotated and/or scaled. This test only works with non-rotated, non-scaled nodes.");
//        return NO;
//    }
//
//    // no point in testing further if bounding boxes don't intersect
//    if ([self kkIntersectsNode:other]) {
//        return [self pixelMaskIntersectsRegularNode:other];
//    }

    return NO;
}


- (void)dealloc {
    if (pixelMaskRunner) {
        free(pixelMaskRunner);
        pixelMaskRunner = nil;
    }
}

- (UIImage *)convertSpriteToImage:(CCSprite *)sprite {
    CGPoint p = sprite.anchorPoint;
    [sprite setAnchorPoint:ccp(0, 0)];

    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:(int) sprite.contentSize.width height:(int) sprite.contentSize.height];

    [renderer begin];
    [sprite visit];
    [renderer end];

    [sprite setAnchorPoint:p];
    UIImage *image = renderer.getUIImage;
    return image;
}


- (CGRect)intersectionForNodeSpaceInPixels:(CGRect)r1 otherBox:(CGRect)r2 {

    CGRect intersectRect = CGRectIntersection(r1, r2);

    // transform the intersection rect to the sprite's space and convert points to pixels
    intersectRect.origin = [self convertToNodeSpace:intersectRect.origin];
    return CC_RECT_POINTS_TO_PIXELS(intersectRect);
}

- (void)setPixelMaskUsingOwnImage {
    [self setPixelMaskUsingOwnImageWithAlphaThreshold:200];
}

- (void)setPixelMaskUsingOwnImageWithAlphaThreshold:(UInt8)alphaThreshold {
    [self setPixelMaskWithSprite:self withAlphaThreshold:alphaThreshold];
}

-(void)setPixelMaskWithSprite:(CCSprite *)sprite withAlphaThreshold:(UInt8)alphaThreshold {
    [self setPixelMaskForImage:[self convertSpriteToImage:sprite] withAlphaThreshold:alphaThreshold];
}

- (NSUInteger)getMirroredIndexForX:(NSUInteger)x y:(NSUInteger)y withWidth:(NSUInteger)width height:(NSUInteger)height{
    return x + width * (height - 1 - y);
}

@end