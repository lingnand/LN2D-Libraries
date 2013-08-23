/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/

#import "B2DWorld_protected.h"
#import "B2DRUBECache.h"

@implementation B2DWorld

/**
* Spec:
* The engine, while holding the reference to the world; should provide the necessary
* functions of the world in an obj-c way (essentially a wrapper)
*
* We'll have another loader class that's responsible for loading up the rube file and
* providing the information to the B2DEngine
*
* e.g:
* // the loader should be an immutable instance upon creation (each instance is specific to the file loaded)
* RUBELoader *loader = [RUBELoader loaderWithFile:@"file.rube"];
* // the body returned should already be wired to the correct instance of the engine
* B2DBody *pinballBody = [loader bodyWithKey:@"pinball"];
* pinball.body = pinballBody;
* // this way it seems that we don't even need to care about the wiring up of the world; but we do
* // need to pass the loader around; a better way might be integrating world with loader?
* // like this:
* B2DEngine *engine = [B2DEngine engineWithLoader:[Loader withFileName:@"filename"]];
* B2DBody *pinballBody = [engine.loader bodyWithKey:@"pinball"]
* // but this approach still risks of having the loader property set to another thing (or at least it seems)
* B2DEngine *engine = [B2DEngine engineWithRubeFile:@"filename"];
* B2DBody *pinballBody = [engine bodyWithKey:@"pinball"]
* // but it seems weird really.. to have loader operations on a *world*
*
*
* // still the first approach seems most sound to me; to improve the situation as passing *loader* around
* // we can rename it to something like RUBEWorldCache
*/

#define DEFAULT_PTM_RATIO 1.5

+ (id)worldWithB2World:(b2World *)world ptmRatio:(float)ptmRatio {
    return [[self alloc] initWithB2World:world ptmRatio:ptmRatio];
}

+ (NSMutableDictionary *)worldMap {
    static NSMutableDictionary *worldMap = nil;
    if (!worldMap) {
        worldMap = [NSMutableDictionary dictionary];
    }
    return worldMap;
}

+ (id)worldWithB2World:(b2World *)world {
    return [self worldWithB2World:world ptmRatio:DEFAULT_PTM_RATIO];
}


+ (id)worldWithGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio {
    return [[self alloc] initWithGravity:gravity ptmRatio:ptmRatio];
}

+ (id)worldFromB2World:(b2World *)world {
    id w = [self.class worldMap][[NSValue valueWithPointer:world]];
    return [w isKindOfClass:[self class]] ? w : nil;
}

- (id)initWithGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio {
    return [self initWithB2World:new b2World(gravity) ptmRatio:ptmRatio];
}

- (id)initWithB2World:(b2World *)world ptmRatio:(float)ptmRatio {
    // we should ensure that there's only ever one such world being initiated
    if (!(self = [self.class worldFromB2World:world]) && (self = [super init])) {
        // create a new world
        [self.class worldMap][[NSValue valueWithPointer:world]] = self;
        self.world = world;
        // set up the contact listener
        self.worldContactListener = new B2DWorldContactListener();
        self.world->SetContactListener(self.worldContactListener);
    }
    // defining PTM ratio
    self.ptmRatio = ptmRatio;
    return self;
}

- (b2Body *)createBody:(b2BodyDef *)def {
    if (def)
        return self.world->CreateBody(def);
    return nil;
}

- (void)destroyBody:(b2Body *)body {
    if (body)
        self.world->DestroyBody(body);
}

- (void)setWorld:(b2World *)world {
    if (world != _world) {
        // delete the old world
        delete _world;
        _world = world;
    }
}

- (void)setWorldContactListener:(B2DWorldContactListener *)worldContactListener {
    if (worldContactListener != _worldContactListener) {
        delete _worldContactListener;
        _worldContactListener = worldContactListener;
    }
}


/**
 * Convert b2Vec2 to CGPoint honoring ptmratio
 */
- (b2Vec2) b2Vec2FromCGPoint:(CGPoint)p {
    return b2Vec2(p.x/self.ptmRatio, p.y/self.ptmRatio);
}

- (b2Vec2) b2Vec2FromX:(float)x  y:(float)y {
    return b2Vec2(x/self.ptmRatio, y/self.ptmRatio);
}

/**
 * Convert CGPoint to b2Vec2 honoring self.ptmRatio
 */
- (CGPoint) CGPointFromb2Vec2:(b2Vec2)p {
    return CGPointMake(p.x * self.ptmRatio, p.y * self.ptmRatio);
}

- (void)dealloc {
    self.world = nil;
}

- (void)activate {
    [self scheduleUpdate];
}

- (void)deactivate {
    [self unscheduleUpdate];
}

- (void)update:(ccTime)step {
    const float32 timeStep = 1.0f / 30.0f;
    const int32 velocityIterations = 5;
    const int32 positionIterations = 1;

    // step the world
    self.world->Step(timeStep, velocityIterations, positionIterations);
}

- (void)iterateBodiesWithBlock:(B2DBodyCallback)callback {
    for (b2Body* b = self.world->GetBodyList(); b; b = b->GetNext()) {
        // get the object
        callback([B2DBody bodyFromB2Body:b]);
    }
}

- (B2DRUBECache *)cacheForThisWorldWithFileName:(NSString *)name {
    return [B2DRUBECache cacheForWorld:self WithFileName:name];
}



@end

