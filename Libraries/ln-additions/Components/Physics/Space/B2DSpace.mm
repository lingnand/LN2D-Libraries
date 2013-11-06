/*!
    @header Box2DEngine
    @copyright LnStudio
    @updated 11/07/2013
    @author lingnan
*/

#import "B2DSpace_protected.h"
#import "Body_protect.h"
#import "B2DBody_protected.h"
#import "B2DRUBECache.h"
#import "CCNode+LnAdditions.h"

@implementation B2DSpace {
    B2DSpaceContactListener *_spaceContactListener;
}

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

+ (NSMutableDictionary *)spaceMap {
    static NSMutableDictionary *spaceMap = nil;
    if (!spaceMap) {
        spaceMap = [NSMutableDictionary dictionary];
    }
    return spaceMap;
}

+ (id)spaceWithB2World:(b2World *)world {
    return [[self alloc] initWithB2World:world ptmRatio:DEFAULT_PTM_RATIO];
}

+ (id)spaceFromB2World:(b2World *)world {
    id w = [self spaceMap][[NSValue valueWithPointer:(void *) world]];
    return [w isKindOfClass:[self class]] ? w : nil;
}

+ (id)spaceWitGravity:(CGPoint)gravity ptmRatio:(float)ptmRatio {
    return [[self alloc] initWithGravity:gravity ptmRatio:ptmRatio];
}

- (id)initWithGravity:(CGPoint)point ptmRatio:(float)ptmRatio {
    return [self initWithPhysicalGravity:b2Vec2(point.x / ptmRatio, point.y / ptmRatio) ptmRatio:ptmRatio];
}

+ (id)spaceWithPhysicalGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio {
    return [[self alloc] initWithPhysicalGravity:gravity ptmRatio:ptmRatio];
}

- (id)initWithPhysicalGravity:(b2Vec2)gravity ptmRatio:(float)ptmRatio {
    return [self initWithB2World:new b2World(gravity) ptmRatio:ptmRatio];
}

- (id)init {
    return [self initWithGravity:DEFAULT_GRAVITY ptmRatio:DEFAULT_PTM_RATIO];
}

/** Designated initializer */
- (id)initWithB2World:(b2World *)world ptmRatio:(float)ptmRatio {
    // we should ensure that there's only ever one such world being initiated
    id w = [self.class spaceFromB2World:world];
    if (w) {
        self = w;
    } else if (self = [super init]) {
        self.world = world;
        // defining PTM ratio
        self.ptmRatio = ptmRatio;
    }
    return self;
}

- (Class)bodyClass {
    return [B2DBody class];
}

- (void)setGravity:(CGPoint)gravity {
    self.physicalGravity = b2Vec2FromCGPoint(gravity, self);
}

- (CGPoint)gravity {
    return CGPointFromb2Vec2(self.physicalGravity, self);
}

- (void)setPhysicalGravity:(b2Vec2)physicalGravity {
    self.world->SetGravity(physicalGravity);
}

- (b2Vec2)physicalGravity {
    return self.world->GetGravity();
}

- (void)setWorld:(b2World *)world {
    if (world != _world) {
        // delete the old world
        if (_world) {
            [self.class spaceMap][[NSValue valueWithPointer:_world]] = nil;
            for (Body *b in self.allBodies) {
                b.space = nil;
            }
            delete _world;
        }
        _world = world;
        NSValue *value = [NSValue valueWithPointer:world];
        // create a new world
        id ow = [self.class spaceMap][value];
        [self.class spaceMap][value] = self;
        if (ow) {
            NSAssert([ow isKindOfClass:[B2DSpace class]], @"the world is associated with some unknown class");
            // 1. set the delegate pointer that's all
            for (Body *b in ow) {
                [b setWorldDirect:self];
            }
            // 2. remove all the components
            [((Space *) ow).bodies removeAllObjects];
        } else {
            // inflate the new world with B2DBody..
            [self refreshBodies];
        }
        // reset up the contact listener
        world->SetContactListener(self.spaceContactListener);
    }
}

// readd the b2bodies into the space's b2dbody list
- (void)refreshBodies {
    b2Body *b = self.world->GetBodyList();
    while (b) {
        // add the body
        [self addBodyForB2Body:b];
        b = b->GetNext();
    }
}

- (void)addBodyForB2Body:(b2Body *)b {
    [B2DBody bodyWithB2Body:b];
}

- (B2DSpaceContactListener *)spaceContactListener {
    if (!_spaceContactListener)
        self.spaceContactListener = new B2DSpaceContactListener();
    return _spaceContactListener;
}

- (void)setSpaceContactListener:(B2DSpaceContactListener *)spaceContactListener {
    if (spaceContactListener != _spaceContactListener) {
        delete _spaceContactListener;
        _spaceContactListener = spaceContactListener;
        self.world->SetContactListener(spaceContactListener);
    }
}

- (void)dealloc {
    self.world = nil;
    self.spaceContactListener = nil;
}

- (void)componentActivated {
    [super componentActivated];
    [self scheduleUpdate];
}

- (void)componentDeactivated {
    [super componentDeactivated];
    [self unscheduleUpdate];
}

- (void)update:(ccTime)step {
//    NSLog(@"timestep = %f", step);
//    const float32 timeStep = 1.0f / 60.0f;
//    const float32 timeStep = step / 5000.0f;
    const int32 velocityIterations = 8;
    const int32 positionIterations = 1;

    // step the world
    self.world->Step(step, velocityIterations, positionIterations);

    // update the position for all the bodies within
    // set the inupdateloop property for all the bodies
    [self.allBodies setValue:[NSNumber numberWithBool:YES] forKey:@"inUpdateLoop"];
    [self updatePositionForNode:self.host markSet:[[self.allBodies valueForKey:@"host"] mutableCopy]];
    [self.allBodies setValue:[NSNumber numberWithBool:NO] forKey:@"inUpdateLoop"];
}

- (void)updatePositionForNode:(CCNode *)n markSet:(NSMutableSet *)set {
    if (set.count == 0)
        return;
    if ([set containsObject:n]) {
        // get the corresponding b2d instance
        B2DBody *body = [n.rootComponent childForClass:[B2DBody class]];
        [body updateHost];
        [set removeObject:n];
    }
    for (CCNode *c in n.children) {
        [self updatePositionForNode:c markSet:set];
    }
}

#pragma mark - Override the addComponent and removeComponent to add B2D specific processings

- (void)onAddingNewBody:(B2DBody *)body {
    // we need to check for more accurate assigning
    if (!body.body || body.body->GetWorld() != self.world) {
        // we need to create the body
        body.body = self.world->CreateBody(body.currentBodyDef);
    }
}

- (void)onRemovingBody:(B2DBody *)body {
    self.world->DestroyBody(body.body);
    // we also need to nil the body as a B2DBody not connected with
    // any world would be funny to have a dangling b2body with it
    body.body = nil;
}

- (B2DRUBECache *)cacheForThisSpaceWithFileName:(NSString *)name {
    return [B2DRUBECache cacheForSpace:self withFileName:name];
}
@end

