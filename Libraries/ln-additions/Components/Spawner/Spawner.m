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
    return [self spawnerWithSpawnPointGenerator:pg block:nil];
}

+ (id)spawnerWithSpawnPointGenerator:(RandomPointGenerator *)pg block:(SpawnBlock)block {
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

- (void)onAddComponent {
    // maybe we should set the host's visibility to NO so as to match the active  attribute
    self.delegate.visible = NO;
}

- (void)onRemoveComponent {
    [self unscheduleUpdate];
}

- (void)update:(ccTime)delta {
    if ([self.delegate fullyOutsideScreen]) {
        if (self.passedScreen) {
            self.delegate.visible = NO;
            // presumably stop the body
            self.delegate.body.enabled = NO;
        }
    } else {
        if (!self.passedScreen)
            self.passedScreen = YES;
    }
}

- (void)spawn {
    [self spawnAtPoint:self.spawnPointGenerator.nextPoint];
}

- (void)spawnRightHere {
    [self spawnAtPoint:self.delegate.position];
}

- (void)spawnAtPoint:(CGPoint)point {
    self.delegate.position = point;
    self.delegate.visible = YES;
    self.passedScreen = NO;
    if (self.spawnBlock) {
        self.spawnBlock();
    }
    // presumably we should start the body
    self.delegate.body.enabled = YES;
}

- (BOOL)active {
    return self.delegate.visible;
}

- (id)copyWithZone:(NSZone *)zone {
    Spawner *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.spawnPointGenerator = self.spawnPointGenerator;
    }

    return copy;
}


@end