/*!
    @header World
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "World_protected.h"
#import "Body.h"
#import "Body_protect.h"
#import "CCNode+LnAdditions.h"

@implementation World

+ (id)world {
    return [self new];
}

- (void)onAddComponent {
    // find all children bodies that might be working for this world;
    // only if this world is empty
    if (!self.bodies.count)
        [self addEncompassingBodiesInNode:self.host];
}

- (void)addEncompassingBodiesInNode:(CCNode *)n {
    for (CCNode *c in n.children) {
        // we need to use the predicate to get all the components that matchs
        // the requirement
        Body *b = [c.componentManager componentForClass:[Body class]];
        if ([self isKindOfClass:b.worldClass]) {
            b.world = self;
        }
        // recurse downwards
        [self addEncompassingBodiesInNode:c];
    }
}

- (NSMutableSet *)bodies {
    if (!_bodies)
        _bodies = [NSMutableSet set];
    return _bodies;
}

- (void)addBody:(Body *)body {
    if (body.world != self) {
        if (body.world)
            [body.world removeBody:body];
        [self.bodies addObject:body];
        [body setWorldDirect:self];
    }
}

- (void)removeBody:(Body *)body {
    if (body.world == self) {
        [self.bodies removeObject:body];
        [body setWorldDirect:nil];
    }
}

- (NSSet *)allBodies {
    return self.bodies;
}

- (void)dealloc {
}

@end