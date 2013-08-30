//
// Created by Lingnan Dai on 26/06/2013.
//


#import <objc/runtime.h>
#import "CCNode+GridCell.h"
#import "GridLine.h"
#import "GridGroup.h"
#import "CCNode+LnAdditions.h"
#import "GridNode.h"


static char const *const gridCellRowDelegate = "GridCellRowDelegate";
static char const *const gridCellColDelegate = "GridCellColDelegate";
static char const *const gridCellTempDelegate = "GridCellTempDelegate";
static char const *const gridCellDynamicWidth = "GridCellDynamicWidth";
static char const *const gridCellDynamicHeight = "GridCellDynamicHeight";
static char const *const gridCellDynamicWidthUserSet = "GridCellDynamicWidthUserSet";
static char const *const gridCellDynamicHeightUserSet = "GridCellDynamicHeightUserSet";
@implementation CCNode (GridCell)

- (BOOL)getDynamicsWithKey:(const void *)key {
    NSNumber *d = objc_getAssociatedObject(self, key);
    if (!d) {
        // this is default value. By default all dimensions in each cell is dynamic
        return YES;
    }
    return [d boolValue];
}

- (BOOL)dynamicWidthUserSet {
    return [objc_getAssociatedObject(self, gridCellDynamicWidthUserSet) boolValue];
}

