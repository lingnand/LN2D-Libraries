/*!
    @header B2DBody
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#include "B2DBody.h"
#import "B2DWorld.h"

@interface B2DBody()
@property (nonatomic, assign) b2BodyDef *bodyDef;
@property (nonatomic, assign) b2Body *body;
@end

@implementation B2DBody {
    b2BodyDef *_bodyDef;
}

+ (id)bodyWithB2Body:(b2Body *)body world:(B2DWorld *)world {
    B2DBody *b = [self bodyWithB2Body:body];
    b.world = world;
    return b;
}

+ (id)bodyWithB2Body:(b2Body *)body {
    // two situation
    // 1. if the b2body is already linked to a b2dbody
    B2DBody *b = [self bodyFromB2Body:body];
    if (!b) {
        b = [[self alloc] initWithB2Body:body];
    }
    return b;
}

+ (B2DBody *)bodyFromB2Body:(b2Body *)body {
    void *bu = body->GetUserData();
    B2DBody *b = nil;
    if (bu) {
        NSAssert([(__bridge id)bu isKindOfClass:[B2DBody class]], @"Unrecognized userdata (should be a B2DBody)");
        b = (__bridge id)bu;
    }
    return b;
}

- (id)initWithB2Body:(b2Body *)body {
    if (self = [super init]) {
        self.body = body;
    }
    return self;
}

- (void)setBody:(b2Body *)body {
    if (_body != body) {
        // make sure that the body's userdata points to myself
        // remove self from the old body
        [(B2DWorld *) self.world destroyBody:self.body];
        // should we delete the body?
        // get the current body def before setting body to nil
        self.bodyDef = self.currentBodyDef;
        if (body) {
            body->SetUserData((__bridge void *) self);
            self.bodyDef = nil;
        } else {
            self.bodyDef = self.currentBodyDef;
            // handle the fixtures ??
            // handle the joints ??
        }
        _body = body;
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

- (b2Vec2)position {
    return self.body ? _body->GetPosition() : self.bodyDef->position;
}

- (void)setPosition:(b2Vec2)position {
    if (self.body) {
        self.body->SetTransform(position, self.angle);
        // now applying the position change to the CC side as well
    } else {
        self.bodyDef->position = position;
    }
}

- (float)angle {
    return self.body ? self.body->GetAngle() : self.bodyDef->angle;
}

- (void)setAngle:(float)angle {
    if (self.body)
        self.body->SetTransform(self.position, angle);
    else
        self.bodyDef->angle = angle;
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

- (Class)worldClass {
    return [B2DWorld class];
}

- (void)worldChangedFrom:(World *)ow to:(World *)nw {
    [super worldChangedFrom:ow to:nw];
    // need to wire the internal body
    B2DWorld *o = (B2DWorld *) ow;
    B2DWorld *n = (B2DWorld *) nw;
    if (o && self.body) {
        self.body = nil;
    }
    if (n) {
        // get the def to add to the new world
        self.body = [n createBody:self.currentBodyDef];
    }

}

- (void)dealloc {
    self.bodyDef = nil;
}

- (b2BodyDef *)currentBodyDef {
    b2BodyDef *def;
    if (_body) {
        NSAssert(!self.bodyDef, @"Inconsistent states. BodyDef should have been deleted if body is present");
        def = new b2BodyDef();
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

#pragma mark - Operations

-(b2Fixture *) addFixture:(b2FixtureDef *)fixtureDef {
    return self.body ? self.body->CreateFixture(fixtureDef) : nil;
}

#pragma mark - Update
// 1. override position change details so that when ever a sprite's position
// is changed, it's equal to moving in the physical world
// we can achieve this through a KVO

- (void)enable {
    [super enable];
    [self.delegate addObserver:self
                    forKeyPath:@"position"
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context:nil];
}

- (void)disable {
    [super disable];
    [self.delegate removeObserver:self forKeyPath:@"position"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"position"]) {
        // first get the position relative to the world
        // set the relative position in the physical world
        self.body->SetTransform([(B2DWorld *)self.world b2Vec2FromCGPoint:self.positionInWorld], self.body->GetAngle());
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (CGPoint)positionInWorld {
    // transform the local coordinates into the world coordinates
    return CGPointApplyAffineTransform(self.delegate.position, self.delegateToWorldTransform);
}

/** return the transform from the local coordinates into the world coordinates
 * if there's no world indicated, the outermost world is chosen */
- (CGAffineTransform)delegateToWorldTransform {
    CGAffineTransform t = [self.delegate nodeToParentTransform];

    for (CCNode *p = self.delegate.parent; p != self.world.delegate; p = p.parent)
        t = CGAffineTransformConcat(t, [p nodeToParentTransform]);

    return t;
}

- (CGAffineTransform)worldToDelegateTransform {
    return CGAffineTransformInvert([self delegateToWorldTransform]);
}

- (void) updateCCFromPhysics {
    CGPoint ccpos = [(B2DWorld *)self.world CGPointFromb2Vec2:self.body->GetPosition()];
    self.delegate.position = CGPointApplyAffineTransform(ccpos, [self worldToDelegateTransform]);
    // this might not consider the relative rotation of layered relationships
    self.delegate.rotation = -1 * CC_RADIANS_TO_DEGREES(self.body->GetAngle());
}

@end
