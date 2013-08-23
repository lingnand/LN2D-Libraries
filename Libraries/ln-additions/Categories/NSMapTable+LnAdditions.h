/*!
    @header NSMapTable(LnAdditions)
    @copyright LnStudio
    @updated 22/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@interface NSMapTable (LnAdditions)

- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)anObject forKeyedSubscript:(id)aKey;
@end