//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponentKit.h"
#import "CHBidirectionalDictionary.h"
#import "NSPredicate+LnAdditions.h"
#import "NSDictionary+LnAdditions.h"

@interface CCComponentKit ()
@property(nonatomic, strong) NSMutableDictionary *generalTable;
@property(nonatomic, strong) NSMutableDictionary *predicateTable;
@property(nonatomic, strong) NSMutableSet *predicateQueue;
@property(nonatomic, strong) NSMutableSet *predicateLocks;
@property(nonatomic, strong) NSMutableSet *componentStore;
@end

@implementation CCComponentKit {

}
@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (void)setEnabled:(BOOL)enabled {
    [self.allComponents setValue:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
}

#pragma mark - Central add and remove

// check if the component has been added
- (BOOL)containsComponent:(CCComponent *)comp {
    return [self.componentStore containsObject:comp];
}

- (void)removeComponent:(CCComponent *)comp {
    if ([self containsComponent:comp]) {
        [self.generalTable removeObjectsForKeys:[self.generalTable allKeysForObject:comp]];
        NSArray *predicates = [self.predicateTable allKeysForObject:comp];
        [self.predicateLocks minusSet:[NSSet setWithArray:predicates]];
        [self.predicateTable removeObjectsForKeys:predicates];
        [self.componentStore removeObject:comp];
        // we are assuming that the component is already present in this kit
        comp.delegate = nil;
    }
}


/** Without any kind of wiring up, just doing the backhouse wiring for
 * the component */
- (BOOL)addComponent:(CCComponent *)component {
    if ([self componentMatchingLock:component])
        return NO;
    [self intakeComponent:component];
    return YES;
}

/** Wiring up for the component; without consideration for locks */
- (void)intakeComponent:(CCComponent *)component {
    if (![self containsComponent:component]) {
        component.delegate = self.delegate;
        // need to go through the adding procedure
        // procedure for adding the component
        // check through all the holes...
        // forward Queue
        if (self.predicateQueue.count) {
            NSMutableSet *fq = [NSMutableSet setWithCapacity:self.predicateQueue.count];
            for (NSPredicate *p in self.predicateQueue) {
                if ([p evaluateWithObject:component])
                        // add the mmapping in the predicate table
                    self.predicateTable[p] = component;
                else
                    [fq addObject:p];
            }
            self.predicateQueue = fq;
        }
        [self.componentStore addObject:component];
    }
}

- (NSSet *)allComponents {
    return self.componentStore.copy;
}

- (NSSet *)filteredComponentsUsingPredicate:(NSPredicate *)predicate {
    return [self.componentStore filteredSetUsingPredicate:predicate];
}


#pragma mark - Tag interface (NSNumber)

- (BOOL)setComponent:(CCComponent *)component forTag:(NSInteger)tag {
    return [self setComponent:component forKey:[NSNumber numberWithInt:tag]];
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

#pragma mark - General store interface (id)

- (BOOL)setComponent:(CCComponent *)component forKey:(id)key {
    BOOL r = [self addComponent:component];
    if (r)
        self.generalTable[key] = component;
    return r;
}

- (id)componentForKey:(id)key {
    return self.generalTable[key];
}

- (void)removeComponentForKey:(id)key {
    [self removeComponent:[self componentForKey:key]];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self componentForKey:key];
}

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)key {
    [self setComponent:comp forKey:key];
}

#pragma mark - Predicate Lock interface

- (BOOL)componentMatchingLock:(CCComponent *)comp {
    for (NSPredicate *p in self.predicateLocks) {
        if ([p evaluateWithObject:comp])
            return YES;
    }
    return NO;
}

- (id)componentForPredicate:(NSPredicate *)predicate {
    CCComponent *comp = nil;
    if ([self isCachablePredicate:predicate]) {
        comp = self.predicateTable[predicate];
        if (!comp && ![self.predicateQueue containsObject:predicate]) {
            if ((comp = [self filteredComponentsUsingPredicate:predicate].anyObject))
                    // we obtained the comp ref so we should match up the accessor system
                self.predicateTable[predicate] = comp;
            else
                [self.predicateQueue addObject:predicate];
        }
    } else {
        // we don't bother for caching if it's block based: we can't cache
        // block based predicate
        comp = [self filteredComponentsUsingPredicate:predicate].anyObject;
    }
    return comp;
}

- (BOOL)isCachablePredicate:(NSPredicate *)predicate {
    return ![predicate.predicateFormat hasPrefix:@"BLOCKPREDICATE"];
}

