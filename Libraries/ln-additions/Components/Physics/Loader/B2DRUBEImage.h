/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#include "b2dJsonImage.h"
#import "B2DBody.h"


/** A wrapper around b2dJsonImage */
/**
* NOTICE:
* After adding this component a sprite woould be initiated and added
* to the delegate to simulate the effects as in RUBE
*
*/
@interface B2DRUBEImage : CCComponent

@property (nonatomic, readonly, strong) CCSprite *image;
@property (nonatomic, readonly, strong) B2DBody *attachedBody;

+ (id)bodyWithJsonImage:(b2dJsonImage *)image;
@end
