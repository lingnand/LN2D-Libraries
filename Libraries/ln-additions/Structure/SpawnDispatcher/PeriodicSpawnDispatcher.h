//
// Created by knight on 05/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "SpawnDispatcher.h"



@interface PeriodicSpawnDispatcher : SpawnDispatcher

+ (id)periodicDispatcherWithTagSet:(NSIndexSet *)indexSet spawnPeriod:(NSUInteger)period;

@end