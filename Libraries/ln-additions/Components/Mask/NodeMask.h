/*!
    @header ChildrenMask
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Mask.h"

/** Node mask is designed to forward mask requests:
 * If the host has children, then it will default to using
  * a composite mask containing its children. Otherwise
  * it will use a simple RectMask*/
@interface NodeMask : Mask
@end