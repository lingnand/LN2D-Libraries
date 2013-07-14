/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/


#ifndef __Box2DEngine_H_
#define __Box2DEngine_H_

#include <iostream>
#include "b2Math.h"
#include "b2World.h"
#import "PhysicsEngine.h"

/**
 * The PTM_RATIO
 * Using it as a global variable is ugly but hiding it into
 * GB2Engine would slow down things too much.
 */
extern float PTM_RATIO;

/**
 * Convert b2Vec2 to CGPoint honoring PTM_RATIO
 */
inline b2Vec2 b2Vec2FromCGPoint(const CGPoint &p)
{
    return b2Vec2(p.x/PTM_RATIO, p.y/PTM_RATIO);
}

inline b2Vec2 b2Vec2FromCC(float x, float y)
{
    return b2Vec2(x/PTM_RATIO, y/PTM_RATIO);
}

/**
 * Convert CGPoint to b2Vec2 honoring PTM_RATIO
 */
inline CGPoint CGPointFromb2Vec2(const b2Vec2 &p)
{
    return CGPointMake(p.x * PTM_RATIO, p.y*PTM_RATIO);
}

@interface B2DEngine : PhysicsEngine

@property (readonly, assign) b2World* world;

/**
 * Delete all objects in the world
 * including the world
 */
- (void)deleteWorld;

/**
 * Delete all objects
 */
- (void)deleteAllObjects;


@end

#endif //__Box2DEngine_H_
