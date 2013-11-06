/*!
    @header B2DBody
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DBody_protected.h"
#import "B2DSpace_protected.h"
#import "b2Fixture.h"
#import "B2DFixture_protected.h"
#import "B2DContactListener.h"

@interface B2DBody ()
@property(nonatomic, strong) NSArray *monitoredNodes;
@end

@implementation B2DBody {
    b2BodyDef *_bodyDef;
    BOOL inUpdateLoop;
}


+ (id)bodyWithB2Body:(b2Body *)body {
    return [[self alloc] initWithB2Body:body];
}

+ (id)bodyFromB2Body:(b2Body *)body {
    if (!body)
        return nil;
    id b = (__bridge id) body->GetUserData();
    return [b isKindOfClass:[self class]] ? b : nil;
}

- (id)initWithB2Body:(b2Body *)body {
    NSAssert(body, @"Cannot initialize a B2DBody with a NULL b2Body pointer");
    id b = [self.class bodyFromB2Body:body];
    if (b) {
        self = b;
    } else if (self = [super init]) {
        self.body = body;
    }
    return self;
}

- (void)bindB2Body:(b2Body *)body toUserData:(void *)data {
    body->SetUserData(data);
}

- (void)enumerateFixturesInB2Body:(b2Body *)body withBlock:(void (^)(b2Fixture *fixture))block {
    b2Fixture *fix = body->GetFixtureList();
    while (fix) {
        block(fix);
        fix = fix->GetNext();
    }
}

- (void)setBody:(b2Body *)body {
    if (_body != body) {
        if (_body) {
            [self bindB2Body:_body toUserData:nil];
            // should we loop through all the fixture defs and set the userdata to nil?

            // should we destroy the body?
//            [(B2DWorld *) self.world destroyBody:_body];
            // should we delete the body?
            // delete _body;
            // save the bodyDef if the body is going to be niled.
            if (!body) {
                self.bodyDef = self.currentBodyDef;
            }
            // we need to nil all the fixtures
            for (B2DFixture *fix in self.fixtures) {
                fix.fix = nil;
            }
        }
        _body = body;
        if (body) {
            // we should check here if the body is already associated with
            // another B2DBody object
            id b = [self.class bodyFromB2Body:body];
            if (b) {
                NSAssert([b isKindOfClass:[B2DBody class]], @"the body is associated with some unknown class");
                ((B2DBody *)b).body = nil;
            }
            [self bindB2Body:body toUserData:(__bridge void *)self];
            self.bodyDef = nil;

            if (body->GetFixtureList()) {
                // if the body has fixtures; then that will override
                // the existing fixtures
                [self.fixtures removeAllObjects];
                // convert all the fixtures in the body into cached fixtures..
                [self enumerateFixturesInB2Body:body withBlock:^(b2Fixture *fixture) {
                    // add the fixture into self
                    // these steps will automatically wire up with top structure
                    [B2DFixture fixtureWithB2Fixture:fixture];
                }];
            } else {
                // add all the current fixtures
                for (B2DFixture *fix in self.fixtures)
                    fix.fix = self.body->CreateFixture(fix.currentFixtureDef);
            }
        }
        if (!self.bodySpaceInSync) {
            // default to instantiate a B2DWorld upper level
            if (body)
                self.space = [B2DSpace spaceWithB2World:body->GetWorld()];
            else
                self.space = nil;
        }
    }
}

- (b2BodyDef *)bodyDef {
    if (!_bodyDef)
        _bodyDef = new b2BodyDef();
    return _bodyDef;
}

- (void)setBodyDef:(b2BodyDef *)bodyDef {
    if (bodyDef != _bodyDef) {
       // delete the old bodyDef
        delete _bodyDef;
        _bodyDef = bodyDef;
    }
}

/** type information */

- (b2BodyType)type {
    return self.body ? self.body->GetType() : self.bodyDef->type;
}

- (void)setType:(b2BodyType)type {
    if (self.body) {
        self.body->SetType(type);
    } else {
        self.bodyDef->type = type;
    }
}

- (CGPoint)position {
    return CGPointApplyAffineTransform(self.spacePosition, self.spaceToHostParentTransform);
}

- (void)setPosition:(CGPoint)position {
    // first get the position relative to the world
    // set the relative position in the physical world
    self.spacePosition = CGPointApplyAffineTransform(position, self.hostParentToSpaceTransform);
}

- (CGPoint)spacePosition {
    return CGPointFromb2Vec2(self.spacePhysicalPosition, self.space);
}

- (void)setSpacePosition:(CGPoint)spacePosition {
    self.spacePhysicalPosition = b2Vec2FromCGPoint(spacePosition, self.space);
}

- (b2Vec2)spacePhysicalPosition {
    return self.body ? _body->GetPosition() : self.bodyDef->position;
}

- (void)setSpacePhysicalPosition:(b2Vec2)spacePhysicalPosition {
    if (self.body) {
        self.body->SetTransform(spacePhysicalPosition, self.angle);
    } else {
        self.bodyDef->position = spacePhysicalPosition;
    }
}

