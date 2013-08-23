/*!
    @header B2DRUBEBody
    @copyright LnStudio
    @updated 22/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "B2DBody.h"
#include "b2dJson.h"

/**
* NOTE: this class should always get initialized with the two methods
* below. Any other kind of initialization might not get what you want
*/

@interface B2DRUBEBody : B2DBody
@property (nonatomic, strong) NSString *name;

- (id)initWithB2Body:(b2Body *)body b2dJson:(b2dJson *)b2dJson;

+ (id)bodyWithB2Body:(b2Body *)body b2dJson:(b2dJson *)b2dJson;
@end