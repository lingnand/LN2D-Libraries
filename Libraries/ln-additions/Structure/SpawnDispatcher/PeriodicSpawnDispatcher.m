//
// Created by knight on 05/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "PeriodicSpawnDispatcher.h"
#import "NSString+LnAddition.h"


@interface PeriodicSpawnDispatcher ()
@property(nonatomic) ccTime elapsed;
@property(nonatomic) ccTime period;
@end

/* aim of this class is to provide caching for a single scroller type */
@implementation PeriodicSpawnDispatcher {

}

+ (id)periodicDispatcherWithTagSet:(NSIndexSet *)indexSet spawnPeriod:(NSUInteger)period {
    return [[self alloc] initWithTagSet:indexSet spawnPeriod:period];
}

- (id)initWithTagSet:(NSIndexSet *)indexSet spawnPeriod:(NSUInteger)period {
    if (self = [super initWithTagSet:indexSet]) {
        self.period = period;
    }
    return self;
}

- (void)componentActivated {
    [self scheduleUpdate];
}

- (void)componentDeactivated {
    [self unscheduleUpdate];
}

- (void)update:(ccTime)delta {
    // we'd like to have a correct behavior for specifying the period (as number of seconds before releasing the next object
    self.elapsed += delta;
    if (self.elapsed > self.period) {
        self.elapsed = 0;
        [self spawnInactiveInstance];
    }
}


@end