/** This method will set the comp to the predicate and ensure that there's no
 * other component that matches up with the given predicate */
- (BOOL)setComponent:(CCComponent *)comp forPredicateLock:(NSPredicate *)lock {
    NSAssert([lock evaluateWithObject:comp], @"Assigning a component that does not evaluate with the predicate to true");
    // if there's the same predicate in the lock set, that means this predicate has been enforced and
    // so we only need to remove that particular associated component
    // note that this operation implies that the lock is cachable
    if ([self.predicateLocks containsObject:lock]) {
        CCComponent *oldComp = self.predicateTable[lock];
        if (oldComp == comp)
            return YES;
        // we must also make sure that this component does not match other existing locks
        // in the set
        // remove the lock first if it's already in the set (otherwise we cannot add the component)
        [self.predicateLocks removeObject:lock];
        // the following step might still fail.. if the component matches other
        // locks currently held
        if ([self addComponent:comp]) {
            [self removeComponent:oldComp];
            self.predicateTable[lock] = comp;
            [self.predicateLocks addObject:lock];
            return YES;
        }
        [self.predicateLocks addObject:lock];
    } else if ([self addComponent:comp]) {
        if (![self.predicateQueue containsObject:lock]) {
            // we are not sure if there's already any components that
            // match this predicate (because there's no note in the queue)
            // we have to remove all these components and then assign again
            for (CCComponent *c in [self filteredComponentsUsingPredicate:lock]) {
                if (c != comp)
                    [self removeComponent:c];
            }
        }
        if ([self isCachablePredicate:lock])
            self.predicateTable[lock] = comp;
        [self.predicateLocks addObject:lock];
        return YES;
    }
    return NO;
}

// To remove a given lock you can only achieve through remove the component (since some predicates
// might not be comparable)

#pragma mark - Class interface (select component by class, derived from predicate lock)

- (id)componentForClass:(Class)aClass {
    return [self componentForPredicate:[NSPredicate predicateWithKindOfClassFilter:aClass]];
}

/** responsibility assigning method */
- (void)setComponent:(CCComponent *)component forClassLock:(Class)aClass {
    [self setComponent:component forPredicateLock:[NSPredicate predicateWithKindOfClassFilter:aClass]];
}

#pragma mark - Selector interface (select component by selector)

- (id)componentForSelector:(SEL)selector {
    return [self componentForPredicate:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

- (void)setComponent:(CCComponent *)component forSelectorLock:(SEL)selector {
    [self setComponent:component forPredicateLock:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

#pragma mark - Facilities

- (NSMutableDictionary *)generalTable {
    if (!_generalTable) {
        _generalTable = [NSMutableDictionary dictionary];
    }
    return _generalTable;
}

- (NSMutableDictionary *)predicateTable {
    if (!_predicateTable) {
        _predicateTable = [NSMutableDictionary dictionary];
    }
    return _predicateTable;
}

- (NSMutableSet *)predicateQueue {
    if (!_predicateQueue) {
        _predicateQueue = [NSMutableSet set];
    }
    return _predicateQueue;
}

- (NSMutableSet *)componentStore {
    if (!_componentStore) {
        _componentStore = [NSMutableSet set];
    }
    return _componentStore;
}

- (NSMutableSet *)predicateLocks {
    if (!_predicateLocks) {
        _predicateLocks = [NSMutableSet set];
    }
    return _predicateLocks;
}

- (void)setDelegate:(CCNode *)delegate {
    // need to set all the delegates for the components within
    if (delegate != _delegate) {
        _delegate = delegate;
        for (CCComponent *comp in self.allComponents) {
            comp.delegate = delegate;
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    CCComponentKit *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        // NOTE: the following implementation is based on the assumption
        // that the only additional operation in addComponent is to
        // wire up the delegate; since a new componentKit does not point
        // to any delegate so we don't really need to go through that
        // operation

        // we need to copy all the components (drudgery...!)
        // I. copy all comps not referenced by the generalTable
        // we first obtain the set that cannot be referenced by the key/value pairs
        NSMutableSet *unKeyedComps = self.componentStore.mutableCopy;
        [unKeyedComps minusSet:self.generalTable.valueSet];
        for (CCComponent *c in unKeyedComps) {
            [copy.componentStore addObject:c.copy];
        }
        // II. copy all key/value pairs
        [self.generalTable enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id c = [obj copy];
            copy.generalTable[key] = c;
            [copy.componentStore addObject:c];
        }];
        // III. copy the locks
        copy.predicateLocks = self.predicateLocks.mutableCopy;
    }

    return copy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self componentForSelector:aSelector];
}


@end