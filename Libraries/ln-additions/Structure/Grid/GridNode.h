//
// Created by Lingnan Dai on 22/04/2013.
//


#import "GridGroup.h"

@interface GridNode : CCNode <NSFastEnumeration>

@property(nonatomic) GridGroup *rows;
@property(nonatomic) GridGroup *cols;
/** dimension would be 2 for the current implementation, but it can have more dimensions if needed */
@property(nonatomic, readonly) NSUInteger dimension;
@property(nonatomic) CGFloat gap;
@property (nonatomic) CGPoint origin;
// originPosition is the position of the origin with regard to the parent of gridNode
@property (nonatomic, readonly) CGPoint absoluteOrigin;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

/** @group Creating grid */

+ (id)gridWithGap:(CGFloat)gap;

+ (id)gridWithGroup:(GridGroup *)group;

/** @group Initializing a grid */

- (id)initWithGap:(CGFloat)gap;

/** @group Querying a grid */

- (GridLine *)objectAtIndexedSubscript:(NSUInteger)col;

/** @group Setting a column */

- (void)setObject:(GridLine *)col atIndexedSubscript:(NSUInteger)index1;

/** @group Delegate methods */

- (void)refreshOrigin;

- (CGFloat)originPositionWithGroup:(GridGroup *)group;

- (GridGroup *)reciproGroupForGroup:(GridGroup *)group;

@end