- (void)setDynamicWidthUserSet:(BOOL)dynamicWidthUserSet {
    objc_setAssociatedObject(self, gridCellDynamicWidthUserSet, [NSNumber numberWithBool:dynamicWidthUserSet], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dynamicHeightUserSet {
    return [objc_getAssociatedObject(self, gridCellDynamicHeightUserSet) boolValue];
}

- (void)setDynamicHeightUserSet:(BOOL)dynamicHeightUserSet {
    objc_setAssociatedObject(self, gridCellDynamicHeightUserSet, [NSNumber numberWithBool:dynamicHeightUserSet], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dynamicWidth {
    return [self getDynamicsWithKey:gridCellDynamicWidth];
}

- (void)setDynamicWidth:(BOOL)dynamicWidth {
    [self setDynamicWidthInner:dynamicWidth];
    // turn on the user control toggle
    self.dynamicWidthUserSet = YES;
}

- (void)setDynamicWidthInner:(BOOL)dynamicWidth {
    [self updateDynamicChangeWithDelegate:self.col oldDynamic:self.dynamicWidth newDynamic:dynamicWidth];
    [self setDynamicWidthOnly:dynamicWidth];
}

- (void)setDynamicWidthOnly:(BOOL)dynamicWidth {
    objc_setAssociatedObject(self, gridCellDynamicWidth, [NSNumber numberWithBool:dynamicWidth], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dynamicHeight {
    return [self getDynamicsWithKey:gridCellDynamicHeight];
}

- (void)setDynamicHeight:(BOOL)dynamicHeight {
    [self setDynamicHeightInner:dynamicHeight];
    self.dynamicHeightUserSet = YES;
}

- (void)setDynamicHeightInner:(BOOL)dynamicHeight {
    [self updateDynamicChangeWithDelegate:self.row oldDynamic:self.dynamicHeight newDynamic:dynamicHeight];
    [self setDynamicHeightOnly:dynamicHeight];
}

- (void)setDynamicHeightOnly:(BOOL)dynamicHeight {
    objc_setAssociatedObject(self, gridCellDynamicHeight, [NSNumber numberWithBool:dynamicHeight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateDelegateChangeWithOldDelegate:(GridLine *)oldDelegate newDelegate:(GridLine *)newDelegate dynamic:(BOOL)dynamic{
    if (oldDelegate != newDelegate) {
        if (dynamic) {
            // remove wring from old delegate
            [self removeObserverWithDelegate:oldDelegate];
            // potentially remove this cell from the delegate? don't know...
            // you shouldn't do this though as how about the delegate for the other dimension, etc??
            // at this level there's no way to know what has happened given the delegate has been changed.
            // verdict: never change the delegate from a client side
            // add wring for new delegate
            [self addObserverWithDelegate:newDelegate];
        }
    }
}

// if update successful return true
- (BOOL)updateDrawingInParent {
    // only update when both row and col properties are consistent
    if (self.parent != self.row.group.grid && self.row.group.grid == self.col.group.grid) {
        [self removeFromParentAndCleanup:YES];
        [self.row.group.grid addChild:self];
        return YES;
    }
    return NO;
}

- (void)addObserverWithDelegate:(GridLine *)delegate {
    if (delegate) {
        [self addObserver:delegate
               forKeyPath:@"gridSize"
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                  context:nil];
    }
}

- (void)removeObserverWithDelegate:(GridLine *)delegate {
    if (delegate) {
        [self removeObserver:delegate forKeyPath:@"gridSize"];
        // recalculate width
        [delegate updateColWidthFromOldWidth:[delegate gridWidthWithCell:self] toNewWidth:delegate.defaultWidth];
    }
}

- (void)updateDynamicChangeWithDelegate:(GridLine *)delegate oldDynamic:(BOOL)oldDynamic newDynamic:(BOOL)newDynamic {
    if (oldDynamic != newDynamic) {
        if (newDynamic) {
            // wire up delegate
            [self addObserverWithDelegate:delegate];
        } else {
            // remove wiring from delegate
            [self removeObserverWithDelegate:delegate];
        }
    }
}

- (BOOL)dynamicSizeWithType:(GridDimension)type {
    switch (type) {
        case Row:return self.dynamicHeight;
        case Col:return self.dynamicWidth;
        // giving YES as default value
        case GridLineTypeMax: return self.tempDelegate ? self.tempDelegate.dynamic : YES;
    }
}

- (void)setDynamicSizeTentatively:(BOOL)dynamicSize type:(GridDimension)type {
    switch (type) {
        case Row:
            if (!self.dynamicHeightUserSet)
                [self setDynamicHeightInner:dynamicSize];
            break;
        case Col:
            if (!self.dynamicWidthUserSet)
                [self setDynamicWidthInner:dynamicSize];
            break;
        case GridLineTypeMax:
            break;
    }
}

- (void)setDynamicSize:(BOOL)dynamicSize type:(GridDimension)type {
    switch (type) {
        case Row:
            [self setDynamicHeightInner:dynamicSize];
            break;
        case Col:
            [self setDynamicWidthInner:dynamicSize];
            break;
        case GridLineTypeMax:
            break;
    }
}

- (void)setDynamicSizeOnlyAndTentatively:(BOOL)dynamicSize type:(GridDimension)type {
    switch (type) {
        case Row:
            if (!self.dynamicHeightUserSet)
                [self setDynamicHeightOnly:dynamicSize];
            break;
        case Col:
            if (!self.dynamicWidthUserSet)
                [self setDynamicWidthOnly:dynamicSize];
            break;
        case GridLineTypeMax:
            break;
    }
}

-(GridLine *)row {
    return objc_getAssociatedObject(self, gridCellRowDelegate);
}

- (void)setRow:(GridLine *)row {
    [self updateDelegateChangeWithOldDelegate:self.row newDelegate:row dynamic:self.dynamicHeight];
    objc_setAssociatedObject(self, gridCellRowDelegate, row, OBJC_ASSOCIATION_ASSIGN);
    [self updateDrawingInParent];
}

-(GridLine *)col {
    return objc_getAssociatedObject(self, gridCellColDelegate);
}

- (void)setCol:(GridLine *)col {
    [self updateDelegateChangeWithOldDelegate:self.col newDelegate:col dynamic:self.dynamicWidth];
    objc_setAssociatedObject(self, gridCellColDelegate, col, OBJC_ASSOCIATION_ASSIGN);
    [self updateDrawingInParent];
}

-(GridLine *)tempDelegate {
    return objc_getAssociatedObject(self, gridCellTempDelegate);
}

- (void)setTempDelegate:(GridLine *)temp {
    // quite a trap here; setting the delegate for the temp always implies first setting the dynamic property to the new delegate's dynamic property
    // and then perform a set delegate
    [self updateDynamicChangeWithDelegate:self.tempDelegate oldDynamic:self.tempDelegate.dynamic newDynamic:temp.dynamic];
    [self updateDelegateChangeWithOldDelegate:self.tempDelegate newDelegate:temp dynamic: temp.dynamic];
    objc_setAssociatedObject(self, gridCellTempDelegate, temp, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setGridCellDelegate:(GridLine *)delegate type:(GridDimension)type{
    switch (type) {
        case Row:
            self.row = delegate;
            break;
        case Col:
            self.col = delegate;
            break;
        case GridLineTypeMax:
            self.tempDelegate = delegate;
            break;
    }
}

- (CGRect)gridBox {
    return (CGRect){self.position, self.gridSize};
}

- (CGSize)gridSize {
    if (self.isEmpty) {
        // setting to minimum size is to prevent the gridLine width to change incorrectly
        // i.e. expand due to an empty cell
        return CGSizeMake(CGFLOAT_MIN, CGFLOAT_MIN);
    }
    CGRect unionBoxInParent = self.unionBoxInParent;
    // the position attribute of this node would indicate where the anchor point is in the parent space
    CGFloat width = unionBoxInParent.origin.x + unionBoxInParent.size.width - self.position.x;
    CGFloat height = unionBoxInParent.origin.y + unionBoxInParent.size.height - self.position.y;
    return CGSizeMake(width, height);
}

- (BOOL)isEmpty {
    return self.children.count == 0 && self.contentSize.width == 0 && self.contentSize.height == 0;
}

+ (GridCell *)empty {
    return [self node];
}

// the following is to be used with gridSize monitoring in GridNode family
+ (NSSet *)keyPathsForValuesAffectingGridSize {
    return [NSSet setWithObject:@"canvasSize"];
}

@end

