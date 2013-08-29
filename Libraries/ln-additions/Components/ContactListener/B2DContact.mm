/*!
    @header B2DContact
    @copyright LnStudio
    @updated 16/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "Contact.h"
#import "B2DContact.h"
#import "B2DBody.h"
#include "b2Contact.h"

@implementation B2DContact
- (id)initWithBody:(B2DBody *)ownBody otherBody:(B2DBody *)otherBody ownFixture:(b2Fixture *)ownFixture otherFixture:(b2Fixture *)otherFixture b2Contact:(b2Contact *)contact {
    if (self = [super initWithBody:ownBody otherBody:otherBody]) {
        self.ownFixture = ownFixture;
        self.otherFixture = otherFixture;
        self.b2Contact = contact;
    }
    return self;
}

- (BOOL)enabled {
    return self.b2Contact->IsEnabled();
}

- (void)setEnabled:(BOOL)enabled {
    self.b2Contact->SetEnabled(enabled);
}

+ (id)contactWithBody:(B2DBody *)ownBody otherBody:(B2DBody *)otherBody ownFixture:(b2Fixture *)ownFixture otherFixture:(b2Fixture *)otherFixture b2Contact:(b2Contact *)contact {
    return [[self alloc] initWithBody:ownBody otherBody:otherBody ownFixture:ownFixture otherFixture:otherFixture b2Contact:contact];
}

@end
