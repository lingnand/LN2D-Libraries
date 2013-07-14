//
// Created by knight on 05/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "NSDictionary+LnAdditions.h"

@protocol SpawnableObject
-(BOOL)active;
-(void)spawn;
@end


@interface SpawnDispatcher : CCComponent
@property(nonatomic, strong) NSIndexSet *tagSet;
@property(nonatomic, readonly) NSArray *activeInstances;
- (id)initWithTagSet:(NSIndexSet *)indexSet;

-(id<SpawnableObject>)spawnInactiveInstance;
@end