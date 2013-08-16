/*!
    @header B2DBody
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/


#ifndef __B2DBody_H_
#define __B2DBody_H_

#include <iostream>
#import "Body.h"
#include "b2Math.h"
#include "b2Body.h"
#include "b2World.h"


// we'll preseve using the original b2d units and syntax
@interface B2DBody:Body

@property (nonatomic) b2Vec2 position;
@property (nonatomic) float angle;
@property (nonatomic) b2Vec2 linearVelocity;
@property (nonatomic) float angularVelocity;
@property (nonatomic) float linearDamping;
@property (nonatomic) float angularDamping;
@property (nonatomic) BOOL allowSleep;
@property (nonatomic) BOOL awake;
@property (nonatomic) BOOL fixedRotation;
@property (nonatomic) BOOL bullet;
@property (nonatomic) BOOL active;
@property (nonatomic) float gravityScale;

+ (id)bodyWithB2Body:(b2Body *)body world:(B2DWorld *)world;

+ (id)bodyWithB2Body:(b2Body *)body;

+ (B2DBody *)bodyFromB2Body:(b2Body *)body;

- (void)updateCCFromPhysics;
@end


#endif //__B2DBody_H_
