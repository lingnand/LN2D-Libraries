/*!
    @header B2DRUBEWorld
    @copyright LnStudio
    @updated 26/08/2013
    @author lingnan
*/

#import "B2DWorld_protected.h"
#import "B2DRUBEWorld.h"
#import "B2DBody_protected.h"
#import "B2DRUBEBody.h"
#import "B2DRUBECache.h"


@implementation B2DRUBEWorld {
}

- (void)addBodyForB2Body:(b2Body *)b {
    [B2DRUBEBody bodyWithB2Body:b];
}

- (B2DRUBECache *)cacheForThisWorldWithFileName:(NSString *)name {
    return [B2DRUBECache cacheForWorld:self WithFileName:name];
}
@end
