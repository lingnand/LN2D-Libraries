//
// Created by knight on 09/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "DBEntity.h"
#import "PlistDatabase.h"


@interface DBEntity ()
@property(nonatomic, strong) NSDictionary *config;
@end

@implementation DBEntity {

}
+ (id)DBEntityWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

+ (id)DBEntityWithKeyPath:(NSString *)keypath {
    return [[self alloc] initWithDictionary:[PlistDatabase table:keypath]];
}

+ (id)DBEntitiesWithParentKeyPath:(NSString *)keypath {
    NSMutableSet *set = [NSMutableSet set];
    for (NSDictionary *dictionary in [PlistDatabase table:keypath]) {
        [set addObject:[self DBEntityWithDictionary:dictionary]];
    }
    return set.copy;
}

+(NSSet *)DBEntitiesWithKeyPaths:(NSString *)keypath,... {
    va_list args;
    va_start(args, keypath);
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *key = keypath; key != nil; key = va_arg(args, NSString *)) {
        [set addObject:[self DBEntityWithKeyPath:key]];
    }
    va_end(args);
    return set.copy;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.config = dictionary;
    }
    return self;
}


- (id)implementingInstance {
//    NSString *implementingClassName = [self.config valueForKeyPath:EnumImplementingClass];
//    NSAssert(implementingClassName, @"invokeClass is not found in the dictionary", @"dictionary information %@", self.config);
//    Class pClass = NSClassFromString(implementingClassName);
//    return [[pClass alloc] initWithConfig:[self.config valueForKeyPath:implementingClassName]];
    return nil;
}

-(id)configForClass:(Class)class {
    return [self.config objectForKey:NSStringFromClass(class)];
}

- (id)configuredInstanceOfClass:(Class)class {
//    return [[class alloc] initForDBEntity:self];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


@end