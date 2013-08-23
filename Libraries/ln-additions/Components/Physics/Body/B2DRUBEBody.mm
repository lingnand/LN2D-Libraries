/*!
    @header B2DRUBEBody
    @copyright LnStudio
    @updated 22/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DRUBEBody.h"


@implementation B2DRUBEBody {

}

+ (id)bodyWithB2Body:(b2Body *)body b2dJson:(b2dJson *)b2dJson {
    return [[self alloc] initWithB2Body:body b2dJson:b2dJson];
}

- (id)initWithB2Body:(b2Body *)body b2dJson:(b2dJson *)b2dJson {
    if (self = [super initWithB2Body:body]) {
        self.name = [NSString stringWithUTF8String:b2dJson->getBodyName(body).c_str()];
    }
    return self;
}

@end