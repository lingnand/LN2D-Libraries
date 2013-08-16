//
// Created by Lingnan Dai on 4/29/13.
//


#import "GridGroup.h"
#import "GridNode.h"
#import "CompositeMask.h"

@interface GridGroup ()
@property(nonatomic, strong) NSMutableArray *lines;
@end

@implementation GridGroup
@synthesize mask = _mask;

#pragma mark - Lifecycle

+ (id)groupWithType:(GridDimension)type gap:(CGFloat)gap {
    GridGroup *group = [[self alloc] initWithGap:gap];
    group.type = type;
    return group;
}

+ (id)groupWithGap:(CGFloat)gap {
    return [[self alloc] initWithGap:gap];
}

+ (id)groupWithGap:(CGFloat)gap lines:(GridLine *)firstLine,... {
    va_list args;
    va_start(args,firstLine);
    GridGroup *group = [self groupWithGridGroup:[GridGroup groupWithGap:gap] firstParameter:firstLine parameterList:args];
    va_end(args);
    return group;
}

+ (id)groupWithGridGroup:(GridGroup *)group firstParameter:(GridLine *)firstLine parameterList:(va_list)list {
    for (GridLine *line = firstLine; line != nil; line = va_arg(list, GridLine *)) {
        [group addLine:line];
    }
    return group;
}

+ (id)groupWithGap:(CGFloat)gap line:(GridLine *)line {
    GridGroup *group = [GridGroup groupWithGap:gap];
    [group addLine:line];
    return group;
}

+ (id)rowsWithGap:(CGFloat)gap {
    return [self groupWithType:Row gap:gap];
}

+ (id)rowsWithGap:(CGFloat)gap line:(GridLine *)line {
    GridGroup *group = [self groupWithGap:gap line:line];
    group.type = Row;
    return group;
}

+ (id)rowsWithGap:(CGFloat)gap lines:(GridLine *)firstLine,... {
    va_list args;
    va_start(args,firstLine);
    GridGroup *group = [self groupWithGridGroup:[GridGroup rowsWithGap:gap] firstParameter:firstLine parameterList:args];
    va_end(args);
    return group;
}

+ (id)columnsWithGap:(CGFloat)gap {
    return [self groupWithType:Col gap:gap];
}

+ (id)columnsWithGap:(CGFloat)gap line:(GridLine *)line {
    GridGroup *group = [self groupWithGap:gap line:line];
    group.type = Col;
    return group;
}

+ (id)columnsWithGap:(CGFloat)gap lines:(GridLine *)firstLine,... {
    va_list args;
    va_start(args,firstLine);
    GridGroup *group = [self groupWithGridGroup:[GridGroup columnsWithGap:gap] firstParameter:firstLine parameterList:args];
    va_end(args);
    return group;
}

- (id)initWithGap:(CGFloat)gap {
    self = [super init];
    if (self) {
        // init the array!
        _lines = [NSMutableArray array];
        _gap = gap;
        _type = GridLineTypeMax;
    }
    return self;
}

//- (void)dealloc {
    // remove the subsituent components
    // NOTICE! using  weak references should automatically nil-ing the properties now
//    for (GridLine *line in self) {
//        [self cleanPropertiesWithLine:line];
//    }
//}

#pragma mark - Common properties

- (Mask *)mask {
    if (!_mask) {
        // default mask
        self.mask = [CompositeMask maskWithNodeContainer:self];
    }
    return _mask;
}

- (void)setGrid:(GridNode *)grid {
    if (grid != _grid) {
        _grid = grid;
        // update all the lines below
        [self updateDrawingInParent];
    }
}

- (void)setGap:(CGFloat)gap {
    // need to consider a cascading change in the gap (the second col needs to be moved by 1 * change; the second 2 * change...)
    if (_gap != gap) {
        CGFloat d = gap - _gap;
        for (NSUInteger i = 1; i < self.count; i++) {
            self[i].position += i * d;
        }
        _gap = gap;
    }
}

- (BOOL)updateDrawingInParent {
    NSUInteger i = 0;
    while (i < self.count && [self[i] updateDrawingInParent])
        i++;
    return i != 0;
}

- (GridLine *)objectAtIndexedSubscript:(NSUInteger)line {
    // we need to insert new lines if needed
    while (line >= self.lines.count) {
        [self addLine:[GridLine dynamicLine]];
    }
    return self.lines[line];
}

