/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/

#include "B2DEngine.h"

// default ptm ratio value
float PTM_RATIO = 32.0f;

@implementation B2DEngine


- (id)initWithGravity:(b2Vec2)gravity {
    self = [super init];
    if (self) {
        _world = new b2World(gravity);
        // defining PTM ratio??

        // set up the contact listener

        [self scheduleUpdate];
    }

    return self;
}

@end

