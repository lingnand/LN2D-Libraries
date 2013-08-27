/*!
    @header B2DRUBEBody
    @copyright LnStudio
    @updated 22/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DRUBEBody.h"
#import "CCComponentManager.h"

@interface B2DRUBEBody()
@end

@implementation B2DRUBEBody {
    CCComponentManager *_imageManager;
}

+ (id)bodyWithB2Body:(b2Body *)body images:(NSSet *)images {
    return [[self alloc] initWithB2Body:body images:images];
}

- (id)initWithB2Body:(b2Body *)body images:(NSSet *)images {
    if (self = [super initWithB2Body:body]) {
        [self.imageManager addComponents:images];
    }
    return self;
}

- (CCComponentManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [CCComponentManager manager];
    }
    return _imageManager;
}

- (void)activate {
    [super activate];
    self.imageManager.delegate = self.host;
    self.host.zOrder = [[self.imageManager.allComponents valueForKeyPath:@"@min.zOrder"] integerValue];
}

- (void)deactivate {
    [super deactivate];
    self.imageManager.delegate = nil;
}

@end