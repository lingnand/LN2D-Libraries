/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/



#include "b2World.h"
#import "World.h"
#import "B2DWorldContactListener.h"

#define DEFAULT_PTM_RATIO 1.5
@class B2DRUBECache;
@class B2DBody;


@interface B2DWorld : World

/** The B2DWorld is setup such that the world attribute will always be set
 * This is such that you don't need to deal with when b2world is not present */
// if ptmRatio changed and the world is enabled then it will automatically
// recalibrate everything in the next 'update' cycle; otherwise there's no
// need to change
@property (atomic) float ptmRatio;
@property (atomic) b2Vec2 physicalGravity;
@property (nonatomic, assign) B2DWorldContactListener *worldContactListener;


+ (id)worldFromB2World:(b2World *)world;

+ (id)worldWithB2World:(b2World *)world;

+ (id)worldWitGravity:(CGPoint)gravity ptmRatio:(float)ptmRatio;

+ (id)worldWithPhysicalGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio;

- (id)initWithGravity:(CGPoint)point ptmRatio:(float)ptmRatio;

- (id)initWithPhysicalGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio;

- (id)initWithB2World:(b2World *)world ptmRatio:(float)ptmRatio;

- (b2Vec2)b2Vec2FromCGPoint:(CGPoint)p;

- (b2Vec2)b2Vec2FromX:(float)x y:(float)y;

- (CGPoint)CGPointFromb2Vec2:(b2Vec2)p;

- (void)addBodyForB2Body:(b2Body *)b;

@end

