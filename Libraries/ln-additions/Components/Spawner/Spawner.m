//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "Spawner.h"
#import "CCNode+LnAdditions.h"
#import "RandomPointGenerator.h"
#import "NSString+LnAddition.h"
#import "NSObject+REResponder.h"

@interface Spawner ()
@property(nonatomic) BOOL passedScreen;
@property(nonatomic, strong) RandomPointGenerator *spawnPointGenerator;
@end

/* ScrollMover Component enables the delegate to move across the screen at a constant velocity and spawn on demand */
@implementation Spawner {

}

+ (id)spawnerWithSpawnPointGenerator:(RandomPointGenerator *)pg {
    return [self spawnerWithSpawnPointGenerator:pg spawnCallback:nil];
}

+ (id)spawnerWithSpawnPointGenerator:(RandomPointGenerator *)pg spawnCallback:(SpawnBlock)block {
    return [[self alloc] initWithSpawnPointGenerator:pg block:block];
}

- (id)initWithSpawnPointGenerator:(RandomPointGenerator *)pg block:(SpawnBlock)spawnBlock{
    self = [super init];
    if (self) {
        self.spawnPointGenerator = pg;
        self.spawnBlock = spawnBlock;
    }
    return self;
}

- (void)spawn {
    [self spawnAtPoint:self.spawnPointGenerator.nextPoint];
}

- (void)spawnRightHere {
    [self spawnAtPoint:self.host.position];
}

- (void)spawnAtPoint:(CGPoint)point {
    self.host.position = point;
    BLOCK_SAFE_RUN(self.spawnBlock);
}

- (id)copyWithZone:(NSZone *)zone {
    Spawner *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.spawnPointGenerator = self.spawnPointGenerator;
    }

    return copy;
}


@end