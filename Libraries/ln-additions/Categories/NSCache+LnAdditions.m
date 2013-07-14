//
// Created by Lingnan Dai on 25/06/2013.
//


#import "NSCache+LnAdditions.h"


@implementation NSCache (LnAdditions)

- (id)objectForKey:(id)k valueGenerator:(id(^)(id key))generator {
    id value = [self objectForKey:k];
    if (!value) {
        value = generator(k);
        [self setObject:value forKey:k];
    }
    return value;
}

- (void)setObject:(id)object forKeyedSubscript:(id)key {
    [self setObject:object forKey:key];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}


@end