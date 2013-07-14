//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>


@interface NSIndexSet (LnAddition)
+ (NSIndexSet *)indexSetWithIndexes:(int)firstIndex, ...;


+ (NSIndexSet *)indexSetWithArray:(NSArray *)array;
@end