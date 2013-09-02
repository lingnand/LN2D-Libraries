//
// Created by Lingnan Dai on 4/29/13.
//


#import "GridLine.h"
#import "GridGroup.h"
#import "GridNode.h"

@interface GridLine ()
@property(nonatomic, strong) NSMutableArray *cells;
@end

@implementation GridLine

#pragma mark - Lifecycle

+ (id)lineWithWidth:(CGFloat)width {
    return [[self alloc] initWithWidth:width dynamic:NO];
}

+ (id)lineWithWidth:(CGFloat)width cell:(GridCell *)cell {
    return [self lineWithWidth:width dynamic:NO cell:cell];
}

+ (id)lineWithWidth:(CGFloat)width cells:(GridCell *)firstCell, ... {
    va_list args;
    va_start(args, firstCell);
    GridLine *line = [self lineWithGridLine:[self lineWithWidth:width] firstParameter:firstCell parameterList:args];
    va_end(args);
    return line;
}

// CGFLOAT_MIN acts like a flag indicating that
// 1. the width hasn't changed since the line is created (most probably there's nothing filled in the line yet)
// 2. the width should be set to that given by the delegate whenever the delegate is set
+ (id)dynamicLine {
    return [[self alloc] initWithWidth:CGFLOAT_MIN dynamic:YES];
}

+ (id)dynamicLineWithCell:(GridCell *)cell {
    return [self lineWithWidth:CGFLOAT_MIN dynamic:YES cell:cell];
}

+ (id)dynamicLineWithCells:(GridCell *)firstCell, ... {
    va_list args;
    va_start(args, firstCell);
    GridLine *line = [self lineWithGridLine:[self dynamicLine] firstParameter:firstCell parameterList:args];
    va_end(args);
    return line;
}


// row section

+ (id)rowWithWidth:(CGFloat)width {
    GridLine *row = [self lineWithWidth:width];
    row.type = Row;
    return row;
}

+ (id)rowWithWidth:(CGFloat)width cell:(GridCell *)cell {
    GridLine *row = [self lineWithWidth:width cell:cell];
    row.type = Row;
    return row;
}

+ (id)rowWithWidth:(CGFloat)width cells:(GridCell *)firstCell, ... {
    va_list args;
    va_start(args, firstCell);
    GridLine *row = [self lineWithGridLine:[self rowWithWidth:width] firstParameter:firstCell parameterList:args];
    va_end(args);
    return row;
}

+ (id)dynamicRow {
    GridLine *row = [self dynamicLine];
    row.type = Row;
    return row;
}

+ (id)dynamicRowWithCell:(GridCell *)cell {
    GridLine *row = [self dynamicLineWithCell:cell];
    row.type = Row;
    return row;
}

+ (id)dynamicRowWithCells:(GridCell *)firstCell, ... {
    va_list args;
    va_start(args, firstCell);
    GridLine *row = [self lineWithGridLine:[self dynamicRow] firstParameter:firstCell parameterList:args];
    va_end(args);
    return row;
}

// col section

+ (id)columnWithWidth:(CGFloat)width {
    GridLine *column = [self lineWithWidth:width];
    column.type = Col;
    return column;
}

+ (id)columnWithWidth:(CGFloat)width cell:(GridCell *)cell {
    GridLine *column = [self lineWithWidth:width cell:cell];
    column.type = Col;
    return column;
}

+ (id)columnWithWidth:(CGFloat)width cells:(GridCell *)firstCell, ... {
    va_list args;
    va_start(args, firstCell);
    GridLine *column = [self lineWithGridLine:[self columnWithWidth:width] firstParameter:firstCell parameterList:args];
    va_end(args);
    return column;
}

+ (id)dynamicColumn {
    GridLine *column = [self dynamicLine];
    column.type = Col;
    return column;
}

+ (id)dynamicColumnWithCell:(GridCell *)cell {
    GridLine *column = [self dynamicLineWithCell:cell];
    column.type = Col;
    return column;
}

+ (id)dynamicColumnWithCells:(GridCell *)firstCell, ... {
    va_list args;
    va_start(args, firstCell);
    GridLine *column = [self lineWithGridLine:[self dynamicColumn] firstParameter:firstCell parameterList:args];
    va_end(args);
    return column;
}

// helper section

+ (id)lineWithWidth:(CGFloat)width dynamic:(BOOL)dynamic cell:(GridCell *)cell {
    GridLine *line = [[self alloc] initWithWidth:width dynamic:dynamic];
    line[0] = cell;
    return line;
}

