/*!
    @header B2DFixture
    @copyright LnStudio
    @updated 25/08/2013
    @author lingnan
*/

#import "B2DFixture_protected.h"
#import "CCComponent.h"
#import "B2DBody_protected.h"

@implementation B2DFixture {
    b2FixtureDef *_fixDef;
}

+ (id)fixtureFromB2Fixture:(b2Fixture *)fixture {
    if (!fixture)
        return nil;
    id b = (__bridge id) fixture->GetUserData();
    return [b isKindOfClass:[self class]] ? b : nil;
}

+ (id)fixtureWithB2Fixture:(b2Fixture *)fixture {
    return [[self alloc] initWithB2Fixture:fixture];
}

+ (id)fixture {
    return [self new];
}


- (id)initWithB2Fixture:(b2Fixture *)fixture {
    id f = [self.class fixtureFromB2Fixture:fixture];
    if (f) {
        self = f;
    } else if (self = [super init]) {
        self.fix = fixture;
    }
    return self;
}

- (void)setBody:(B2DBody *)body {
    if (body != _body) {
        // just route the request to next level up
        [_body removeFixture:self];
        [body addFixture:self];
    }
}

- (void)setBodyDirect:(B2DBody *)body {
    _body = body;
}

- (b2FixtureDef *)fixDef {
    if (!_fixDef)
        _fixDef = new b2FixtureDef();
    return _fixDef;
}

- (void)setFixDef:(b2FixtureDef *)fixDef {
    if (fixDef != _fixDef) {
        delete _fixDef;
        _fixDef = fixDef;
    }
}

/** the higher level (body) would be responsible for initiating all the
 * fixtures with the wrapper (so we wouldn't accidentally cause unwanted results)
  * */
- (B2DFixture *)next {
    return self.fix ? [B2DFixture fixtureFromB2Fixture:self.fix->GetNext()] : nil;
}

- (float)density {
    return self.fix ? self.fix->GetDensity() : self.fixDef->density;
}

- (void)setDensity:(float)density {
    if (self.fix)
        self.fix->SetDensity(density);
    else
        self.fixDef->density = density;
}

- (const b2Shape *)shape {
    return self.fix ? self.fix->GetShape() : self.fixDef->shape;
}

- (void)setShape:(b2Shape *)shape {
    if (self.fix) {
        b2FixtureDef *def = self.currentFixtureDef;
        def->shape = shape;
        // we only want to hotswap the fixture thus we don't want to remove / re-add
        // a fixture
        self.fix = self.body.body->CreateFixture(def);
        delete def;
    }
    else
        self.fixDef->shape = shape;
}

- (float)friction {
    return self.fix ? self.fix->GetFriction() : self.fixDef->friction;
}

- (void)setFriction:(float)friction {
    if (self.fix)
        self.fix->SetFriction(friction);
    else
        self.fixDef->friction = friction;
}

- (float)restitution {
    return self.fix ? self.fix->GetRestitution() : self.fixDef->restitution;
}

- (void)setRestitution:(float)restitution {
    if (self.fix)
        self.fix->SetRestitution(restitution);
    else
        self.fixDef->restitution = restitution;
}

- (BOOL)isSensor {
    return self.fix ? self.fix->IsSensor() : self.fixDef->isSensor;
}

- (void)setIsSensor:(BOOL)isSensor {
    if (self.fix)
        self.fix->SetSensor(isSensor);
    else
        self.fixDef->isSensor = isSensor;
}

- (b2Filter)filter {
    return self.fix ? self.fix->GetFilterData() : self.fixDef->filter;
}

- (void)setFilter:(b2Filter)filter {
    if (self.fix)
        self.fix->SetFilterData(filter);
    else
        self.fixDef->filter = filter;
}

- (void)bindB2Fixture:(b2Fixture *)fix toUserData:(void *)data {
    fix->SetUserData(data);
}

- (void)setFix:(b2Fixture *)fix {
    if (_fix != fix) {
        if (_fix) {
            [self bindB2Fixture:_fix toUserData:nil];
            // delete the old fix...?
            if (!fix)
                self.fixDef = self.currentFixtureDef;
        }
        _fix = fix;
        if (fix) {
            // we should check here if the body is already associated with
            // another B2DFixture object
            id f = [self.class fixtureFromB2Fixture:fix];
            if (f) {
                NSAssert([f isKindOfClass:[B2DFixture class]], @"the fixture is associated with some unknown class");
                ((B2DFixture *) f).fix = nil;
            }
            [self bindB2Fixture:fix toUserData:(__bridge void *)self];
            self.fixDef = nil;
        }
        if (!self.fixtureBodyInSync) {
            if (fix)
                // default to instantiate a B2DBody upper level
                self.body = [B2DBody bodyWithB2Body:fix->GetBody()];
            else
                self.body = nil;
        }
    }
}

- (BOOL)fixtureBodyInSync {
    return (!self.fix && !self.body.body) || ([B2DBody bodyFromB2Body:self.fix->GetBody()] == self.body);
}

- (b2FixtureDef *)currentFixtureDef {
    b2FixtureDef *def;
    if (self.fix) {
        NSAssert(!self.fixDef, @"Inconsistent states. FixDef should have been deleted if fix is present");
        def = new b2FixtureDef;
        def->friction = self.fix->GetFriction();
        def->shape = self.fix->GetShape();
        def->filter = self.fix->GetFilterData();
        def->density = self.fix->GetDensity();
        def->isSensor = self.fix->IsSensor();
        def->restitution = self.fix->GetRestitution();
    } else {
        def = self.fixDef;
    }
    return def;
}

- (id)copyWithZone:(NSZone *)zone {
    B2DFixture *copy = [[[self class] allocWithZone:zone] init];
    if (copy != nil) {
        if (self.fix)
            copy->_fixDef = self.currentFixtureDef;
        else
            copy->_fixDef = new b2FixtureDef(*(self.fixDef));
    }
    return copy;
}


@end