//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <objc/runtime.h>
#import "NSDictionary+LnAdditions.h"

id cValueForKey (NSDictionary *self, SEL sel) {
    return [self valueForKeyPath:NSStringFromSelector(sel)];
}

@implementation NSDictionary (LnAdditions)

-(NSSet *) keySet {
    return [NSSet setWithArray:self.allKeys];
}

-(NSSet *)valueSet {
    return [NSSet setWithArray:self.allValues];
}

-(BOOL) hasKey:(id)key {
    return [self objectForKey:key] != nil;
}

-(BOOL) hasAllKeys:(id)key1,... {
    NSMutableArray *arr = [NSMutableArray array];
    va_list args;
    va_start(args, key1);
    for (id i = key1; i != nil; i = va_arg(args, id))
    {
        [arr addObject:i];
    }
    va_end(args);
    return [self hasAllKeysInArray:arr];
}

-(BOOL) hasAllKeysInArray:(NSArray *)keys {
    return  ![[self objectsForKeys:keys notFoundMarker:[NSNull null]] containsObject:[NSNull null]];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    [self valueForKey:NSStringFromSelector(aSelector)];
}

// dynamically resolve methods so that key value pairs can be read of as properties
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return class_addMethod([self class], sel, (IMP) cValueForKey, "@@:");
}

- (id)objectAtIndexedSubscript:(NSInteger)tag {
    return [self objectForKey:[NSNumber numberWithInt:tag]];
}



@end