+ (id)lineWithGridLine:(GridLine *)line firstParameter:(GridCell *)firstCell parameterList:(va_list)list {
    for (GridCell * cell = firstCell; cell != nil; cell = va_arg(list, GridCell *)) {
        [line addCell:cell];
    }
    return line;
}

- (id)initWithWidth:(CGFloat)width dynamic:(BOOL)dynamic {
    self = [super init];
    if (self) {
        _width = width;
        _index = 0;
        _type = GridLineTypeMax;
        _cells = [NSMutableArray array];
        _dynamic = dynamic;
    }

    return self;
}

//- (void)dealloc {
    // need to remove self from all other nodes being observed
    // just set all the delegate to nil and the underlying nodes will handle the rest
    // also need to remove the underlying nodes from the canvas at least as when the line structure is destroyed
    // the underlying nodes shouldn't remain on the screen
    // NOTICE: switching the property to weak should ensure all the cell's property set to nil automatically now
//    for (GridCell *cell in self) {
//        [self stopUpdateForCell:cell];
//    }
//}

#pragma mark - Properties

- (void)setPosition:(CGFloat)position {
    if (position != _position) {
        _position = position;
        [self updateAllPositions];
    }
}

-(void)setType:(GridDimension)type {
    if (type != _type) {
        if (self.count > 0) {
            // copy the dynamic variables
            if (!self.typePrepared)
                for (GridCell *cell in self)
                    [cell setDynamicSizeOnlyAndTentatively:self.dynamic type:type];
            // need to choose about the initial width before rewiring the relationship
            // three options
            // 1. defaultWidth (this is to assume that the new line should be considered a dynamic line)
            // 2. the current width (this can be misleading as it can be the width obtained from the dynamic width of the current type)
            // 3. if all the nodes in the current dimension are NOT dynamic, that means the current width is meant as a fixed width,
            // so take that as the starting point
            // otherwise the width is reset to the defaultWidth
            // resetting the delegate relationship
            // 4. if the current type is temp, that means the user has not decided the type of the line;
            //        in this case, the dynamics of the line after changing the type would be dependent on the previous config, so use 3.
            //    otherwise, the line's type has already been set,
            //        the dynamics of the line is NOT quite dependent on the previous config, instead, it's more dependent
            //        on the dynamic config of the new dimension; thus just loop through all the nodes in the new dimension
            //        while following the guideline in 3. but since we are already inside a loop and to do this we need to create another loop
            //        it's quite contrived, so just don't use the current width (since it's not so related to the new dimension)
            if (self.typePrepared || self.dynamic)
                _width = self.defaultWidth;
            // need to set the type first because when recalculating the width by relying on pushing notification
            // back to this class, the class will need the correct type info to compute the correct width
            GridDimension oldType = _type;
            _type = type;
            for (GridCell *cell in self) {
                [cell setGridCellDelegate:nil type:oldType];
                [cell setGridCellDelegate:self type:type];
            }

            // needs to update the position
            [self updateAllPositions];
        } else {
            _type = type;
        }
    }
}

- (void)setDynamic:(BOOL)dynamic {
    // update the dynamics of all the cells
    // we cannot use the inequality test as the individual cells can have different dynamic values to that
    // recorded by the line, so we have to tell each cell to update dynamic field even if the dynamic value
    // to be set is the same as the current value
    _dynamic = dynamic;
    for (GridCell *cell in self)
        [cell setDynamicSize:dynamic type:self.type];
}

- (void)setWidth:(CGFloat)width {
    [self setWidthOnly:width];
    self.dynamic = NO;
}

- (void)setWidthOnly:(CGFloat)width {
    if (width != _width) {
        CGFloat oldWidth = _width;
        _width = width;
        [self.group lineAtIndex:self.index widthChangedFrom:oldWidth newWidth:_width];
    }
}

- (void)setGroup:(GridGroup *)group {
    if (group != _group) {
        _group = group;
        [self updateDrawingInParent];
        // the only valid negative width would be defaultWidth
        if (self.dynamic && self.width == CGFLOAT_MIN) {
            // width correction: we should set the width to the default
            _width = self.defaultWidth;
        }
    }
}

- (BOOL)updateDrawingInParent {
// needs to remove the elements from the current grid and put them into the new grid
    NSUInteger i = 0;
    while (i < self.count && [self[i] updateDrawingInParent])
        i++;
    return i != 0;
}

#pragma mark - Convenience methods, query operations

