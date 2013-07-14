//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "PlistDatabase.h"
#import "NSDictionary+LnAdditions.h"
#import "NSObject+LnAdditions.h"

@protocol DatabaseContainer
@property(nonatomic, strong) NSString *path;
@property(nonatomic) BOOL changed;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
@end

/* Composition class to record data entry properties */
@interface DatabaseDictionary : NSMutableDictionary <DatabaseContainer>
+ (id)databaseDictionaryWithContentsOfFile:(NSString *)path;
@end

@interface DatabaseDictionary ()
@property(nonatomic, strong) NSMutableDictionary *database;
@end

@implementation DatabaseDictionary

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (![[self.database objectForKey:aKey] isEqual:anObject]) {
        self.changed = YES;
        [self.database setObject:anObject forKey:aKey];
    }
}

- (void)removeObjectForKey:(id)aKey {
    if ([self.database hasKey:aKey]) {
        self.changed = YES;
        [self.database removeObjectForKey:aKey];
    }
}

- (NSUInteger)count {
    return self.database.count;
}

- (id)objectForKey:(id)aKey {
    return [self.database objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [self.database keyEnumerator];
}

+ (id)databaseDictionaryWithContentsOfFile:(NSString *)path {
    return [[DatabaseDictionary alloc] initWithContentsOfFile:path];
}

- (id)initWithContentsOfFile:(NSString *)path {
    if (self = [super init]) {
        self.database = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if (self.database) {
            self.path = path;
        } else {
            self = nil;
        }
    }
    return self;
}

@end

/* Composition class to record data entry properties */
@interface DatabaseArray : NSMutableArray <DatabaseContainer>
+ (id)databaseArrayWithContentsOfFile:(NSString *)path;
@end

@interface DatabaseArray ()
@property(nonatomic, strong) NSMutableArray *database;
@end

@implementation DatabaseArray
- (void)addObject:(id)anObject {
    [self.database addObject:anObject];
    self.changed = YES;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self.database insertObject:anObject atIndex:index];
    self.changed = YES;
}

- (void)removeLastObject {
    [self.database removeLastObject];
    self.changed = YES;
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.database removeObjectAtIndex:index];
    self.changed = YES;
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.database replaceObjectAtIndex:index withObject:anObject];
    self.changed = YES;
}

- (id)initWithContentsOfFile:(NSString *)path {
    if (self = [super init]) {
        self.database = [NSMutableArray arrayWithContentsOfFile:path];
        if (self.database) {
            self.path = path;
        } else {
            self = nil;
        }
    }
    return self;
}

- (NSUInteger)count {
    return [self.database count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.database objectAtIndex:index];
}

+ (id)databaseArrayWithContentsOfFile:(NSString *)path {
    return [[DatabaseArray alloc] initWithContentsOfFile:path];
}


@end


@interface PlistDatabase ()
@property(nonatomic, strong) NSMutableDictionary *tables;
@end

@implementation PlistDatabase {

}

+ (PlistDatabase *)sharedDatabase {
    static PlistDatabase *db = nil;
    if (!db) {
        db = [[self alloc] init];
    }
    return db;
}

- (NSMutableDictionary *)tables {
    if (!_tables) {
        _tables = [NSMutableDictionary dictionary];
    }
    return _tables;
}

+ (id)query:(NSString *)query, ... {
    va_list args;
    va_start(args, query);
    id result = [[self sharedDatabase] query:query withParameters:args];
    va_end(args);
    return result;
}

- (id)query:(NSString *)query, ... {
    va_list args;
    va_start(args, query);
    id result = [self query:query withParameters:args];
    va_end(args);
    return result;
}

- (id)query:(NSString *)query withParameters:(va_list)valist {
    // obtain the first component of the string
    NSMutableArray *arr = [[query componentsSeparatedByString:@"."] mutableCopy];
    // get the first table just to sure it's already fetched
    [self table:[arr objectAtIndex:0]];
    for (NSString *str = va_arg(valist, NSString *); str != nil; str = va_arg(valist, NSString *)) {
        [arr addObject:str];
    }
    return [self.tables valueForKeyPath:[arr componentsJoinedByString:@"."]];
}

+ (id)table:(NSString *)name {
    return [[self sharedDatabase] table:name];
}

- (id)table:(NSString *)name {
    id table = [self.tables objectForKey:name];
    if (!table) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        table = [DatabaseDictionary databaseDictionaryWithContentsOfFile:path];
        if (!table) {
            table = [DatabaseArray databaseArrayWithContentsOfFile:path];
        }
        self.tables[name] = table;
    }
    return table;
}

- (id)instanceofClass:(Class)class withConfigKeyPath:(NSString *)configKeyPath {
    if ([class conformsToProtocol:@protocol(ConfigurableObject)]) {
        return [[class alloc] initWithConfig:self[configKeyPath]];
    }
    return nil;
}


// implement KVC and then add dynamic properties
- (id)valueForUndefinedKey:(NSString *)key {
    return [self table:key];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    static NSString *DEFAULT_DATABASE_PATH = nil;
    if (!DEFAULT_DATABASE_PATH)
        DEFAULT_DATABASE_PATH = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Data"];
    // the value should be a nsdictionary or a nsarray then (so as to facilitate saving
    id <DatabaseContainer> container;
    if ([value isKindOfClass:[NSArray class]]) {
        container = [DatabaseArray arrayWithArray:value];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        container = [DatabaseDictionary dictionaryWithDictionary:value];
    }
    container.path = [[DEFAULT_DATABASE_PATH stringByAppendingPathComponent:key] stringByAppendingPathExtension:@"plist"];
    container.changed = YES;
    self.tables[key] = container;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self valueForKeyPath:key];
}

- (void)setObject:(id)value forKeyedSubscript:(id)key {
    [self setValue:value forKeyPath:key];
}

- (void)dealloc {
    // saving the changes to the filesystem
    [self.tables enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj conformsToProtocol:@protocol(DatabaseContainer)]) {
            id<DatabaseContainer> database = obj;
            if (database.changed) {
                [database writeToFile:database.path atomically:NO];
            }
        }
    }];
}


@end