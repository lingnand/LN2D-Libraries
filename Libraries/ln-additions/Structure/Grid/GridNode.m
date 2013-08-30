//


#import "GridNode.h"
#import "CCNode+LnAdditions.h"

@interface GridNode ()
@property(nonatomic, strong) NSMutableArray *grids;

@end

@implementation GridNode {

}
#pragma mark - Lifecycle

+ (id)gridWithGap:(CGFloat)gap {
    return [[self alloc] initWithGap:gap];
}

+ (id)gridWithGroup:(GridGroup *)group {
    GridNode *gn = [self gridWithGap:group.gap];
    [gn setGroup:group atIndex:group.type];
    return gn;
}

- (id)initWithGap:(CGFloat)gap {
    self = [super init];
    if (self) {
        self.anchorPoint = CGPointZero;

        _gap = gap;
        _origin = CGPointZero;
        // setting width to be negative gap so that empty cells are ignored
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:GridLineTypeMax];
        for (GridDimension type = (GridDimension) 0; type < GridLineTypeMax; type++) {
            GridGroup *group = [GridGroup groupWithType:type gap:gap];
            group.grid = self;
            [arr addObject:group];
        }
        _grids = arr;

        // the default mask (a nodemask will be good enough for looping through all
        // the children of this node)
    }
    return self;
}

- (void)dealloc {
    // nil the delegate pointers
    for (GridGroup *group in self.grids) {
        group.grid = nil;
    }
}

#pragma mark - Properties

- (void)setGap:(CGFloat)gap {
    // propagate the change in gap across all the groups
    // can't use the inequality test as the individual group gap may be different to that of the grid
    _gap = gap;
    for (GridGroup *g in self)
        g.gap = gap;
}

- (void)setOrigin:(CGPoint)origin {
    // basically this means shifting everything
    [self.rows shiftLinesAtIndexesStarting:0 byDelta:origin.x - _origin.x];
    [self.cols shiftLinesAtIndexesStarting:0 byDelta:origin.y - _origin.y];
    _origin = origin;
}

- (CGPoint)absoluteOrigin {
    return ccpAdd(self.position, self.origin);
}

- (GridLine *)objectAtIndexedSubscript:(NSUInteger)col {
    return  self.cols[col];
}

- (void)setObject:(GridLine *)col atIndexedSubscript:(NSUInteger)index {
    self.cols[index] = col;
}

- (GridGroup *)rows {
    return self.grids[Row];
}

- (GridGroup *)cols {
    return self.grids[Col];
}

- (void)setRows:(GridGroup *)rows {
    [self setGroup:rows atIndex:Row];
}

- (void)setCols:(GridGroup *)cols {
    [self setGroup:cols atIndex:Col];
}

- (CGFloat)width {
    return self.cols.width;
}

- (CGFloat)height {
    return self.rows.width;
}

- (NSUInteger)dimension {
    return self.grids.count;
}

-(void)setGroup:(GridGroup *)group atIndex:(NSUInteger)index {
    NSAssert(index < self.dimension, @"index out of bound");
    // first we need to nil the delegate field of ALL the groups in the current node
    // because even if only one dimension changes, ALL dimensions change as well
    for (NSUInteger i = 0; i < self.dimension; i++) {
        // this will remove the nodes from the canvas as well
        GridGroup *g = self.grids[i];
        g.grid = nil;
        // reinitiate the groups
        self.grids[i] = [GridGroup groupWithGap:self.gap];
    }
    // add in the lines one by one
    for (GridLine *line in group) {
        [self.grids[index] addLine:line];
    }
}

#pragma mark - GridGroupDelegate protocol

-(void)refreshOrigin {
    // change the origin
    CGPoint pos = self.origin;
    if (self.rows.count > 0) {
        pos.y = [self.rows[0] position];
    }
    if (self.cols.count > 0) {
        pos.x = [self.cols[0] position];
    }
    _origin = pos;
}

- (CGFloat)originPositionWithGroup:(GridGroup *)group {
    switch (group.type) {
        case Row:
            return self.origin.x;
        case Col:
            return self.origin.y;
        case GridLineTypeMax:
            [NSException raise:@"Wrong Argument" format:@"type input = %i", group.type];
    }
    return CGFLOAT_MIN;
}

- (GridGroup *)reciproGroupForGroup:(GridGroup *)group {
    switch (group.type) {
        case GridLineTypeMax: return nil;
        default: return self.grids[(NSUInteger) !group.type];
    }
}

#pragma mark - NSFastEnumeration (enumerate through groups)

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.grids countByEnumeratingWithState:state objects:buffer count:len];
}


@end

