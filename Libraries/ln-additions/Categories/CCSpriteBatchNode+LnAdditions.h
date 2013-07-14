/*!
    @header CCSpriteBatchNode(LnAdditions)
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@interface CCSpriteBatchNode (LnAdditions)
- (id)initWithSpriteFrameName:(NSString *)frame capacity:(NSUInteger)capacity;

+ (id)batchNodeWithSpriteFrameName:(NSString *)frame capacity:(NSUInteger)capacity;
@end