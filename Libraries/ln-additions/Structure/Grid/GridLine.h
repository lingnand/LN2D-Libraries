//
// Created by Lingnan Dai on 4/29/13.
//

#import "CCNode+GridCell.h"
#import "Mask.h"

@class GridGroup;
@class GridLine;
@class CompositeMask;
@class Mask;


@interface GridLine : NSObject <NSFastEnumeration, Masked>

// when you set the width, it will follow the following rule
// if width>=0, width will be set to the value and the line's dynamicity is changed to false
// if width<0, width will be set to the defaultWidth, and dynamicity is changed to true
@property(nonatomic) CGFloat width;
@property (nonatomic, weak) GridGroup *group;
@property(nonatomic) CGFloat position;
@property(nonatomic) GridDimension type;
@property(nonatomic) NSUInteger index;
// default dynamicity of the line
@property(nonatomic) BOOL dynamic;
// default mask
@property(nonatomic, strong) Mask *mask;


/** @group Line creation */

+ (id)lineWithWidth:(CGFloat)width;

+ (id)lineWithWidth:(CGFloat)width cell:(GridCell *)cell;

+ (id)lineWithWidth:(CGFloat)width cells:(GridCell *)firstCell, ...;

+ (id)dynamicLine;

+ (id)dynamicLineWithCell:(GridCell *)cell;

+ (id)dynamicLineWithCells:(GridCell *)firstCell, ...;

+ (id)rowWithWidth:(CGFloat)width;

+ (id)rowWithWidth:(CGFloat)width cell:(GridCell *)cell;

+ (id)rowWithWidth:(CGFloat)width cells:(GridCell *)firstCell, ...;

+ (id)dynamicRow;

+ (id)dynamicRowWithCell:(GridCell *)cell;

+ (id)dynamicRowWithCells:(GridCell *)firstCell, ...;

+ (id)columnWithWidth:(CGFloat)width;

+ (id)columnWithWidth:(CGFloat)width cell:(GridCell *)cell;

+ (id)columnWithWidth:(CGFloat)width cells:(GridCell *)firstCell, ...;

+ (id)dynamicColumn;

+ (id)dynamicColumnWithCell:(GridCell *)cell;

+ (id)dynamicColumnWithCells:(GridCell *)firstCell, ...;

/** @group Querying a line */

- (NSUInteger)count;

- (GridCell *)objectAtIndexedSubscript:(NSUInteger)index1;

- (NSUInteger)minNonEmptyIndex;

- (NSUInteger)maxNonEmptyIndex;

- (GridCell *)lastCell;

/** @group Replacing cells */

- (void)setObject:(GridCell *)obj atIndexedSubscript:(NSUInteger)index1;

- (void)setCell:(GridCell *)cell atIndex:(NSUInteger)index1;

/** @group Adding cells */

- (void)addCell:(GridCell *)cell;

- (void)insertCell:(GridCell *)cell atIndex:(NSUInteger)index1;

/** @group Removing cells */

- (void)removeLastCell;

- (void)removeCellAtIndex:(NSUInteger)index1;

/** @group Sending messages */

- (void)enumerateCellsUsingBlock:(void (^)(GridCell *cell, NSUInteger idx, BOOL *stop))block;

/** @group Delegate methods */

- (CGFloat)gridWidthWithCell:(GridCell *)cell;

- (void)updateColWidthFromOldWidth:(CGFloat)oldWidth toNewWidth:(CGFloat)newWidth;

/** @group Helper methods (only meant to be used by Grid family) */

- (void)oneSideSetCell:(GridCell *)cell atIndex:(NSUInteger)index1;

- (void)oneSideInsertCell:(GridCell *)cell atIndex:(NSUInteger)index1;

- (void)oneSideRemoveCellAtIndex:(NSUInteger)index1;

- (CGFloat)defaultWidth;

- (BOOL)updateDrawingInParent;


@end
