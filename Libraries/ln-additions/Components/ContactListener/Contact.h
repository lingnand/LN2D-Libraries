/*!
    @header Contact
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@class Body;


@interface Contact : NSObject
@property (nonatomic, strong) Body *ownBody;
@property (nonatomic, strong) Body *otherBody;

- (id)initWithBody:(Body *)ownBody otherBody:(Body *)otherBody;

+ (id)contactWithBody:(Body *)ownBody otherBody:(Body *)otherBody;
@end