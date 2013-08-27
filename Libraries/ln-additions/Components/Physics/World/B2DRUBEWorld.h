/*!
    @header B2DRUBEWorld
    @copyright LnStudio
    @updated 26/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>


@interface B2DRUBEWorld : B2DWorld
- (B2DRUBECache *)cacheForThisWorldWithFileName:(NSString *)name;
@end