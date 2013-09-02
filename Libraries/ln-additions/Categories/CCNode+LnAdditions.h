//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCNode.h"

@class Body;
@class CCComponent;


@interface CCNode (LnAdditions)

+ (id)nodeWithRootComponent:(CCComponent *)comp;

/** @group Queries */
- (BOOL)fullyOutsideScreen;

-(BOOL)fullyInsideScreen;

- (CGFloat)minXEdgePosition;

- (CGFloat)maxXEdgePosition;

- (CGFloat)minYEdgePosition;

- (CGFloat)maxYEdgePosition;

-(CGSize)winSize;

- (void)addChildren:(id <NSFastEnumeration>)children;

/**
    This is the union of all the space measured in the CURRENT NODE space
    It takes care
    1. the space taken by the children
    2. scale and rotate

    The unionBox (and also its siblings) is especially useful for computation
    involving what 'looks like' on screen.
*/
- (CGRect)unionBox;

/** The unionBox measured in the absolute world */
- (CGRect)unionBoxInWorld;

/** The unionBox measured in the parent space */
- (CGRect)unionBoxInParent;

/** @group Operations */
- (void)flipInnerX;

- (void)flipInnerY;

/** @group Subscript child manipulation */
- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCNode *)node atIndexedSubscript:(NSInteger)tag;

- (CGPoint)anchorPointFromDeltaPoint:(CGPoint)delta;

- (BOOL)isAscendantOfNode:(CCNode *)node;

- (BOOL)isDescendantOfNode:(CCNode *)node;

- (BOOL)isOnLineageOfNode:(CCNode *)node;

/** return all the ancestors and all the posterity of this node */
- (NSArray *)allLineages;

/** return all the ancestors of this node */
- (NSArray *)allAscendants;

/** return all the posterity of this node */
- (NSArray *)allDescendants;

/** @group Curries */
- (id)nodeWithAnchorPoint:(CGPoint)anchor;

/** @group Component */
@property (nonatomic, strong) CCComponent *rootComponent;

/** @group Body */
@property(nonatomic) Body *body;

@end