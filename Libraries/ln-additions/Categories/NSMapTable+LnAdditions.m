/*!
    @header NSMapTable(LnAdditions)
    @copyright LnStudio
    @updated 22/08/2013
    @author lingnan
*/

#import "NSMapTable+LnAdditions.h"


@implementation NSMapTable (LnAdditions)

-(id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

-(void)setObject:(id)anObject forKeyedSubscript:(id)aKey {
    [self setObject:anObject forKey:aKey];
}
@end