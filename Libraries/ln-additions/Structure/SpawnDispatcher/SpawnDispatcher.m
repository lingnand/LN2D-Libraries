//
// Created by knight on 05/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "PeriodicSpawnDispatcher.h"
#import "CCNode+LnAdditions.h"

@interface SpawnDispatcher ()
@end

@implementation SpawnDispatcher {
}

- (id)initWithTagSet:(NSIndexSet *)indexSet {
    self = [super init];
    if (self) {
        self.tagSet = indexSet;
    }
    return self;
}

- (id <RespawnableObject>)spawnInactiveInstance {
    NSArray *instances = self.instances;
    int start = randomInt(instances.count);
    for (NSUInteger i = (NSUInteger) start; i < start + instances.count; i++) {
        id<RespawnableObject> child = instances[i % instances.count];
        if (child.respawnable) {
            [child respawn];
            return child;
        }
    }
    return nil;
}

- (NSArray *)instances {
    if (self.tagSet)
        return [self.delegate.children.getNSArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id child, NSDictionary *bindings) {
            return [self.tagSet containsIndex:(NSUInteger) [child tag]] && [child conformsToProtocol:@protocol(RespawnableObject)];
        }]];
    else
        return self.delegate.children.getNSArray;
}

- (NSArray *)activeInstances {
    return [self.instances filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<RespawnableObject> obj, NSDictionary *bindings) {
        return !obj.respawnable;
    }]];
}


@end