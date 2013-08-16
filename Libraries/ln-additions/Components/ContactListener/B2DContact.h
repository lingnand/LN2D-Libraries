/*!
    @header B2DContact
    @copyright LnStudio
    @updated 16/08/2013
    @author lingnan
*/

#include "b2Fixture.h"
#include "b2Contact.h"

@class B2DBody;

@interface B2DContact: NSObject
@property (nonatomic, strong) B2DBody *ownBody;
@property (nonatomic, strong) B2DBody *otherBody;
@property (nonatomic, assign) b2Fixture *ownFixture;
@property (nonatomic, assign) b2Fixture *otherFixture;
@property (nonatomic, assign) b2Contact *b2Contact;
/**
 * Sets a collition to disabled
 * You can use this in the presolver phase to disable contacts
 * between Sprites
 */
@property (nonatomic) BOOL enabled;

- (id)initWithBody:(B2DBody *)ownBody otherBody:(B2DBody *)otherBody ownFixture:(b2Fixture *)ownFixture otherFixture:(b2Fixture *)otherFixture b2Contact:(b2Contact *)contact;

+ (id)contactWithBody:(B2DBody *)ownBody otherBody:(B2DBody *)otherBody ownFixture:(b2Fixture *)ownFixture otherFixture:(b2Fixture *)otherFixture b2Contact:(b2Contact *)contact;
@end
