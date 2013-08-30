/*!
    @header B2DRUBEWorld
    @copyright LnStudio
    @updated 26/08/2013
    @author lingnan
*/

#import "B2DSpace_protected.h"
#import "B2DRUBESpace.h"
#import "B2DBody_protected.h"
#import "B2DRUBEBody.h"
#import "B2DRUBECache.h"


@implementation B2DRUBESpace {
}

- (void)addBodyForB2Body:(b2Body *)b {
    [B2DRUBEBody bodyWithB2Body:b];
}

- (B2DRUBECache *)cacheForThisSpaceWithFileName:(NSString *)name {
    return [B2DRUBECache cacheForSpace:self withFileName:name];
}
@end
