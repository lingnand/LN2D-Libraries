/*!
    @header World
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "Space_protected.h"
#import "Body.h"
#import "Body_protect.h"
#import "CCNode+LnAdditions.h"

@implementation Space
@dynamic gravity;

+ (id)space {
    return [self new];
}

- (Class)bodyClass {
    return [Body class];
}

- (void)componentAdded {
    // find all children bodies that might be working for this world;
    // only if this world is empty
    if (!self.bodies.count)
        // this will ensure undercutting -- that is, if you add a world at the outermost level
        // and you add another world at some intermediate level, then the bodies down that
        // intermediate level will be captured by this new world
        [self addEncompassingBodiesInNode:self.host];
}

- (void)addEncompassingBodiesInNode:(CCNode *)n {
    for (CCNode *c in n.children) {
        // we need to use the predicate to get all the components that matchs
        // the requirement
        [self addBody:[c.rootComponent childForClass:self.bodyClass]];
        // recurse downwards
        // if we already found suitable bodies in c, then we don't recurse down
        // -- we assume that the underlying nodes would be managed by the
        [self addEncompassingBodiesInNode:c];
    }
}

- (NSMutableSet *)bodies {
    if (!_bodies)
        _bodies = [NSMutableSet set];
    return _bodies;
}

/** returns whether or not this body is added successfully */
- (BOOL)addBody:(Body *)body {
    // adding a body is a mutual process: the world must be able to manage this body
    // and this body must be willing to be managed by this world
    if (![self isKindOfClass:body.spaceClass] || ![body isKindOfClass:self.bodyClass])
        return NO;

    if (body.space != self) {
        if (body.space)
            [body.space removeBody:body];
        // additional steps to manage the body..?
        [self onAddingNewBody:body];
        [self.bodies addObject:body];
        [body setWorldDirect:self];
    }
    return YES;
}

- (void)onAddingNewBody:(Body *)body {

}

- (BOOL)removeBody:(Body *)body {
    if (body.space != self)
        return NO;
    [self onRemovingBody:body];
    [self.bodies removeObject:body];
    [body setWorldDirect:nil];
    return YES;
}

- (void)onRemovingBody:(Body *)body {

}

- (NSSet *)allBodies {
    return self.bodies;
}

- (void)dealloc {
}

@end