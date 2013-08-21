//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCNode+LnAdditions.h"
#import "RectMask.h"
#import <objc/runtime.h>

// dynamically access the components array
static char const *const nodeComponentKitKey = "CCNodeExtension.CCCompoonentKit";
static char const *const nodeDataKey = "CCNodeExtension.UserData";

@implementation CCNode (LnAdditions)
@dynamic components;
@dynamic mask;
@dynamic body;

#pragma mark - Normal extension

- (BOOL)fullyOutsideScreen {
    CGPoint worldCoord = [self.parent convertToWorldSpace:self.position];
    return worldCoord.x + (1 - self.anchorPoint.x) * self.contentSize.width < 0 || worldCoord.x - self.anchorPoint.x * self.contentSize.width > [CCDirector sharedDirector].winSize.width
            || worldCoord.y + (1 - self.anchorPoint.y) * self.contentSize.height < 0 || worldCoord.y - self.anchorPoint.y * self.contentSize.height > [CCDirector sharedDirector].winSize.height;
}

- (BOOL)fullyInsideScreen {
    CGPoint worldCoord = [self.parent convertToWorldSpace:self.position];
    return worldCoord.x - self.anchorPoint.x * self.contentSize.width >= 0 && worldCoord.x + (1 - self.anchorPoint.x) * self.contentSize.width <= [CCDirector sharedDirector].winSize.width
            && worldCoord.y - self.anchorPoint.y * self.contentSize.height >= 0 && worldCoord.y + (1 - self.anchorPoint.y) * self.contentSize.height <= [CCDirector sharedDirector].winSize.height;
}

- (CGFloat)minXEdgePosition {
    return self.position.x - self.contentSize.width * self.anchorPoint.x;
}

- (CGFloat)maxXEdgePosition {
    return self.position.x + self.contentSize.width * (1 - self.anchorPoint.x);
}

- (CGFloat)minYEdgePosition {
    return self.position.y - self.contentSize.height * self.anchorPoint.y;
}

- (CGFloat)maxYEdgePosition {
    return self.position.y + self.contentSize.height * (1 - self.anchorPoint.y);
}

- (CGSize)winSize {
    return [CCDirector sharedDirector].winSize;
}

- (id)objectAtIndexedSubscript:(NSInteger)tag {
    return [self getChildByTag:tag];
}

- (void)setObject:(CCNode *)node atIndexedSubscript:(NSInteger)tag {
    [self addChild:node z:0 tag:tag];
}

#pragma mark - Anchor point related operations

/**
* This method will return the new anchor point calculated from traversing
* from the current anchor point by the 'delta' amount of point
* The size of the node is measured by the contentSize
* That's why this method might only be useful if the content size is defined
*/
- (CGPoint)anchorPointFromDeltaPoint:(CGPoint)delta {
    CGFloat width = self.contentSize.width;
    CGFloat height = self.contentSize.height;
    return ccpAdd(self.anchorPoint,
            ccp(width ? delta.x/ width : 0, height ? delta.y/ height : 0));
}

#pragma mark - Operations
// chained methods
-(id)nodeWithAnchorPoint:(CGPoint)anchor {
    self.anchorPoint = anchor;
    return self;
}

// return a sprite with flipped
-(void)flipInnerX {
    self.scaleX *= -1;
    CGPoint an = self.anchorPoint;
    // the anchorPoint should reflect about an.x = 0.5
    an.x = 1 - an.x;
    self.anchorPoint = an;
}

-(void)flipInnerY {
    self.scaleY *= -1;
    CGPoint an = self.anchorPoint;
    // the anchorPoint should reflect about an.x = 0.5
    an.y = 1 - an.y;
    self.anchorPoint = an;
}

#pragma mark - Worldspace size calculation

- (CGRect)canvasBox {
    CGRect canvas = [self rectInWorldSpace:(CGRect){{0, 0}, self.contentSize}];
    for (CCNode *node in self.children) {
        canvas = CGRectUnion(canvas, node.canvasBox);
    }
    return canvas;
}

- (CGSize)canvasSize {
    return self.canvasBox.size;
}

- (NSSet *)keyPathsForValuesAffectingCanvasBox:(NSString *)key {
    return [NSSet setWithObjects:@"scaleX",@"scaleY",@"anchorPoint", @"children", @"contentSize", nil];
}

- (NSSet *)keyPathsForValuesAffectingCanvasSize:(NSString *)key {
    return [NSSet setWithObject:@"canvasBox"];
}


#pragma mark - Components

- (CCComponentKit *)components {
    CCComponentKit *components = objc_getAssociatedObject(self, nodeComponentKitKey);
    // lazy instantiation
    if (!components) {
        components = [[CCComponentKit alloc] init];
        self.components = components;
    }
    return components;
}

- (void)setComponents:(CCComponentKit *)components {
    [components setDelegate:self];
    objc_setAssociatedObject(self, nodeComponentKitKey, components, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.components;
}

#pragma mark - Body

// default returns a normal body
- (id)body {
    Body *m = [self.components componentForClass:[Body class]];
    if (!m) {
        m = [SimpleBody body];
        self.body = m;
    }
    return m;
}

- (void)setBody:(Body *)body {
    [self.components setComponent:body forClassLock:[Body class]];
}

// velocity is the one thing that should be supported across bodies
- (CGPoint)velocity {
    return self.body.velocity;
}

- (void)setVelocity:(CGPoint)velocity {
    self.body.velocity = velocity;
}

#pragma mark - Mask

// defualt returns a rectMask
- (Mask *)mask {
    // lazily instantiate
    Mask *m = [self.components componentForClass:[Mask class]];
    if (!m) {
        m = [RectMask mask];
        self.mask = m;
    }
    return m;
}

- (void)setMask:(Mask *)mask {
    [self.components setComponent:mask forClassLock:[Mask class]];
}

/** converting a rect in the current nodespace to the world nodespace */
- (CGRect)rectInWorldSpace:(CGRect)rect {
    return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}


@end