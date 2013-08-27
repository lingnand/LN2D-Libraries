//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponentManager.h"
#import "NSPredicate+LnAdditions.h"
#import "NSDictionary+LnAdditions.h"

@interface CCComponentManager ()
@property(nonatomic, strong) NSMutableDictionary *generalTable;
@property(nonatomic, strong) NSMutableDictionary *predicateTable;
@property(nonatomic, strong) NSMutableSet *predicateQueue;
@property(nonatomic, strong) NSMutableSet *cachablePredicateLocks;
@property(nonatomic, strong) NSMutableSet *uncachablePredicateLocks;
@property(nonatomic, strong) NSMutableSet *componentStore;
@end

@implementation CCComponentManager {

}
@synthesize delegate = _delegate;

#pragma mark - CCComponent status

- (BOOL)enabled {
    // loop through all components and check whether they are enabled
    for (CCComponent *c in self.componentStore) {
        if (!c.enabled)
            return NO;
    }
    return YES;
}

- (void)setEnabled:(BOOL)enabled {
    [self.componentStore setValue:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
}

- (BOOL)activated {
    // loop through all components and check whether they are enabled
    for (CCComponent *c in self.componentStore) {
        if (!c.activated)
            return NO;
    }
    return YES;
}

#pragma mark - Lifecycle
+ (id)manager {
    return [self new];
}

+ (id)managerWithComponent:(CCComponent *)comp {
    return [self managerWithComponents:[NSSet setWithObject:comp]];
}

+ (id)managerWithComponents:(id <NSFastEnumeration>)comps {
    CCComponentManager *kit = [self new];
    [kit addComponents:comps];
    return kit;
}

#pragma mark - Central add and remove

// check if the component has been added
- (BOOL)containsComponent:(CCComponent *)comp {
    return [self.componentStore containsObject:comp];
}

- (void)removeComponent:(CCComponent *)comp {
    if (comp.delegate == self) {
        [self.generalTable removeObjectsForKeys:[self.generalTable allKeysForObject:comp]];
        // removes from the caching entries
        NSArray *predicates = [self.predicateTable allKeysForObject:comp];
        [self.predicateTable removeObjectsForKeys:predicates];
        // remove from the cachableLocks
        [self.cachablePredicateLocks minusSet:[NSSet setWithArray:predicates]];
        // remove the uncachablelocks
        [self.uncachablePredicateLocks filterUsingPredicate:[NSPredicate predicateWithFormat:@"!(SELF evaluateWithObject: %@)", comp]];
        [self.componentStore removeObject:comp];
        // we are assuming that the component is already present in this kit
        [comp setDelegateDirect:nil];
    }
}


- (BOOL)addComponent:(CCComponent *)component {
    if (!component)
        return YES;
    if ([self componentMatchingLock:component])
        return NO;
    if (component.delegate != self) {
        // check if the component is already wired to a kit
        if (component.delegate)
            [component.delegate removeComponent:component];
        // need to go through the adding procedure
        // procedure for adding the component
        // check through all the holes...
        // forward Queue
        if (self.predicateQueue.count) {
            NSMutableSet *fq = [NSMutableSet setWithCapacity:self.predicateQueue.count];
            for (NSPredicate *p in self.predicateQueue) {
                if ([p evaluateWithObject:component])
                        // add the mapping in the predicate table
                    self.writablePredicateTable[p] = component;
                else
                    [fq addObject:p];
            }
            self.predicateQueue = fq;
        }
        [self.writableComponentStore addObject:component];
        // set the delegate
        [component setDelegateDirect:self];
    }
    return YES;
}

- (BOOL)addComponents:(id <NSFastEnumeration>)comps {
    BOOL succeed = YES;
    for (CCComponent *comp in comps) {
        succeed &= [self addComponent:comp];
    }
    return succeed;
}

- (NSSet *)filteredComponentsUsingPredicate:(NSPredicate *)predicate {
    return [self.writableComponentStore filteredSetUsingPredicate:predicate];
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
        self.writableGeneralTable[key] = component;
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
    if (comp) {
        for (NSPredicate *p in self.cachablePredicateLocks) {
            if ([p evaluateWithObject:comp])
                return YES;
        }
        for (NSPredicate *p in self.uncachablePredicateLocks) {
            if ([p evaluateWithObject:comp])
                return YES;
        }
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
                self.writablePredicateTable[predicate] = comp;
            else
                [self.writablePredicateQueue addObject:predicate];
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
    NSAssert(!lock || [lock evaluateWithObject:comp], @"Assigning a component that does not evaluate with the predicate to true");
    // if there's the same predicate in the lock set, that means this predicate has been enforced and
    // so we only need to remove that particular associated component
    // note that this operation implies that the lock is cachable
    if ([self.cachablePredicateLocks containsObject:lock]) {
        CCComponent *oldComp = self.predicateTable[lock];
        if (oldComp == comp)
            return YES;
        // we must also make sure that this component does not match other existing locks
        // in the set
        // remove the lock first if it's already in the set (otherwise we cannot add the component)
        [self.cachablePredicateLocks removeObject:lock];
        // the following step might still fail.. if the component matches other
        // locks currently held
        if ([self addComponent:comp]) {
            [self removeComponent:oldComp];
            if (comp) {
                self.writablePredicateTable[lock] = comp;
                [self.writableCachablePredicateLocks addObject:lock];
            }
            return YES;
        }
        [self.writableCachablePredicateLocks addObject:lock];
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
        if (comp) {
            if ([self isCachablePredicate:lock]) {
                self.writablePredicateTable[lock] = comp;
                [self.writableCachablePredicateLocks addObject:lock];
            } else {
                // We assume that an uncachable lock cannot be recorded as
                // as such we won't need to remove any old component
                // add the lock to the set
                if (!self.uncachablePredicateLocks) {
                    self.uncachablePredicateLocks = [NSMutableSet set];
                }
                [self.uncachablePredicateLocks addObject:lock];
            }
        }
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
- (void)setComponent:(CCComponent *)component
        forClassLock:
                (Class)aClass {
    [self setComponent:component forPredicateLock:[NSPredicate predicateWithKindOfClassFilter:aClass]];
}

#pragma mark - Selector interface (select component by selector)

- (id)componentForSelector:(SEL)selector {
    return [self componentForPredicate:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

- (void)setComponent:(CCComponent *)component
     forSelectorLock:
             (SEL)selector {
    [self setComponent:component forPredicateLock:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

#pragma mark - Facilities

- (NSMutableDictionary *)writableGeneralTable {
    if (!_generalTable) {
        _generalTable = [NSMutableDictionary dictionary];
    }
    return _generalTable;
}

- (NSMutableDictionary *)writablePredicateTable {
    if (!_predicateTable) {
        _predicateTable = [NSMutableDictionary dictionary];
    }
    return _predicateTable;
}

- (NSMutableSet *)writablePredicateQueue {
    if (!_predicateQueue) {
        _predicateQueue = [NSMutableSet set];
    }
    return _predicateQueue;
}

- (NSMutableSet *)writableComponentStore {
    if (!_componentStore) {
        _componentStore = [NSMutableSet set];
    }
    return _componentStore;
}

- (NSMutableSet *)writableCachablePredicateLocks {
    if (!_cachablePredicateLocks) {
        _cachablePredicateLocks = [NSMutableSet set];
    }
    return _cachablePredicateLocks;
}

- (void)setDelegate:(CCNode *)delegate {
    // host node changed
    if (delegate != _delegate) {
        // in fact we have to go through the all-remove AND all-add approach
        // because most components will bind to the host
        // we don't need to perform any storage related operations because
        // there's none involved
        [self.componentStore setValue:nil forKey:@"delegateDirect"];
        _delegate = delegate;
        [self.componentStore setValue:self forKey:@"delegateDirect"];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    CCComponentManager *copy = [[[self class] allocWithZone:zone] init];

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
        copy->_componentStore = [[NSMutableSet alloc] initWithSet:unKeyedComps copyItems:YES];
        // II. copy all key/value pairs
        copy->_generalTable = [[NSMutableDictionary alloc] initWithDictionary:self.generalTable copyItems:YES];
        [copy.writableComponentStore addObjectsFromArray:copy.generalTable.allValues];
        // III. copy the locks (because the objects within are immutable so this is fine...)
        copy.cachablePredicateLocks = self.cachablePredicateLocks.mutableCopy;
    }

    return copy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self componentForSelector:aSelector];
}

- (NSSet *)allComponents {
    return self.writableComponentStore;
}
@end