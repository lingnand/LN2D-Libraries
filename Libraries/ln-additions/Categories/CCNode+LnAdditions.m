//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCNode+LnAdditions.h"
#import "JRSwizzle.h"
#import "NodalMask.h"
#import <objc/runtime.h>

// dynamically access the components array
static char const *const nodeComponentKitKey = "CCNodeExtension.CCCompoonentKit";

@implementation CCNode (LnAdditions)
@dynamic componentManager;
@dynamic mask;
@dynamic body;

#pragma mark - More initializer

+ (id)nodeWithComponentManager:(CCComponentManager *)manager {
    CCNode *n = [self new];
    n.componentManager = manager;
    return n;
}

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
            ccp(width ? delta.x / width : 0, height ? delta.y / height : 0));
}

#pragma mark - Operations

- (BOOL)isAscendantOfNode:(CCNode *)node {
    if (node == self)
        return NO;
    CCNode *p;
    while ((p = node.parent)) {
        if (p == self)
            return YES;
    }
    return NO;
}

- (BOOL)isDescendantOfNode:(CCNode *)node {
    return [node isAscendantOfNode:self];
}

- (BOOL)isOnLineageOfNode:(CCNode *)node {
    return node == self || [self isAscendantOfNode:node] || [self isDescendantOfNode:node];
}

/** return all the nodes on this lineage */
- (NSArray *)allLineages {
    NSMutableArray *arr = [NSMutableArray array];
    // get all the parents first
    CCNode *n = self;
    do
        [arr addObject:n];
    while ((n = n.parent));
    // add all the children
    return [arr arrayByAddingObjectsFromArray:self.allDescendants];
}

-(NSArray *)allAscendants {
    NSMutableArray *arr = [NSMutableArray array];
    CCNode *n = self;
    while ((n = n.parent)) {
        [arr addObject:n];
    }
    return arr;
}

- (NSArray *)allDescendants {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObjectsFromArray:self.children.getNSArray];
    for (CCNode *c in self.children) {
        [arr addObjectsFromArray:c.allDescendants];
    }
    return arr;
}

// chained methods
- (id)nodeWithAnchorPoint:(CGPoint)anchor {
    self.anchorPoint = anchor;
    return self;
}

// return a sprite with flipped
- (void)flipInnerX {
    self.scaleX *= -1;
    CGPoint an = self.anchorPoint;
    // the anchorPoint should reflect about an.x = 0.5
    an.x = 1 - an.x;
    self.anchorPoint = an;
}

- (void)flipInnerY {
    self.scaleY *= -1;
    CGPoint an = self.anchorPoint;
    // the anchorPoint should reflect about an.x = 0.5
    an.y = 1 - an.y;
    self.anchorPoint = an;
}

- (void)addChildren:(id<NSFastEnumeration>)children {
    for (CCNode *c in children)
        [self addChild:c];
}

#pragma mark - Worldspace size calculation

// we should really return the box measured at this level / in the coordinates system of this
// node. In other words, how large is the node as measured in the current space..?
- (CGRect)unionBox {
    CGRect un = (CGRect) {{0, 0}, self.contentSize};
    for (CCNode *node in self.children) {
        // we have to be careful about the anchor points as well
        un = CGRectUnion(un, CGRectApplyAffineTransform(node.unionBox, node.nodeToParentTransform));
    }
    // we obtain the rect
    // note that this rect might not only include the rect of the subnodes in the first
    // quadron. In fact, it's the union of all the node's size in this coordinate system
    return un;
}

// the unioned boundingBox in the world coordinates
- (CGRect)unionBoxInWorld {
    return CGRectApplyAffineTransform(self.unionBox, self.nodeToWorldTransform);
}

// this is the unioned space viewed in the parent space
- (CGRect)unionBoxInParent {
    return CGRectApplyAffineTransform(self.unionBox, self.nodeToParentTransform);
}

- (CGRect)canvasBox {
    CGRect canvas = [self rectInWorldSpace:(CGRect) {{0, 0}, self.contentSize}];
    for (CCNode *node in self.children) {
        canvas = CGRectUnion(canvas, node.canvasBox);
    }
    return canvas;
}

- (CGSize)canvasSize {
    return self.canvasBox.size;
}

- (NSSet *)keyPathsForValuesAffectingCanvasBox:(NSString *)key {
    return [NSSet setWithObjects:@"scaleX", @"scaleY", @"anchorPoint", @"children", @"contentSize", nil];
}

- (NSSet *)keyPathsForValuesAffectingCanvasSize:(NSString *)key {
    return [NSSet setWithObject:@"canvasBox"];
}


#pragma mark - Components

- (CCComponentManager *)componentManager {
    CCComponentManager *components = objc_getAssociatedObject(self, nodeComponentKitKey);
    // lazy instantiation
    if (!components) {
        components = [[CCComponentManager alloc] init];
        self.componentManager = components;
    }
    return components;
}

- (void)setComponentManager:(CCComponentManager *)componentManager {
    componentManager.delegate = self;
    objc_setAssociatedObject(self, nodeComponentKitKey, componentManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.componentManager;
}

#pragma mark - Body

// default returns a simplebody
- (Body *)body {
    Body *m = [self.componentManager componentForClass:[Body class]];
    if (!m)
        self.body = m = [Body body];
    return m;
}

- (void)setBody:(Body *)body {
    [self.componentManager setComponent:body forClassLock:[Body class]];
}

#pragma mark - Mask

- (BodilyMask *)mask {
    Body *b = self.body;
    if ([b isKindOfClass:[SimpleBody class]])
        return ((SimpleBody *)b).mask;
    return nil;
}

- (void)setMask:(BodilyMask *)mask {
    // get the body and set the mask
    Body *b = self.body;
    if ([b isKindOfClass:[SimpleBody class]])
        ((SimpleBody *)b).mask = mask;
}

/** converting a rect in the current nodespace to the world nodespace */
- (CGRect)rectInWorldSpace:(CGRect)rect {
    return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

#pragma mark - Position overriding

- (void)setNodePosition:(CGPoint)nodePosition {
    self.body.position = nodePosition;
}

- (CGPoint)nodePosition {
    return self.body.position;
}

+ (void)load {
    if (self.class == [CCNode class]) {
        [self jr_swizzleMethod:@selector(position) withMethod:@selector(nodePosition) error:nil];
        [self jr_swizzleMethod:@selector(setPosition:) withMethod:@selector(setNodePosition:) error:nil];
    }
}


@end