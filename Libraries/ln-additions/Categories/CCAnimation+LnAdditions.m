/*!
    @header CCAnimation(LnAdditions)
    @copyright LnStudio
    @updated 02/07/2013
    @author lingnan
*/

#import "CCAnimation+LnAdditions.h"
#import "SequenceStringGenerator.h"


@implementation CCAnimation (LnAdditions)

+(id)animationWithFrameNameGenerator:(SequenceStringGenerator *)gen delay:(float)delay {
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];

    // load the animation frames as textures and create the sprite frames
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:gen.count];

    for (NSString *name in gen.allValues) {
        [frames addObject:[frameCache spriteFrameByName:name]];
    }
    // return an animation object from all the sprite animation frames
    return [CCAnimation animationWithSpriteFrames:frames delay:delay];
}

@end