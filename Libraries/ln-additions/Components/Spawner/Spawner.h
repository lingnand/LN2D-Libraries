//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "TranslationalBody.h"

typedef void (^SpawnBlock)();
@class RandomPointGenerator;


@interface Spawner : CCComponent
@property(nonatomic, copy) SpawnBlock spawnBlock;

+ (id)spawnerWithSpawnPointGenerator:(RandomPointGenerator *)pg;

+ (id)spawnerWithSpawnPointGenerator:(RandomPointGenerator *)pg spawnCallback:(SpawnBlock)block;

- (void)spawn;

- (void)spawnRightHere;

- (void)spawnAtPoint:(CGPoint)point;

@end