- (float)rotation {
    float rot = -CC_RADIANS_TO_DEGREES(self.angle);
    for (CCNode *p = self.host.parent; p && p != self.space.host; p = p.parent) {
        rot -= p.rotation;
    }
    return rot;
    // need to convert to normal form
//    int sign = SIGN(rot);
//    float mag = ABS(rot);
//    while (mag >= 360)
//        mag -= 360;
//    return sign * mag;
}

- (void)setRotation:(float)rotation {
    // need to calculate all the rotation
    for (CCNode *p = self.host.parent; p && p != self.space.host; p = p.parent) {
        rotation += p.rotation;
    }
    self.angle = - CC_DEGREES_TO_RADIANS(rotation);
}

- (float)angle {
    return self.body ? self.body->GetAngle() : self.bodyDef->angle;
}

- (void)setAngle:(float)angle {
    if (self.body)
        self.body->SetTransform(self.spacePhysicalPosition, angle);
    else
        self.bodyDef->angle = angle;
}

- (CGPoint)velocity {
    return CGPointVectorApplyAffineTransform(self.spaceVelocity, self.spaceToHostParentTransform);
}

- (void)setVelocity:(CGPoint)velocity {
    self.spaceVelocity = CGPointVectorApplyAffineTransform(velocity, self.hostParentToSpaceTransform);
}

// velocity in the CC sense
- (CGPoint)spaceVelocity {
    return CGPointFromb2Vec2(self.linearVelocity, self.space);
}

- (void)setSpaceVelocity:(CGPoint)velocity {
    self.linearVelocity = b2Vec2FromCGPoint(velocity, self.space);
}

- (b2Vec2)linearVelocity {
    return self.body ? self.body->GetLinearVelocity() : self.bodyDef->linearVelocity;
}

- (void)setLinearVelocity:(b2Vec2)linearVelocity {
    if (self.body)
        self.body->SetLinearVelocity(linearVelocity);
    else
        self.bodyDef->linearVelocity = linearVelocity;
}

- (float)angularVelocity {
    return self.body ? self.body->GetAngularVelocity() : self.bodyDef->angularVelocity;
}

- (void)setAngularVelocity:(float)angularVelocity {
    if (self.body)
        self.body->SetAngularVelocity(angularVelocity);
    else
        self.bodyDef->angularVelocity = angularVelocity;
}

- (float)linearDamping {
    return self.body ? self.body->GetLinearDamping() : self.bodyDef->linearDamping;
}

- (void)setLinearDamping:(float)linearDamping {
    if (self.body)
        self.body->SetLinearDamping(linearDamping);
    else
        self.bodyDef->linearDamping = linearDamping;
}

- (float)angularDamping {
    return self.body ? self.body->GetAngularDamping() : self.bodyDef->angularDamping;
}

- (void)setAngularDamping:(float)angularDamping {
    if (self.body)
        self.body->SetAngularDamping(angularDamping);
    else
        self.bodyDef->angularDamping = angularDamping;
}

- (BOOL)allowSleep {
    return self.body ? self.body->IsSleepingAllowed() : self.bodyDef->allowSleep;
}

- (void)setAllowSleep:(BOOL)allowSleep {
    if (self.body)
        self.body->SetSleepingAllowed(allowSleep);
    else
        self.bodyDef->allowSleep = allowSleep;
}

- (BOOL)awake {
    return self.body ? self.body->IsAwake() : self.bodyDef->awake;
}

- (void)setAwake:(BOOL)awake {
    if (self.body)
        self.body->SetAwake(awake);
    else
        self.bodyDef->awake = awake;
}

- (BOOL)fixedRotation {
    return self.body ? self.body->IsFixedRotation() : self.bodyDef->fixedRotation;
}

- (void)setFixedRotation:(BOOL)fixedRotation {
    if (self.body)
        self.body->SetFixedRotation(fixedRotation);
    else
        self.bodyDef->fixedRotation = fixedRotation;
}

- (BOOL)bullet {
    return self.body ? self.body->IsBullet() : self.bodyDef->bullet;
}

- (void)setBullet:(BOOL)bullet {
    if (self.body)
        self.body->SetBullet(bullet);
    else
        self.bodyDef->bullet = bullet;
}

- (BOOL)active {
    return self.body ? self.body->IsActive() : self.bodyDef->active;
}

- (void)setActive:(BOOL)active {
    if (self.body)
        self.body->SetActive(active);
    else
        self.bodyDef->active = active;
}

- (float)gravityScale {
    return self.body ? self.body->GetGravityScale() : self.bodyDef->gravityScale;
}

- (void)setGravityScale:(float)gravityScale {
    if (self.body)
        self.body->SetGravityScale(gravityScale);
    else
        self.bodyDef->gravityScale = gravityScale;
}

- (BOOL)bodySpaceInSync {
   return (!self.body && !self.space) || ([B2DSpace spaceFromB2World:self.body->GetWorld()] == self.space);
}

- (void)dealloc {
    self.bodyDef = nil;
    self.body = nil;
}