- (void)setObject:(GridLine *)line atIndexedSubscript:(NSUInteger)index {
    [self setLine:line atIndex:index];
}

- (void)setType:(GridDimension)type {
    if (type != _type) {
        _type = type;
        for (GridLine *l in self.lines) {
            l.type = type;
        }
        // need to change all the positions
        CGFloat p = [self.grid originPositionWithGroup:self];

        for (GridLine *line in self.lines) {
            line.position = p;
            p += line.width + self.gap;
        }
    }
}

- (GridLine *)lastLine {
    return self.lines.lastObject;
}

- (CGFloat)width {
    // if the width is invalid then return CGFLOAT_MIN as a guard
    if (self.count == 0 || !self.typePrepared) return CGFLOAT_MIN;
    // return the total width of the group
    return self.lastLine.position - self[0].position + self.lastLine.width;
}

- (NSUInteger)count {
    return self.lines.count;
}

#pragma mark - Line manipulation

- (BOOL)linkedToGrid {
    return self.reciproGroup != nil;
}

- (BOOL)typePrepared {
    return self.type != GridLineTypeMax;
}

- (void)addLine:(GridLine *)line {
//    NSAssert(self.type == line.type, @"incompatible types!");
    [self setLine:line atIndex:self.lines.count];
}

- (void)setLine:(GridLine *)line atIndex:(NSUInteger)index {
    // check if the row at index already exists
    // we need to read off the original information from line
    NSAssert(!line.group || (line.group != self.reciproGroup && (line.group != self || line.index >= self.lines.count || self.lines[line.index] != line)), @"You need to remove the line first before you can add it back!");
    [self updatePropertiesWithLine:line atIndex:index];
    if (index < self.count) {
        [self updateReplacementAtIndex:index withLine:line];
    } else {
        // need to grow the lines to accomodate the index
        while (index > self.lines.count) {
            GridLine *newLine = [GridLine dynamicLine];
            [self updatePropertiesWithLine:newLine atIndex:self.lines.count];
            [self updateInsertionWithLine:newLine atIndex:self.lines.count];
        }
        [self updateInsertionWithLine:line atIndex:index];
    }
}

- (void)insertLine:(GridLine *)line atIndex:(NSUInteger)index {
    if (index >= self.lines.count) {
        [self setLine:line atIndex:index];
        return;
    }
    NSAssert(!line.group || (line.group != self.reciproGroup && (line.group != self || line.index >= self.lines.count || self.lines[line.index] != line)), @"You need to remove the line first before you can add it back!");
    [self updatePropertiesWithLine:line atIndex:index];
    [self updateInsertionWithLine:line atIndex:index];

    // shift all other lines up
    [self lineAtIndex:index widthChangedFrom:self.defaultLineWidth newWidth:line.width];
}

- (GridLine *)cutFirst {
    GridLine *first = self.lines[0];
    [self cleanPropertiesWithLine:first];
    [self updateRemovementWithLine:first];
    [self.grid refreshOrigin];
    return first;
}

- (void)removeLine:(GridLine *)line {
    [self removeLineAtIndex:line.index];
}

- (void)removeLineAtIndex:(NSUInteger)index {
    if (index < self.lines.count) {
        GridLine *line = self.lines[index];
        [self lineAtIndex:index widthChangedFrom:line.width newWidth:self.defaultLineWidth];
        [self cleanPropertiesWithLine:line];
        [self updateRemovementWithLine:line];
    }
}

- (void)removeLastLine {
    [self removeLineAtIndex:self.count - 1];
}

#pragma mark - Group manipulation (very experimental)

// this method will attempt to merge two gridgroups together; note that some properties of the group to be inserted will be lost
// - gap
// - delegate
- (void)insertGroup:(GridGroup *)group atIndex:(NSUInteger)index {
    // just add the lines one by one
    for (NSUInteger i = 0; i < group.lines.count; i++) {
        [self insertLine:group.lines[i] atIndex:index+i];
    }
}

- (void)addGroup:(GridGroup *)group {
    [self insertGroup:group atIndex:self.count];
}

#pragma mark - Helper methods

// on the data strorage side, by default the thing is removed and not replaced
- (void)cleanPropertiesWithLine:(GridLine *)line {
    line.group = nil;
}

