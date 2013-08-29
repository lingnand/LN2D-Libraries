#include "B2DWorldContactListener.h"
#include "b2Contact.h"
#import "CCComponent.h"
#import "B2DBody.h"
#import "B2DContactListener.h"
#import "CCNode+LnAdditions.h"

/*!
    @header B2DWorldContactListener
    @copyright LnStudio
    @updated 16/08/2013
    @author lingnan
*/

B2DWorldContactListener::B2DWorldContactListener() : b2ContactListener() {

}

B2DWorldContactListener::~B2DWorldContactListener() {

}

/// Called when two fixtures begin to touch.
void B2DWorldContactListener::BeginContact(b2Contact *contact) {
    triggerHandlers(contact, @selector(beginContact:));
}

/// Called when two fixtures cease to touch.
void B2DWorldContactListener::EndContact(b2Contact *contact) {
    triggerHandlers(contact, @selector(endContact:));
}

/// This is called after a contact is updated. This allows you to inspect a
/// contact before it goes to the solver. If you are careful, you can modify the
/// contact manifold (e.g. disable contact).
/// A copy of the old manifold is provided so that you can detect changes.
/// Note: this is called only for awake bodies.
/// Note: this is called even when the number of contact points is zero.
/// Note: this is not called for sensors.
/// Note: if you set the number of contact points to zero, you will not
/// get an EndContact callback. However, you may get a BeginContact callback
/// the next step.
void B2DWorldContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
    B2_NOT_USED(contact);
    B2_NOT_USED(oldManifold);
    triggerHandlers(contact, @selector(preSolve:));
}

/// This lets you inspect a contact after the solver is finished. This is useful
/// for inspecting impulses.
/// Note: the contact manifold does not include time of impact impulses, which can be
/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
/// in a separate data structure.
/// Note: this is only called for contacts that are touching, solid, and awake.
void B2DWorldContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
    B2_NOT_USED(contact);
    B2_NOT_USED(impulse);
    triggerHandlers(contact, @selector(postSolve:));
}

void B2DWorldContactListener::triggerHandlers(b2Contact *contact, SEL selector) {
    b2Fixture *aFixture = contact->GetFixtureA();
    B2DBody *a = [B2DBody bodyFromB2Body:aFixture->GetBody()];
    b2Fixture *bFixture = contact->GetFixtureB();
    B2DBody *b = [B2DBody bodyFromB2Body:bFixture->GetBody()];
    // find the collisionhandler and trigger it
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [a.contactListener performSelector:selector withObject:[B2DContact contactWithBody:a otherBody:b ownFixture:aFixture otherFixture:bFixture b2Contact:contact]];
    [b.contactListener performSelector:selector withObject:[B2DContact contactWithBody:b otherBody:a ownFixture:bFixture otherFixture:aFixture b2Contact:contact]];
#pragma clang diagnostic pop
}
