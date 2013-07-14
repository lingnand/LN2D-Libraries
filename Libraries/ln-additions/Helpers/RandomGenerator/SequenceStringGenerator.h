//
// Created by knight on 20/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>


@interface SequenceStringGenerator : NSObject
+ (id)generatorWithFormat:(NSString *)format count:(NSUInteger)count;

+ (id)generatorWithFormat:(NSString *)format start:(NSInteger)start count:(NSUInteger)count;

- (id)initWithFormat:(NSString *)format start:(NSInteger)start count:(NSUInteger)count;

- (NSArray *)allValues;

- (NSUInteger)count;

- (id)valueAtIndex:(NSUInteger)index;

- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end