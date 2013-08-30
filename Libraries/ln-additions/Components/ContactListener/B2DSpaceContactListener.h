/*!
    @header B2DWorldContactListener
    @copyright LnStudio
    @updated 16/08/2013
    @author lingnan
*/


#ifndef __B2DWorldContactListener_H_
#define __B2DWorldContactListener_H_

#include <iostream>
#include "b2WorldCallbacks.h"


class B2DSpaceContactListener : public b2ContactListener
{
public:
    B2DSpaceContactListener();
    ~B2DSpaceContactListener();
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    void triggerHandlers(b2Contact *contact, SEL selector);
};


#endif //__B2DWorldContactListener_H_