- (GridCell *)lastCell {
    return self.cells.lastObject;
}

- (NSUInteger)minNonEmptyIndex {
    return [self indexForEdgeIndexWithMaximum:NO];
}

- (NSUInteger)maxNonEmptyIndex {
    return [self indexForEdgeIndexWithMaximum:YES];
}

- (NSArray *)nonEmptyCells {
    return [self.cells filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isEmpty = NO"]];
}

- (NSUInteger)indexForEdgeIndexWithMaximum:(BOOL)max {
    NSEnumerationOptions option = 0;
    __block NSUInteger edge;
    if (max) {
        option = NSEnumerationReverse;
        edge = 0;
    } else {
        edge = self.cells.count - 1;
    }
    [self.cells enumerateObjectsWithOptions:option
                                 usingBlock:^(GridCell *cell, NSUInteger idx, BOOL *stop) {
                                     if (!cell.isEmpty) {
                                         edge = idx;
                                         *stop = YES;
                                     }
                                 }];
    return edge;
}

- (GridCell *)objectAtIndexedSubscript:(NSUInteger)index {
    // add new cells when needed
    while (index >= self.count) {
        [self addCell:[GridCell empty]];
    }
    return self.cells[index];
}

// this is the size of the line
- (NSUInteger)count {
    return self.cells.count;
}

#pragma mark - Storage manipulation

- (CGFloat)defaultWidth {
    if (self.linkedToGroup) {
        return self.group.defaultLineWidth;
    }
    return CGFLOAT_MIN;
}

- (BOOL)typePrepared {
    return self.type != GridLineTypeMax;
}

- (BOOL)linkedToGroup {
    return self.group != nil;
}

- (BOOL)linkedToGrid {
    return self.group.reciproGroup != nil;
}

- (void)setObject:(GridCell *)obj atIndexedSubscript:(NSUInteger)index {
    [self setCell:obj atIndex:index];
}

- (void)addCell:(GridCell *)cell {
    [self setCell:cell atIndex:self.count];
}

- (void)setCell:(GridCell *)cell atIndex:(NSUInteger)index {
    // check for existence of this cell!; of course it would be best if we can dynamically relocate the child, but that means a huge search through and generally I don't think that's worthwhile
    NSAssert(![self.group.grid.children containsObject:cell], @"You can't insert the same children twice!");
    while (index >= self.cells.count) {
        // first add the empty cells into this line (since delegate can be nil)
        // since we are adding new lines we're definitely going towards a replace at the place
        // we need to add more lines for the other dimension
        // tacit add line with dynamic grow
        if (self.linkedToGrid)
            [self.group.reciproGroup addLine:[GridLine dynamicLine]];
        else
            [self oneSideInsertCell:[GridCell empty] atIndex:self.count];
    }
    // deregister the thing if needed
    [self oneSideSetCell:cell atIndex:index];
    [self.group.reciproGroup[index] oneSideSetCell:cell atIndex:self.index];
}

- (void)insertCell:(GridCell *)cell atIndex:(NSUInteger)index {
    if (index >= self.cells.count) {
        [self setCell:cell atIndex:index];
        return;
    }
    NSAssert(![self.group.grid.children containsObject:cell], @"You can't insert the same children twice!");
    // bubbleUp the whole array
    // first create a bubble at the topmost position
    if (self.linkedToGrid) {
        NSUInteger max = self.maxNonEmptyIndex;
        if (max == self.count) {
            // we need to add one more in the other dimension
            [self.group.reciproGroup addLine:[GridLine dynamicLine]];
        }
        [self shiftHoleFromStart:max + 1 end:index];
        [self.group.reciproGroup[index] oneSideSetCell:cell atIndex:self.index];
        // now should have an empty bubble at index
        [self oneSideSetCell:cell atIndex:index];
    } else {
        [self oneSideInsertCell:[GridCell empty] atIndex:index];
    }
}

- (void)removeLastCell {
    [self removeCellAtIndex:self.cells.count - 1];
}

- (void)removeCellAtIndex:(NSUInteger)index {
    if (self.linkedToGrid) {
        GridGroup *reciproGroup = self.group.reciproGroup;
        [reciproGroup[index] oneSideSetCell:[GridCell empty] atIndex:self.index];
        // the end number should be the maximum number in the array that is a node
        NSUInteger max = self.maxNonEmptyIndex;
        [self shiftHoleFromStart:index end:max];
        // check if the topmost line is all bubbles, if yes, then remove it
        GridLine *top = reciproGroup[max];
        if (top.nonEmptyCells.count == 0)
            [reciproGroup removeLine:top];
    }
    [self oneSideRemoveCellAtIndex:index];
}

#pragma mark - Sending message

- (void)enumerateCellsUsingBlock:(void (^)(GridCell *cell, NSUInteger idx, BOOL *stop))block {
    [self.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx, stop);
    }];
}

