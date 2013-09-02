/*!
    @header MaskedBody
    @copyright LnStudio
    @updated 31/08/2013
    @author lingnan
*/

#import "MaskedBody.h"
#import "ContactListener.h"
#import "RectMask.h"


@implementation MaskedBody {
}

#pragma mark - BodilyMask related operations

- (Mask *)mask {
    return [self childForClass:[Mask class]];
}

- (void)setMask:(Mask *)mask {
    [self setChild:mask forClass:[Mask class]];
}

/** Contact Listener */
- (ContactListener *)contactListener {
    if (!_contactListener)
        _contactListener = [ContactListener listener];
    return _contactListener;
}

+ (id)bodyWithMask:(Mask *)mask {
    MaskedBody *b = [self body];
    b.mask = mask;
    return b;
}

- (id)copyWithZone:(NSZone *)zone {
    MaskedBody *copy = (MaskedBody *) [super copyWithZone:zone];

    if (copy != nil) {
        copy.mask = self.mask.copy;
        copy.restitution = self.restitution;
    }

    return copy;
}

@end