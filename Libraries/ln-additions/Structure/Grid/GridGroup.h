//
// Created by Lingnan Dai on 4/29/13.
//


#import "GridLine.h"

@class GridNode;
@class CompositeMask;

@interface GridGroup : NSObject <NSFastEnumeration, Masked>

@property(nonatomic) GridDimension type;
@property(nonatomic) CGFloat gap;
@property (nonatomic, weak) GridNode *grid;
@property (nonatomic, readonly) CGFloat width;
@property(nonatomic, strong) Mask *mask;

/** @group Group creation */

+ (id)groupWithType:(GridDimension)type gap:(CGFloat)gap;

+ (id)groupWithGap:(CGFloat)gap;

+ (id)groupWithGap:(CGFloat)gap lines:(GridLine *)firstLine, ...;

+ (id)groupWithGap:(CGFloat)gap line:(GridLine *)line;

+ (id)rowsWithGap:(CGFloat)gap;

+ (id)rowsWithGap:(CGFloat)gap line:(GridLine *)line;

+ (id)rowsWithGap:(CGFloat)gap lines:(GridLine *)firstLine, ...;

+ (id)columnsWithGap:(CGFloat)gap;

+ (id)columnsWithGap:(CGFloat)gap line:(GridLine *)line;

+ (id)columnsWithGap:(CGFloat)gap lines:(GridLine *)firstLine, ...;

/** @group Querying a group */

- (GridLine *)objectAtIndexedSubscript:(NSUInteger)line;

/** @group Adding lines or groups */

- (void)addLine:(GridLine *)line;

- (void)insertLine:(GridLine *)line atIndex:(NSUInteger)index1;

- (void)insertGroup:(GridGroup *)group atIndex:(NSUInteger)index1;

- (void)addGroup:(GridGroup *)group;

/** @group Replacing lines */

- (void)setLine:(GridLine *)line atIndex:(NSUInteger)index1;

- (void)setObject:(GridLine *)line atIndexedSubscript:(NSUInteger)index;

/** @group Removing lines */

- (GridLine *)cutFirst;

- (void)removeLine:(GridLine *)line;

- (void)removeLineAtIndex:(NSUInteger)index;

- (void)removeLastLine;

/** @group Helper methods */

- (void)shiftLinesAtIndexesStarting:(NSUInteger)index1 byDelta:(CGFloat)delta;

/** @group Delegate methods */

- (GridGroup *)reciproGroup;

- (CGFloat)defaultLineWidth;

- (void)lineAtIndex:(NSUInteger)index1 widthChangedFrom:(CGFloat)oldWidth newWidth:(CGFloat)newWidth;

- (NSUInteger)count;

@end
