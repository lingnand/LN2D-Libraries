//
// Created by Lingnan Dai on 25/06/2013.
//


#import <Foundation/Foundation.h>

@interface NSCache (LnAdditions)

- (id)objectForKey:(id)k valueGenerator:(id(^)(id key))generator;

- (void)setObject:(id)object forKeyedSubscript:(id)key;

- (id)objectForKeyedSubscript:(id)key;

@end