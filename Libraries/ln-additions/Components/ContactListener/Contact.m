/*!
    @header Contact
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import "Contact.h"
#import "Body.h"


@implementation Contact {

}

- (id)initWithBody:(Body *)ownBody otherBody:(Body *)otherBody {
    if (self = [super init]) {
        self.ownBody = ownBody;
        self.otherBody = otherBody;
    }
    return self;
}

+ (id)contactWithBody:(Body *)ownBody otherBody:(Body *)otherBody {
    return [[self alloc] initWithBody:ownBody otherBody:otherBody];
}
@end