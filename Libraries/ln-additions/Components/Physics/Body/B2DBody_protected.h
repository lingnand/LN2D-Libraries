#import "B2DBody.h"
@interface B2DBody()
@property (nonatomic, assign) b2BodyDef *bodyDef;
@property (nonatomic, assign) b2Body *body;
@property (nonatomic, strong) NSMutableSet *fixtures;
- (b2BodyDef *)currentBodyDef;
@end
