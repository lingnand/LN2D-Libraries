/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/



#import "World.h"
#include "b2World.h"

@class B2DBody;

typedef void(^B2DBodyCallBack)(B2DBody *);

@interface B2DWorld : World

@property (readonly) float ptmRatio;


+ (id)worldWithB2World:(b2World *)world;


- (b2Body *)createBody:(b2BodyDef *)def;

- (void)destroyBody:(b2Body *)body;

- (b2Vec2)b2Vec2FromCGPoint:(CGPoint)p;

- (b2Vec2)b2Vec2FromX:(float)x y:(float)y;

- (CGPoint)CGPointFromb2Vec2:(b2Vec2)p;
@end

