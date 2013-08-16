//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "SimpleBody.h"
#import "Mask.h"
#import "ContactListener.h"


typedef NS_ENUM(NSInteger , CollisionState) {
    CollisionStateInAir,
    CollisionStateOnGround,
    CollisionStateMax
};

@interface SimpleContactListener : ContactListener
@property(nonatomic, strong) Mask *wallMask;
@property(nonatomic) CGFloat restitution;
@property(nonatomic) CGPoint gravity;
@property(nonatomic, readonly) CollisionState currentCollisionState;

- (id)initWithGravity:(CGPoint)gravity wallMask:(Mask *)mask restitution:(CGFloat)restitution;

+ (id)collisionHandlerWithGravity:(CGPoint)gravity wallMask:(Mask *)mask restitution:(CGFloat)restitution;

- (BOOL)collidedWithWall;

@end