/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/



#include "b2World.h"
#import "World.h"

@class B2DRUBECache;
@class B2DBody;


@interface B2DWorld : World

// if ptmRatio changed and the world is enabled then it will automatically
// recalibrate everything in the next 'update' cycle; otherwise there's no
// need to change
@property (atomic) float ptmRatio;


+ (id)worldWithB2World:(b2World *)world ptmRatio:(float)ptmRatio;

+ (id)worldWithB2World:(b2World *)world;

+ (id)worldFromB2World:(b2World *)world;

- (b2Vec2)b2Vec2FromCGPoint:(CGPoint)p;

- (b2Vec2)b2Vec2FromX:(float)x y:(float)y;

- (CGPoint)CGPointFromb2Vec2:(b2Vec2)p;

- (void)addBody:(B2DBody *)body;

- (void)removeBody:(B2DBody *)body;

- (void)addBodyForB2Body:(b2Body *)b;

@end

