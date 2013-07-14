//
// Created by knight on 09/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>


@interface DBEntity : NSObject <NSCopying>

+(id)DBEntityWithDictionary:(NSDictionary *)dictionary;

+(id)DBEntityWithKeyPath:(NSString *)keypath;

+(NSSet *)DBEntitiesWithKeyPaths:(NSString *)keypath,...;

-(id)initWithDictionary:(NSDictionary *)dictionary;

-(id)implementingInstance;

-(id)configForClass:(Class)class;

-(id)configuredInstanceOfClass:(Class)class;
@end