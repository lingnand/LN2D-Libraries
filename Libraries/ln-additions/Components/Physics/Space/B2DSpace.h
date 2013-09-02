/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/



#include "b2World.h"
#import "Space.h"
#import "B2DSpaceContactListener.h"

#define DEFAULT_PTM_RATIO 1.5
@class B2DRUBECache;
@class B2DBody;


@interface B2DSpace : Space

/** The B2DWorld is setup such that the world attribute will always be set
 * This is such that you don't need to deal with when b2world is not present */
// if ptmRatio changed and the world is enabled then it will automatically
// recalibrate everything in the next 'update' cycle; otherwise there's no
// need to change
@property(atomic) float ptmRatio;
@property(atomic) b2Vec2 physicalGravity;
@property(nonatomic, assign) B2DSpaceContactListener *spaceContactListener;


+ (id)spaceFromB2World:(b2World *)world;

+ (id)spaceWithB2World:(b2World *)world;

+ (id)spaceWitGravity:(CGPoint)gravity ptmRatio:(float)ptmRatio;

+ (id)spaceWithPhysicalGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio;

- (id)initWithGravity:(CGPoint)point ptmRatio:(float)ptmRatio;

- (id)initWithPhysicalGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio;

- (id)initWithB2World:(b2World *)world ptmRatio:(float)ptmRatio;

/** This can be overriden in the subclass to provide the implementation of
 * inflating the world with bodies */
- (void)addBodyForB2Body:(b2Body *)b;

- (B2DRUBECache *)cacheForThisSpaceWithFileName:(NSString *)name;
@end

// define some functions to transform the coordinates
NS_INLINE CGPoint CGPointFromb2Vec2(b2Vec2 p, B2DSpace *w) {
    float ptmRatio = w ? w.ptmRatio : DEFAULT_PTM_RATIO;
    return ccp(p.x * ptmRatio, p.y * ptmRatio);
}

NS_INLINE b2Vec2 b2Vec2FromCC(CGFloat x, CGFloat y, B2DSpace *w) {
    float ptmRatio = w ? w.ptmRatio : DEFAULT_PTM_RATIO;
    return b2Vec2(x / ptmRatio, y / ptmRatio);
}

NS_INLINE b2Vec2 b2Vec2FromCGPoint(CGPoint p, B2DSpace *w) {
    return b2Vec2FromCC(p.x, p.y, w);
}

NS_INLINE CGFloat CGLengthFromb2Length(float len, B2DSpace *w) {
    float ptmRatio = w ? w.ptmRatio : DEFAULT_PTM_RATIO;
    return len * ptmRatio;
}

NS_INLINE float b2LengthFromCGLength(CGFloat len, B2DSpace *w) {
    float ptmRatio = w ? w.ptmRatio : DEFAULT_PTM_RATIO;
    return len / ptmRatio;
}

