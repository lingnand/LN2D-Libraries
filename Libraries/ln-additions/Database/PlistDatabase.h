//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>


@interface PlistDatabase : NSObject

+(PlistDatabase *)sharedDatabase;

-(id)query:(NSString *)query,...;

+ (id)query:(NSString *)query, ...;


-(id)table:(NSString *)name;

- (id)instanceofClass:(Class)class withConfigKeyPath:(NSString *)configKeyPath;

- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)value forKeyedSubscript:(id)key;

+ (id)table:(NSString *)name;


@end