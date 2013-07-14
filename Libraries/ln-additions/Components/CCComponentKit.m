//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponentKit.h"


@interface CCComponentKit ()
@property(nonatomic, strong) NSMutableDictionary *componentDict;
@property(nonatomic, strong) NSMutableDictionary *forwardTable;
@end

@implementation CCComponentKit {

}
@synthesize delegate=_delegate;
@synthesize enabled = _enabled;

#pragma mark - Config interface (for Database) / deprecated

- (id)initWithConfig:(id)config {
    self = [self init];
    if (self) {
        // load up all the sub directories as components and add those things to myself
        [config enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            Class pClass = NSClassFromString(key);
            NSAssert([pClass isKindOfClass:[CCComponent class]] && [pClass conformsToProtocol:@protocol(ConfigurableObject)], @"the configuration is not for a valid component class! configuration = %@", config);
            [self add:[pClass initWithConfig:obj]];
        }];
    }

    return self;
}

#pragma mark - Tag interface (NSNumber)

-(void)set:(CCComponent *)component tag:(NSInteger)tag {
    [self set:component key:[NSNumber numberWithInt:tag]];
}

- (id)componentForTag:(NSInteger)tag {
    return [self componentForKey:[NSNumber numberWithInt:tag]];
}

- (void)removeComponentForTag:(NSInteger)tag {
    [self removeComponentForKey:[NSNumber numberWithInt:tag]];
}

- (id)objectAtIndexedSubscript:(NSInteger)tag {
    return [self componentForTag:tag];
}

-(void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag {
    [self set:component tag:tag];
}

#pragma mark - Key interface (id)

-(void)set:(CCComponent *)component key:(id)key {
    self.componentDict[key] = component;
    // procedure for adding the component
    component.delegate = self.delegate;
}

-(id)componentForKey:(id)key {
    return self.componentDict[key];
}

- (void)removeComponentForKey:(id)key {
    CCComponent *component = self.componentDict[key];
    [self.componentDict removeObjectForKey:key];
    component.delegate = nil;
    // also need to get it out our forwarding table
    [self.forwardTable removeObjectsForKeys:[self.forwardTable allKeysForObject:component]];
}

- (id)objectForKeyedSubscript:(id)key {
    return self.componentDict[key];
}

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)key {
    self.componentDict[key] = comp;
}

#pragma mark - Reference interface (for specific reference)

/**
    The general method for retrieving components through const pointers
    @param ref
        A pointer (presumably const) that identifies as a unique key. Example: using a static const char *
*/
-(void)set:(CCComponent *)component ref:(const void *)ref {
    [self set:component key:[NSValue valueWithPointer:ref]];
}

-(id)componentForRef:(const void *)ref {
    return [self componentForKey:[NSValue valueWithPointer:ref]];
}

-(void)removeComponentForRef:(const void *)ref {
    [self removeComponentForKey:[NSValue valueWithPointer:ref]];
}

#pragma mark - General interface

// the component will be lost if not referenced else well
-(void)add:(CCComponent *)component  {
    uintptr_t p = (uintptr_t) component;
    [self set:component ref:(void const *) p];
}

-(NSArray *)all {
    return self.componentDict.allValues;
}

-(NSArray *)filteredComponentsUsingPredicate:(NSPredicate *)predicate {
    return [self.all filteredArrayUsingPredicate:predicate];
}

#pragma mark - Facilities

- (NSMutableDictionary *)componentDict {
    if (!_componentDict) {
        _componentDict = [NSMutableDictionary dictionary];
    }
    return _componentDict;
}

- (NSMutableDictionary *)forwardTable {
    if (!_forwardTable) {
        _forwardTable = [NSMutableDictionary dictionary];
    }
    return _forwardTable;
}

- (void)setDelegate:(CCNode *)delegate {
    // need to set all the delegates for the components within
    if (delegate != _delegate) {
        _delegate = delegate;
        [self.componentDict.allValues setValue:_delegate forKey:@"delegate"];
    }
}

- (void)setEnabled:(BOOL)enabled {
    // loop through all the components
    _enabled = enabled;
    [self.componentDict.allValues setValue:[NSNumber numberWithBool:_enabled] forKey:@"enabled"];
}

- (id)copyWithZone:(NSZone *)zone {
    CCComponentKit *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        [self.componentDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            copy.componentDict[key] = [obj copy];
        }];
    }

    return copy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    // if there's already some cache
    NSValue *index = [NSValue valueWithPointer:aSelector];
    id component = self.forwardTable[index];
    if (!component) {
        // we will check through every component in the collection to get one that's able to respond to the message
        for (id comp in self.componentDict.allValues) {
            if ([comp respondsToSelector:aSelector]) {
                component = comp;
                self.forwardTable[index] = comp;
                break;
            }
        }
    }
    return component;
}


@end