- (b2BodyDef *)currentBodyDef {
    b2BodyDef *def;
    if (self.body) {
        NSAssert(!self.bodyDef, @"Inconsistent states. BodyDef should have been deleted if body is present");
        def = new b2BodyDef();
        def->type = _body->GetType();
        def->position = _body->GetPosition();
        def->angle = _body->GetAngle();
        def->linearVelocity = _body->GetLinearVelocity();
        def->angularVelocity = _body->GetAngularVelocity();
        def->linearDamping = _body->GetLinearDamping();
        def->angularDamping = _body->GetAngularDamping();
        def->allowSleep = _body->IsSleepingAllowed();
        def->awake = _body->IsAwake();
        def->fixedRotation = _body->IsFixedRotation();
        def->bullet = _body->IsBullet();
        def->active = _body->IsActive();
        def->gravityScale = _body->GetGravityScale();
    } else {
        def = self.bodyDef;
    }
    return def;
}

#pragma mark - Fixture Operations

-(void) addFixture:(B2DFixture *)fixture {
    // check if the fixture is already part of the body.. ?
    if (fixture.body != self) {
        if (fixture.body)
            [fixture.body removeFixture:fixture];
        //// setting the delegate
        [fixture setBodyDirect:self];
        //// setting the fix
        // sync the fixture and body definition within
        if (self.body) {
            if (!fixture.fix || self.body != fixture.fix->GetBody()) {
                fixture.fix = self.body->CreateFixture(fixture.currentFixtureDef);
            }
        } else {
            fixture.fix = nil;
        }
        // save this fixture in a set
        [self.fixtures addObject:fixture];
    }
}

-(void) removeFixture:(B2DFixture *)fixture {
    if (fixture.body == self) {
        // remove the fixture from the body
        if (self.body)
            self.body->DestroyFixture(fixture.fix);
        //// setting the delegate
        [fixture setBodyDirect:nil];
        //// setting fix
        // we also need to set the fixture.fix to nil
        // as an fix instance without a body would be meaningless
        fixture.fix = nil;
        [self.fixtures removeObject:fixture];
    }
}

- (NSMutableSet *)fixtures {
    if (!_fixtures)
        _fixtures = [NSMutableSet set];
    return _fixtures;
}

- (NSSet *)allFixtures {
    return self.fixtures;
}

#pragma mark - Update

- (BOOL)activated {
    return [super activated] && self.body != nil;
}

+ (NSSet *)keyPathsForValuesAffectingActivated {
    NSMutableSet *set = [NSMutableSet setWithSet:[super keyPathsForValuesAffectingActivated]];
    [set addObject:@"body"];
    return set;
}

// NOTE: if you change the node hierarchy after adding the component then there's no way to
// monitor the changes in the parents
// in that case you have to deactivate and activate it again
- (void)componentActivated {
    [super componentActivated];
    // we didn't add the Initial option because the b2body position has a higher priority
    // monitor the whole hierarchy of nodes
    self.monitoredNodes = [self.hostAncestorsUnderSpace arrayByAddingObject:self.host];
}

- (void)componentDeactivated {
    [super componentDeactivated];
    self.monitoredNodes = nil;
}

- (void)setMonitoredNodes:(NSArray *)monitoredNodes {
    // first remove observer for all existing nodes
    for (CCNode *n in _monitoredNodes) {
        [n removeObserver:self forKeyPath:@"position"];
        [n removeObserver:self forKeyPath:@"rotation"];
    }
    _monitoredNodes = monitoredNodes;
    for (CCNode *n in monitoredNodes) {
        [n addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [n addObserver:self forKeyPath:@"rotation" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

#pragma mark - Contact Listener

- (B2DContactListener *)contactListener {
    if (!_contactListener)
        _contactListener = [B2DContactListener listener];
    return _contactListener;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!inUpdateLoop) {
        if ([keyPath isEqualToString:@"position"]) {
            CGPoint op = [change[NSKeyValueChangeOldKey] CGPointValue];
            CGPoint np = [change[NSKeyValueChangeNewKey] CGPointValue];
            if (op.x != np.x || op.y != np.y)
                self.position = self.host.position;
        }
        else if ([keyPath isEqualToString:@"rotation"]) {
            if ([change[NSKeyValueChangeOldKey] floatValue] != [change[NSKeyValueChangeNewKey] floatValue]) {
                self.rotation = self.host.rotation;
                // position might change as well
                self.position = self.host.position;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)updateHost {
    if (self.activated) {
        self.host.position = self.position;
        self.host.rotation = self.rotation;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    B2DBody *copy = (B2DBody *) [super copyWithZone:zone];

    if (copy != nil) {
        if (self.body)
            // this currentBodyDef will be a newly allocated BodyDef
            copy->_bodyDef = self.currentBodyDef;
        else
            // we need to copy the BodyDef
            copy->_bodyDef = new b2BodyDef(*(self.bodyDef));
        copy->_fixtures = [[NSMutableSet alloc] initWithSet:self.fixtures copyItems:YES];
    }

    return copy;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@"; b2body pointer = %p", self.body];
}

@end
