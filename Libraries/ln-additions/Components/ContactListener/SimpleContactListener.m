//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "SimpleContactListener.h"
#import "CCNode+LnAdditions.h"
#import "Utilities.h"


#define TIME_STAY_LIMIT 0.5
#define DEFAULT_GRAVITY (ccp(0, 100))
#define DEFAULT_RESTITUTION 160

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

- (id)init {
    return [self initWithGravity:DEFAULT_GRAVITY wallMask:nil restitution:DEFAULT_RESTITUTION];
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
    Body *b = self.host.body;
    NSAssert(!b || [b isKindOfClass:[SimpleBody class]], @"SimpleCollisionHandler depends on a simple body");
    return (SimpleBody *) b;
}

// the person is considered inAir if he hasn't collided with anything in the past 2 second
- (void)update:(ccTime)delta {
    self.host.body.velocity = ccpAdd(self.host.body.velocity, ccpMult(self.gravity, delta));

    // the displacement of the player
    CGPoint ds = ccpMult(self.host.body.velocity, delta);
    // this is the actual displacement of the character in the world coordinate
    CGPoint actual_ds = ccpMult(self.delegateBody.worldVelocity, delta);
    CGPoint actual_ds_direction = ccpDirection(actual_ds);
    CGPoint actual_ds_mag = ccpMagnitude(actual_ds);

    CGPoint collideVec = ccp(0, 0);
    // first adjust the x direction
    self.host.position = ccpAdd(self.host.position, ccp(ds.x, 0));
    while (self.contactWithWall && actual_ds_mag.x > 0) {
//        CCLOG(@"Collided");
        collideVec.x = 1;
        self.host.position = ccpAdd(self.host.position, ccp(-actual_ds_direction.x * self.restitution, 0));
        actual_ds_mag.x -= self.restitution;
    }
    // then adjust the y direction
    self.host.position = ccpAdd(self.host.position, ccp(0, ds.y));
    while (self.contactWithWall && actual_ds_mag.y > 0) {
//        CCLOG(@"Collided");
        collideVec.y = 1;
        self.host.position = ccpAdd(self.host.position, ccp(0, -actual_ds_direction.y * self.restitution));
        actual_ds_mag.y -= self.restitution;
    }
//        CCLOG(@"#########Collided!");
    self.host.body.velocity = ccp(self.host.body.velocity.x * !collideVec.x, self.host.body.velocity.y * !collideVec.y);

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
    return [self.host.mask intersects:self.wallMask];
}



@end