//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>

@interface NSDictionary (LnAdditions)
-(NSSet *)keySet;

- (NSSet *)valueSet;

-(BOOL)hasKey:(id)key;

-(BOOL)hasAllKeys:(id)key1,...;

-(BOOL)hasAllKeysInArray:(NSArray *)keys;

- (id)objectAtIndexedSubscript:(NSInteger)tag;
@end