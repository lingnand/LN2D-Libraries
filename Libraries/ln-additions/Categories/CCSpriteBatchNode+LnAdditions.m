/*!
    @header CCSpriteBatchNode(LnAdditions)
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import "CCSpriteBatchNode+LnAdditions.h"


@implementation CCSpriteBatchNode (LnAdditions)

+(id)batchNodeWithSpriteFrameName:(NSString *)frame capacity:(NSUInteger)capacity {
    return [[self alloc] initWithSpriteFrameName:frame capacity:capacity];
}

-(id)initWithSpriteFrameName:(NSString *)frame capacity:(NSUInteger)capacity {
    return [self initWithTexture:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frame].texture capacity:capacity];
}
@end