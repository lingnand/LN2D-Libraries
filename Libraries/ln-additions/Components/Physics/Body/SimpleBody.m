/*!
    @header Mover
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "SimpleBody.h"
#import "CCNode+LnAdditions.h"
#import "NodalMask.h"
#import "BodilyMask.h"
#import "SimpleSpace.h"

@implementation SimpleBody {
    BodilyMask *_mask;
}
@synthesize position = _position;
@synthesize velocity = _velocity;

#pragma mark - LifeCycle

- (BOOL)activated {
    return [super activated] && (self.velocity.x || self.velocity.y || self.acceleration.x || self.acceleration.y);
}

+ (NSSet *)keyPathsForValuesAffectingActivated {
    NSMutableSet *set = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingActivated]];
    [set addObjectsFromArray:@[@"velocity", @"acceleration"]];
    return set;
}

- (void)update:(ccTime)delta {
    // avoid using the setter so that no unnecessary messages are sent to
    // check the activated attribute
    _velocity = ccpAdd(self.velocity, ccpMult(self.acceleration, delta));
    self.position = ccpAdd(self.host.position, ccpMult(self.velocity, delta));
}

- (void)activate {
    [super activate];
    [self scheduleUpdate];
    // set the position (in case the component is added and the position is not in sync)
    self.host.nodePosition = self.position;
}

- (void)deactivate {
    [super deactivate];
    [self unscheduleUpdate];
}

#pragma mark - Positions and attributes

/** with respect to immediate parent */
- (void)setPosition:(CGPoint)position {
    self.host.nodePosition = position;
    _position = position;
}

- (CGPoint)spacePosition {
    // returns the real position of the host in the world coordinate
    return CGPointApplyAffineTransform(self.position, self.hostParentToSpaceTransform);
}

- (void)setSpacePosition:(CGPoint)spacePosition {
    self.position = CGPointApplyAffineTransform(spacePosition, self.spaceToHostParentTransform);
}

- (CGPoint)spaceVelocity {
    return CGPointVectorApplyAffineTransform(self.velocity, self.hostParentToSpaceTransform);
}

- (void)setSpaceVelocity:(CGPoint)spaceVelocity {
    self.velocity = CGPointVectorApplyAffineTransform(spaceVelocity, self.spaceToHostParentTransform);
}

- (CGPoint)spaceAcceleration {
    return CGPointVectorApplyAffineTransform(self.acceleration, self.hostParentToSpaceTransform);
}

- (void)setSpaceAcceleration:(CGPoint)spaceAcceleration {
    self.acceleration = CGPointVectorApplyAffineTransform(spaceAcceleration, self.spaceToHostParentTransform);
}

#pragma mark - BodilyMask related operations

- (BodilyMask *)mask {
    if (!_mask)
        self.mask = [NodalMask mask];
    return _mask;
}

- (void)setMask:(BodilyMask *)mask {
    if (mask != _mask) {
        _mask.body = nil;
        _mask = mask;
        mask.body = self;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    SimpleBody *copy = (SimpleBody *) [super copyWithZone:zone];

    if (copy != nil) {
        copy->_position = _position;
        copy->_acceleration = _acceleration;
        copy->_restitution = _restitution;
        copy->_velocity = _velocity;
    }

    return copy;
}


#pragma mark - Legacy opposite point calculation (not used)

-(CGPoint)edgeStartingPointOnMovingDirection {
    CGFloat rightHalfWidth = self.host.contentSize.width * (1 - self.host.anchorPoint.x);
    CGFloat upperHalfHeight = self.host.contentSize.height * (1 - self.host.anchorPoint.y);
    return [self nearestPointOnEdgeFromPoint:self.host.position
                                           withDirection:ccpMult(self.velocity, -1)
                                                    rect:CGRectMake(-rightHalfWidth, -upperHalfHeight,
                                                            self.host.contentSize.width + [CCDirector sharedDirector].winSize.width,
                                                            self.host.contentSize.height + [CCDirector sharedDirector].winSize.height)];
}

- (float)yIntersectionForXLine:(float)xval withPoint:(CGPoint)point direction:(CGPoint)dir {
    if (dir.x == 0) return NAN;
    return point.y + (xval - point.x) * (dir.y / dir.x);
}

- (float)xIntersectionForYLine:(float)yval withPoint:(CGPoint)point direction:(CGPoint)dir {
    if (dir.y == 0) return NAN;
    return point.x + (yval - point.y) / (dir.y / dir.x);
}

- (CGPoint)nearestPointOnEdgeFromPoint:(CGPoint)point withDirection:(CGPoint)dir rect:(CGRect)rect {

    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);

    BOOL withinRect = point.x <= maxX && point.x >= minX && point.y <= maxY && point.y >= minY;
    CGPoint valid1 = ccp(NAN, NAN), valid2 = ccp(NAN, NAN);


    CGPoint right = CGPointMake(maxX, [self yIntersectionForXLine:maxX withPoint:point direction:dir]);
    if (right.y <= maxY && right.y >= minY) {
        if (withinRect) return right;
        if (valid1.x != valid1.x) valid1 = right;
        else valid2 = right;
    }
    CGPoint left = ccp(minX, [self yIntersectionForXLine:minX withPoint:point direction:dir]);
    if (left.y <= maxY && left.y >= minY) {
        if (withinRect) return left;
        if (valid1.x != valid1.x) valid1 = left;
        else valid2 = left;
    }
    CGPoint bottom = ccp([self xIntersectionForYLine:minY withPoint:point direction:dir], minY);
    if (bottom.x <= maxX && bottom.x >= minX) {
        if (withinRect) return bottom;
        if (valid1.x != valid1.x) valid1 = bottom;
        else valid2 = bottom;
    }
    CGPoint top = ccp([self xIntersectionForYLine:maxY withPoint:point direction:dir], maxY);
    if (top.x <= maxX && top.x >= minX) {
        if (withinRect) return top;
        if (valid1.x != valid1.x) valid1 = top;
        else valid2 = top;
    }

    if (valid1.x != valid1.x)
        NSLog(@"The point is not going to intersect the rect in any way!");
    // compare the distance between the two valid points
    if (SIGN(valid1.x - point.x) == SIGN(dir.x) || SIGN(valid1.y - point.y) == SIGN(dir.y)) {
        if (ccpDistance(valid1, point) > ccpDistance(valid2, point)) return valid2;
        return valid1;
    } else {
        if (ccpDistance(valid1, point) > ccpDistance(valid2, point)) return valid1;
        return valid2;
    }
}



@end