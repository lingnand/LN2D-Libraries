//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "NSMutableDictionary+LnAddition.h"

@implementation NSMutableDictionary (LnAddition)

-(void)setObject:(id)obj atIndexedSubscript:(NSInteger)key {
    [self setObject:obj forKey:[NSNumber numberWithInt:key]];
}


@end