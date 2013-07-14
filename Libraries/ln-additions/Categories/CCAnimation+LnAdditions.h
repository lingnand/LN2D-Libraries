/*!
    @header CCAnimation(LnAdditions)
    @copyright LnStudio
    @updated 02/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@class SequenceStringGenerator;

@interface CCAnimation (LnAdditions)
+ (id)animationWithFrameNameGenerator:(SequenceStringGenerator *)gen delay:(float)delay;
@end