- (void)shiftLinesAtIndexesStarting:(NSUInteger)index byDelta:(CGFloat)delta {
    if (delta == 0 || index >= self.lines.count) return;
    [self.lines enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, self.lines.count - index)]
                                  options:NSEnumerationConcurrent
                               usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                   GridLine *l = obj;
                                   l.position += delta;
                               }];
}


- (void)updateReplacementAtIndex:(NSUInteger)index withLine:(GridLine *)line {
    GridLine *old = self.lines[index];
    [self cleanPropertiesWithLine:old];
    // remove this line first
    self.lines[index] = line;
    // need to do some shifting then
    [self lineAtIndex:index widthChangedFrom:old.width newWidth:line.width];
    // wire up the other end
    [self.reciproGroup.lines enumerateObjectsUsingBlock:^(GridLine *other_line, NSUInteger idx, BOOL *stop) {
        [other_line oneSideSetCell:line[idx] atIndex:index];
    }];
}

// update the position of the line; fill the elements with null if necessary
- (void)updatePropertiesWithLine:(GridLine *)line atIndex:(NSUInteger)index {
    line.group = self;
    line.index = index;
    line.type = self.type;
    if (self.typePrepared) {
        // set the position of the line
        if (index == 0) {
            line.position = [self.grid originPositionWithGroup:self];
        } else {
            GridLine *lastLine = self.lines[index - 1];
            CGFloat width = lastLine.width;
            // the lines below should help make empty lines gapless
            // we should assume that the lines are able to handle width correctly - negative width would turn out to be the default width
//        if (width <= 0) {
//            width = self.defaultWidth;
//        }
            line.position = lastLine.position + width + self.gap;
        }
    }
    if (self.linkedToGrid) {
        // we must make sure that the number of elements = reciproGroup.count
        // 1. the number of elements in this line is smaller than the reciproGroup count
        while (line.count < self.reciproGroup.count) {
            // insert bubbles in the end
            [line oneSideInsertCell:[GridCell empty] atIndex:line.count];
        }
        // 2. the reciproGroup count is smaller than the number of elements in this line
        while (self.reciproGroup.count < line.count) {
            [self.reciproGroup addLine:[GridLine dynamicLine]];
        }
        // check for consistency of no. of elements
        NSAssert(!self.reciproGroup || line.count == self.reciproGroup.count, @"Throwing in a line with incompatible cell number");
    }
}

- (void)updateInsertionWithLine:(GridLine *)line atIndex:(NSUInteger)index {
    [self.lines insertObject:line atIndex:index];
    // need to update all indexes
    if (self.count - 1 > index)
        [self.lines enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, self.count - index - 1)]
                                      options:NSEnumerationConcurrent
                                   usingBlock:^(GridLine *obj, NSUInteger idx, BOOL *stop) {
                                       obj.index++;
                                   }];
    [self.reciproGroup.lines enumerateObjectsUsingBlock:^(GridLine *other_line, NSUInteger idx, BOOL *stop) {
        [other_line oneSideInsertCell:line[idx] atIndex:index];
    }];
}

- (void)updateRemovementWithLine:(GridLine *)line {
    NSUInteger index = line.index;
    [self.lines removeObjectAtIndex:index];
    // need to update the indexes
    if (self.count > index)
        [self.lines enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, self.lines.count - index)]
                                       options:NSEnumerationConcurrent
                                    usingBlock:^(GridLine *obj, NSUInteger idx, BOOL *stop) {
                                        obj.index--;
                                    }];
    // we need to then wire up the other end
    [self.reciproGroup.lines enumerateObjectsUsingBlock:^(GridLine *other_line, NSUInteger idx, BOOL *stop) {
        [other_line oneSideRemoveCellAtIndex:index];
    }];
}

#pragma mark - GridLineDelegate protocol

- (GridGroup *)reciproGroup {
    return [self.grid reciproGroupForGroup:self];
}

- (CGFloat)defaultLineWidth {
    return -self.gap;
}

- (void)lineAtIndex:(NSUInteger)index widthChangedFrom:(CGFloat)oldWidth newWidth:(CGFloat)newWidth {
    if (self.typePrepared && index != self.lines.count) {
        // move all the bigger rows
        [self shiftLinesAtIndexesStarting:index + 1 byDelta:newWidth - oldWidth];
    }
}

#pragma mark - FastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    return [self.lines countByEnumeratingWithState:state objects:buffer count:len];
}

@end
