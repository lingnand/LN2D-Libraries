//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponentKit.h"
#import "CHBidirectionalDictionary.h"


@interface CCComponentKit ()
@property(nonatomic, strong) NSMutableDictionary *componentDict;
/** two tables for storing additional responsibilities for classes and selectors */
@property(nonatomic, strong) NSMutableDictionary *classTable;
@property(nonatomic, strong) NSMutableDictionary *forwardTable;
@property(nonatomic, strong) NSMutableSet *classQueue;
@property(nonatomic, strong) NSMutableSet *forwardQueue;
@end

@implementation CCComponentKit {

}
@synthesize delegate = _delegate;
@synthesize enabled = _enabled;

#pragma mark - Config interface (for Database) / deprecated

- (id)initWithConfig:(id)config {
    self = [self init];
    if (self) {
        // load up all the sub directories as components and add those things to myself
        [config enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            Class pClass = NSClassFromString(key);
            NSAssert([pClass isKindOfClass:[CCComponent class]] && [pClass conformsToProtocol:@protocol(ConfigurableObject)], @"the configuration is not for a valid component class! configuration = %@", config);
            [self addComponent:[pClass initWithConfig:obj]];
        }];
    }

    return self;
}

#pragma mark - Lifecycle

- (void)setEnabled:(BOOL)enabled {
    [self.allComponents setValue:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
}

#pragma mark - Tag interface (NSNumber)

- (void)setComponent:(CCComponent *)component forTag:(NSInteger)tag {
    [self setComponent:component forKey:[NSNumber numberWithInt:tag]];
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

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag {
    [self setComponent:component forTag:tag];
}

#pragma mark - Key interface (id)

- (void)setComponent:(CCComponent *)component forKey:(id)key {
    self.componentDict[key] = component;
    // procedure for adding the component
    component.delegate = self.delegate;
    // check through all the holes...
    // forward Queue
    if (self.forwardQueue.count) {
        NSMutableSet *fq = [NSMutableSet setWithCapacity:self.forwardQueue.count];
        for (NSValue *v in self.forwardQueue) {
            SEL selector = v.pointerValue;
            if ([component respondsToSelector:selector])
                [self setComponent:component forSelector:selector];
            else
                [fq addObject:v];
        }
        self.forwardQueue = fq;
    }
    // class Queue
    if (self.classQueue.count) {
        NSMutableSet *cq = [NSMutableSet setWithCapacity:self.classQueue.count];
        for (Class c in self.classQueue) {
            if ([component isKindOfClass:c])
                [self setComponent:component forClass:c];
            else
                [cq addObject:c];
        }
        self.classQueue = cq;
    }
}

- (id)componentForKey:(id)key {
    return self.componentDict[key];
}

- (void)removeComponentForKey:(id)key {
    CCComponent *component = self.componentDict[key];
    [self.componentDict removeObjectForKey:key];
    component.delegate = nil;
    // remove the component from the tables as well
    [self.forwardTable removeObjectsForKeys:[self.forwardTable allKeysForObject:component]];
    [self.classTable removeObjectsForKeys:[self.classTable allKeysForObject:component]];
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
- (void)setComponent:(CCComponent *)component forRef:(const void *)ref {
    [self setComponent:component forKey:[NSValue valueWithPointer:ref]];
}

- (id)componentForRef:(const void *)ref {
    return [self componentForKey:[NSValue valueWithPointer:ref]];
}

- (void)removeComponentForRef:(const void *)ref {
    [self removeComponentForKey:[NSValue valueWithPointer:ref]];
}

#pragma mark - Class interface (select component by class)
/**
* To accelerate access we can store the component as [class] => [component] once a
* search is made; the only problem is that we'd also need to remove this newly created
* pair once the component is removed; as a result when a component gets removed you
* have to loop through the whole dictionary to get the component and remove that as well
*
*/

/**
* To improve the performance, all dynamic queries about components should be performed
* before the query recorded if it returns nil. So that when a new component is added
* we can fill this hole (reason: a query made once is more than likely to have be made
* again)
*/

- (id)componentForClass:(Class)aClass {
    CCComponent *comp = [self.classTable objectForKey:aClass];
    if (!comp && ![self.classQueue containsObject:aClass]) {
        if ((comp = [[self componentsForClass:aClass] lastObject]))
            [self setComponent:comp forClass:aClass];
        else
            [self.classQueue addObject:aClass];
    }
    return comp;
}

- (id)componentsForClass:(Class)aClass {
    return [self filteredComponentsUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:aClass];
    }]];
}

/** responsibility assigning method */
- (void)setComponent:(CCComponent *)component forClass:(Class)aClass {
    if ([self.componentDict allKeysForObject:component].count == 0) {
        [self addComponent:component];
    }
    self.classTable[aClass] = component;
}

#pragma mark - Selector interface (select component by selector)

- (id)componentForSelector:(SEL)selector {
    // first get the component in question
    NSValue *se = [NSValue valueWithPointer:selector];
    CCComponent *comp = [self.forwardTable objectForKey:se];
    // search for all the components that respond to this selector and choose the first one as the
    // default one
    // cache this is the forwarding table
    if (!comp && ![self.forwardQueue containsObject:se]) {
        if ((comp = [[self componentsForSelector:selector] lastObject]))
            [self setComponent:comp forSelector:selector];
        else
            [self.forwardQueue addObject:se];
    }
    return comp;
}

- (NSArray *)componentsForSelector:(SEL)selector {
    return [self filteredComponentsUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject respondsToSelector:selector];
    }]];
}

-(void)setComponent:(CCComponent *)component forSelector:(SEL)selector {
    if ([self.componentDict allKeysForObject:component].count == 0) {
        [self addComponent:component];
    }
    // this component might not have been added into the components dictionary
    self.forwardTable[[NSValue valueWithPointer:selector]] = component;
}

#pragma mark - General interface

// the component will be lost if not referenced else well
- (void)addComponent:(CCComponent *)component {
    uintptr_t p = (uintptr_t) component;
    [self setComponent:component forRef:(void const *) p];
}

- (NSArray *)allComponents {
    return self.componentDict.allValues;
}

- (NSArray *)filteredComponentsUsingPredicate:(NSPredicate *)predicate {
    return [self.allComponents filteredArrayUsingPredicate:predicate];
}

#pragma mark - Facilities

- (NSMutableDictionary *)componentDict {
    if (!_componentDict) {
        _componentDict = [NSMutableDictionary dictionary];
    }
    return _componentDict;
}

- (NSMutableDictionary *)forwardTable {
    if (!_forwardTable)
        _forwardTable = [NSMutableDictionary dictionary];
    return _forwardTable;
}

- (NSMutableDictionary *)classTable {
    if (!_classTable)
        _classTable = [NSMutableDictionary dictionary];
    return _classTable;
}

- (NSMutableSet *)forwardQueue {
    if (!_forwardQueue)
        _forwardQueue = [NSMutableSet set];
    return _forwardQueue;
}

- (NSMutableSet *)classQueue {
    if (!_classQueue)
        _classQueue = [NSMutableSet set];
    return _classQueue;
}

- (void)setDelegate:(CCNode *)delegate {
    // need to set all the delegates for the components within
    if (delegate != _delegate) {
        _delegate = delegate;
        [self.componentDict.allValues setValue:_delegate forKey:@"delegate"];
    }
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
    return [self componentForSelector:aSelector];
}


@end