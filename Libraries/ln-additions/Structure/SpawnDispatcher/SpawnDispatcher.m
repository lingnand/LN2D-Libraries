//
// Created by knight on 05/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "PeriodicSpawnDispatcher.h"

@interface SpawnDispatcher ()
@end

@implementation SpawnDispatcher {
}
@synthesize enabled=_enabled;

- (id)initWithTagSet:(NSIndexSet *)indexSet {
    self = [super init];
    if (self) {
        self.tagSet = indexSet;
    }
    return self;
}

- (id <SpawnableObject>)spawnInactiveInstance {
    NSArray *instances = self.instances;
    int start = randomInt(instances.count);
    for (NSUInteger i = (NSUInteger) start; i < start+instances.count; i++) {
        id child = instances[i % instances.count];
        if (![child active]) {
            [child spawn];
            return child;
        }
    }
    return nil;
}

- (void)enable {
    [self scheduleUpdate];
}

- (void)disable {
    [self unscheduleUpdate];
}

-(NSArray *) instances {
    if (self.tagSet)
        return [self.delegate.children.getNSArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id child, NSDictionary *bindings) {
//        return (!self.tagSet || [self.tagSet containsIndex:(NSUInteger) [child tag]]) && [child conformsToProtocol:@protocol(SpawnableObject)];
          return [self.tagSet containsIndex:(NSUInteger) [child tag]];
        }]];
    else
        return self.delegate.children.getNSArray;
}

- (NSArray *)activeInstances {
    return [self.instances filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject active];
    }]];
}


@end