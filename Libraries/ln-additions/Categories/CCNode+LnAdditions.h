//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponentManager.h"
#import "Mask.h"
#import "SimpleBody.h"
#import "CCNode.h"


@interface CCNode (LnAdditions) <Masked>

+ (id)nodeWithComponentManager:(CCComponentManager *)manager;

/** @group Queries */
- (BOOL)fullyOutsideScreen;

-(BOOL)fullyInsideScreen;

- (CGFloat)minXEdgePosition;

- (CGFloat)maxXEdgePosition;

- (CGFloat)minYEdgePosition;

- (CGFloat)maxYEdgePosition;

-(CGSize)winSize;

- (CGRect)rectInWorldSpace:(CGRect)rect;

- (void)addChildren:(id <NSFastEnumeration>)children;

/**
    This is the rect of the node measured in the WORLD coordinate.
    It takes care
    1. the space taken by the children
    2. scale and rotate

    The canvasBox (and also its sibling canvasSize) is especially useful for computation
    involving what 'looks like' on screen. Using a world coordinate means that nodes in
    different groups and structures can access the their relative positions and this is
    a vital need for uses such as Mask calculation.
*/
- (CGRect)canvasBox;

/**
    Used primarily to compute the total size of the current node including its children
*/
- (CGSize)canvasSize;

/** @group Operations */
- (void)flipInnerX;

- (void)flipInnerY;

/** @group Subscript child manipulation */
- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCNode *)node atIndexedSubscript:(NSInteger)tag;

- (CGPoint)anchorPointFromDeltaPoint:(CGPoint)delta;

/** @group Curries */
- (id)nodeWithAnchorPoint:(CGPoint)anchor;

/** @group Components */
@property (nonatomic, strong) CCComponentManager *componentManager;

/** @group Mask */
@property(nonatomic, strong) Mask *mask;

/** @group Body */
@property(nonatomic) Body *body;

/** @group Position */
/** change the position of the node (note this is the original method implemented by cocos2d */
@property(nonatomic) CGPoint nodePosition;

@end