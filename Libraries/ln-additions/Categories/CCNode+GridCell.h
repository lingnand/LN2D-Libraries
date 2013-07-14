//
// Created by Lingnan Dai on 26/06/2013.
//


#import <Foundation/Foundation.h>

@class GridLine;

typedef CCNode GridCell;
typedef NS_ENUM(NSUInteger, GridDimension)
{
    Row = 0,
    Col,
    GridLineTypeMax
};

@interface CCNode (GridCell)
/**
    dynamicWidth and dynamicHeight are used to control whether the current cell should be
    considered for grid line resizing
    dynamicWidth: this controls if the column this cell is in should resize its width depending
    on the changes in the size of this cell
    dynamicHeight: if the row this cell is in should resize its width depending on the changes in
    the size of this cell
*/
@property(nonatomic) BOOL dynamicWidth;
@property(nonatomic) BOOL dynamicHeight;
@property GridLine *row;
@property GridLine *col;

- (CGRect)gridBox;

- (CGSize)gridSize;

/**
    @return whether the current cell is empty
*/
- (BOOL)isEmpty;

/**
    @return an emtpy grid cell
*/
+ (GridCell *)empty;

+ (NSSet *)keyPathsForValuesAffectingGridSize;

- (BOOL)updateDrawingInParent;

// these are used by the gridcelldelegate : GridLine
- (BOOL)dynamicSizeWithType:(GridDimension)type;

- (void)setDynamicSize:(BOOL)dynamicSize type:(GridDimension)type;

- (void)setDynamicSizeTentatively:(BOOL)dynamicSize type:(GridDimension)type;

- (void)setDynamicSizeOnlyAndTentatively:(BOOL)dynamicSize type:(GridDimension)type;

- (void)setGridCellDelegate:(GridLine *)delegate type:(GridDimension)type;


@end

