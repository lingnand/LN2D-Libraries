//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "SimpleContactListener.h"
#import "CCNode+LnAdditions.h"
#import "Utilities.h"


#define TIME_STAY_LIMIT 0.5

@interface SimpleContactListener ()
@property(nonatomic) ccTime elapsed;
@end

@implementation SimpleContactListener {
}

+ (id)listenerWithGravity:(CGPoint)gravity wallMask:(Mask *)mask restitution:(CGFloat)restitution {
    return [[self alloc] initWithGravity:gravity wallMask:mask restitution:restitution];
}

- (id)initWithGravity:(CGPoint)gravity wallMask:(Mask *)mask restitution:(CGFloat)restitution {
    self = [super init];
    if (self) {
        self.gravity = gravity;
        self.wallMask = mask;
        self.restitution = restitution;
    }
    return self;
}

- (void)onAddComponent {
    // check for compatibility of the mover class
    _currentContactState = self.contactWithWall ? ContactStateOnGround : ContactStateInAir;
    [self scheduleUpdate];
}

- (void)onRemoveComponent {
    [self unscheduleUpdate];
}

- (SimpleBody *)delegateBody {
    Body *b = self.delegate.body;
    NSAssert(!b || [b isKindOfClass:[SimpleBody class]], @"SimpleCollisionHandler depends on a simple body");
    return (SimpleBody *) b;
}

// the person is considered inAir if he hasn't collided with anything in the past 2 second
- (void)update:(ccTime)delta {
    self.delegate.velocity = ccpAdd(self.delegate.velocity, ccpMult(self.gravity, delta));

    // the displacement of the player
    CGPoint ds = ccpMult(self.delegate.velocity, delta);
    // this is the actual displacement of the character in the world coordinate
    CGPoint actual_ds = ccpMult(self.delegateBody.actualVelocity, delta);
    CGPoint actual_ds_direction = ccpDirection(actual_ds);
    CGPoint actual_ds_mag = ccpMagnitude(actual_ds);

    CGPoint collideVec = ccp(0, 0);
    // first adjust the x direction
    self.delegate.position = ccpAdd(self.delegate.position, ccp(ds.x, 0));
    while (self.contactWithWall && actual_ds_mag.x > 0) {
//        CCLOG(@"Collided");
        collideVec.x = 1;
        self.delegate.position = ccpAdd(self.delegate.position, ccp(-actual_ds_direction.x * self.restitution, 0));
        actual_ds_mag.x -= self.restitution;
    }
    // then adjust the y direction
    self.delegate.position = ccpAdd(self.delegate.position, ccp(0, ds.y));
    while (self.contactWithWall && actual_ds_mag.y > 0) {
//        CCLOG(@"Collided");
        collideVec.y = 1;
        self.delegate.position = ccpAdd(self.delegate.position, ccp(0, -actual_ds_direction.y * self.restitution));
        actual_ds_mag.y -= self.restitution;
    }
//        CCLOG(@"#########Collided!");
    self.delegate.velocity = ccp(self.delegate.velocity.x * !collideVec.x, self.delegate.velocity.y * !collideVec.y);

    if (collideVec.x || collideVec.y) {
        self.elapsed = 0;
        _currentContactState = ContactStateOnGround;
    } else {
        self.elapsed += delta;
        if (self.elapsed > TIME_STAY_LIMIT) {
            _currentContactState = ContactStateInAir;
        }
    }
}

- (BOOL)contactWithWall {
    return [self.delegate.mask intersects:self.wallMask];
}



@end