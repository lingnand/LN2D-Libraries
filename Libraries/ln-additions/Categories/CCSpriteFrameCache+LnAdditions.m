/*!
    @header CCSpriteFrameCache(LnAdditions)
    @copyright LnStudio
    @updated 02/09/2013
    @author lingnan
*/

#import "CCSpriteFrameCache+LnAdditions.h"


@implementation CCSpriteFrameCache (LnAdditions)
- (NSString *) nameOfSpriteFrame:(CCSpriteFrame *)frame {
    // first check for the sprite frames dictionary
    // hopefully using the equal method defined in the category
    NSString *key = [_spriteFrames allKeysForObject:frame].lastObject;
    if (key) {
        // maybe this is an alias?
        NSString *tkey = [_spriteFramesAliases allKeysForObject:key].lastObject;
        if (tkey)
            key = tkey;
    }
    return key;
}
@end