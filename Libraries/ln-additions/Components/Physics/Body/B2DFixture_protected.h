#import "B2DFixture.h"
@interface B2DFixture ()
@property(nonatomic, assign) b2FixtureDef *fixDef;
@property(nonatomic, assign) b2Fixture *fix;
- (void)setBodyDirect:(B2DBody *)body;
- (b2FixtureDef *)currentFixtureDef;
@end

