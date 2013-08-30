/*!
    @header NodalMask
    @copyright LnStudio
    @updated 30/08/2013
    @author lingnan
*/

#import "BodilyMask.h"
#import "Body.h"


@implementation BodilyMask {

}
- (BOOL)contains:(CGPoint)point {
    return self.body.host != nil;
}

// we'll only compare intersection in the same world
- (BOOL)intersectsOneSide:(Mask *)other {
    if (!self.body.host || ![other isKindOfClass:[BodilyMask class]]) return NO;
    BodilyMask *obm = (BodilyMask *) other;
    // we'll only compare intersection in the same world
    return obm.body.host && obm.body.world == self.body.world;
}
@end