#pragma mark - Helper methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.typePrepared) {
        if ([keyPath isEqualToString:@"gridSize"]) {
            CGSize oldSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
            [self updateColWidthFromOldWidth:[self gridWidthWithGridSize:oldSize]
                                  toNewWidth:[self gridWidthWithGridSize:newSize]];
        }
    }
}

- (CGFloat)gridWidthWithCell:(GridCell *)cell {
    return [self gridWidthWithGridSize:cell.gridSize];
}

- (CGFloat)gridWidthWithGridSize:(CGSize)size {
    switch (self.type) {
        case Row: return size.height;
        case Col: return size.width;
        default:return self.defaultWidth;
    }
}

- (void)updateCell:(GridCell *)node {
    [node setDynamicSizeTentatively:self.dynamic type:self.type];
    [node setGridCellDelegate:self type:self.type];
    [self updatePos:self.position withCell:node];
}

- (void)updateColWidthFromOldWidth:(CGFloat)oldWidth toNewWidth:(CGFloat)newWidth {
    // update the maximum col width
    if (oldWidth != newWidth) {
        if (oldWidth == self.width) {
            if (newWidth > oldWidth)
                [self setWidthOnly:newWidth];
            else
                [self setWidthOnly:[self calculatedMaxWidthRetainingOriginalWidth:NO]];
        } else {
            [self setWidthOnly:MAX(self.width, newWidth)];
        }
    }
}

- (CGFloat)calculatedMaxWidthRetainingOriginalWidth:(BOOL)retain {
    // loop through all the nodes in the line and take into account of the nodes that are annotated 'dynamic
    CGFloat max = self.defaultWidth;
    for (GridCell *cell in self) {
        if ([cell dynamicSizeWithType:self.type]) {
            max = MAX(max, [self gridWidthWithCell:cell]);
            retain = NO;
        }
    }
    return retain ? self.width : max;
}

- (void)updateAllPositions {
    for (GridCell *cell in self) {
        [self updatePos:self.position withCell:cell];
    }
}

- (void)updatePos:(CGFloat)position withCell:(GridCell *)child {
    CGPoint pos = child.position;
    switch (self.type) {
        case Row:
            pos.y = position;
            break;
        case Col:
            pos.x = position;
            break;
        case GridLineTypeMax:break;
    }
    child.position = pos;
}


- (void)stopUpdateForCell:(GridCell *)node {
    [node setGridCellDelegate:nil type:self.type];
}

- (void)shiftHoleFromStart:(NSUInteger)start end:(NSUInteger)end {
    if (start == end)
        return;
    int sign = end < start ? -1 : 1;
    int endl = sign * (int) end;
    for (int hole = start; sign * hole < endl; hole += sign) {
        // remove the swapper one
        GridLine *toRemove = self.group[(NSUInteger) (hole + sign)];
        GridLine *toAdd = self.group[(NSUInteger) hole];

        GridCell *obj = toRemove.cells[self.index];
        [toRemove oneSideSetCell:[GridCell empty] atIndex:self.index];
        [toAdd oneSideSetCell:obj atIndex:self.index];
    }
}

// we need to add the entire api to perform one side add/set/insert/remove; and then allow the delegate to manipulate that instead of letting the delegate do everything

- (void)oneSideSetCell:(GridCell *)cell atIndex:(NSUInteger)index {
    GridCell *obj = self.cells[index];
    if (obj == cell) {
        return;
    }
    self.cells[index] = cell;
    [self stopUpdateForCell:obj];
    [self updateCell:cell];
}

-(void)oneSideInsertCell:(GridCell *)cell atIndex:(NSUInteger)index {
    [self.cells insertObject:cell atIndex:index];
    [self updateCell:cell];
}

- (void)oneSideRemoveCellAtIndex:(NSUInteger)index {
    GridCell *obj = self.cells[index];
    [self.cells removeObjectAtIndex:index];
    [self stopUpdateForCell:obj];
}

#pragma mark - FastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    return [self.cells countByEnumeratingWithState:state objects:buffer count:len];
}

@end


