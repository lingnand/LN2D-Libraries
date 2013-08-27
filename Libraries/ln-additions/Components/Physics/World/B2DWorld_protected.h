#import "World_protected.h"
#import "B2DWorld.h"
#import "B2DWorldContactListener.h"

@interface B2DWorld()
@property (nonatomic, assign) b2World *world;
@property (nonatomic, assign) B2DWorldContactListener *worldContactListener;
@end

