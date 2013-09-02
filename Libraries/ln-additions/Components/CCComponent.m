//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponent.h"
#import "NSObject+REObserver.h"
#import "NSMapTable+LnAdditions.h"
#import "NSDictionary+LnAdditions.h"
#import "NSPredicate+LnAdditions.h"
#include "NSObject+LnAdditions.h"

@interface CCComponent ()
@property(nonatomic, strong) NSMutableDictionary *generalTable;
@property(nonatomic, strong) NSMapTable *predicateTable;
@property(nonatomic, strong) NSMutableSet *predicateLocks;
@property(nonatomic, strong) NSMutableSet *predicateQueue;
@property(nonatomic, strong) NSMutableSet *componentStore;
@end

@implementation CCComponent {
    /** these two fields are used for restoring the old host or parent when
     * one of them get niled */
    __weak CCNode *_oldHost;
    __weak CCComponent *_oldParent;
    __weak CCNode *_host;
    BOOL _hostCorrectionToggle;
}

#pragma mark - Lifecycle
+ (id)component {
    return [self new];
}

+ (id)componentWithChild:(CCComponent *)comp {
    return [self componentWithChildren:[NSSet setWithObject:comp]];
}

+ (id)componentWithChildren:(id <NSFastEnumeration>)comps {
    CCComponent *c = [self new];
    [c addChildren:comps];
    return c;
}

- (id)init {
    self = [super init];
    if (self) {
        // the default implementation will be setting enabled to true
        _enabled = YES;
        // monitors the change in the activated value
        [self addObserverForKeyPath:@"activated"
                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior
                         usingBlock:^(NSDictionary *change) {
                             if ([change[NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
                                 // we need to notify the children that 'activated' will be changed
                                 for (CCComponent *c in self.componentStore)
                                     [c willChangeValueForKey:@"activated"];
                             } else {
                                 BOOL oldActivated = [change[NSKeyValueChangeOldKey] boolValue];
                                 BOOL newActivated = [change[NSKeyValueChangeNewKey] boolValue];
                                 if (newActivated != oldActivated) {
                                     // recovering the states for the delegation
                                     CCNode *currHost;
                                     CCComponent *currParent;

                                     if (_oldHost) {
                                         // saving the current value of host
                                         currHost = _host;
                                         _host = _oldHost;
                                     }
                                     if (_oldParent) {
                                         currParent = _parent;
                                         _parent = _oldParent;
                                     }
                                     // we need to activate the host correction toggle for the parent
                                     [_parent setHostCorrectionToggle:YES];

                                     if (newActivated)
                                         [self componentActivated];
                                     else
                                         [self componentDeactivated];

                                     [_parent setHostCorrectionToggle:NO];

                                     if (_oldHost)
                                         _host = currHost;
                                     if (_oldParent)
                                         _parent = currParent;

                                     // notify the children that activated did get changed
                                     // the problem here is that the activated got fed with
                                     // the wrong value (fed with old Lead)
                                     for (CCComponent *c in self.componentStore)
                                         [c didChangeValueForKey:@"activated"];

                                     _oldHost = nil;
                                     _oldParent = nil;
                                 }
                             }
                         }];
    }

    return self;
}

- (void)setHostCorrectionToggle:(BOOL)toggle {
    // set the parent as well
    if (toggle != _hostCorrectionToggle) {
        if (self.parent)
            [self.parent setHostCorrectionToggle:toggle];
        _hostCorrectionToggle = toggle;
    }
}

- (CCNode *)host {
    CCComponent *p = (_hostCorrectionToggle && _oldParent) ? _oldParent : self.parent;
    // defaults to return the host indicated by the parent
    if (p)
        return p.host;
    return (_hostCorrectionToggle && _oldHost) ? _oldHost : _host;
}

/** This method is only useful for the root component */
- (void)setHost:(CCNode *)host {
    // host node changed
    if (!self.parent) {
        [self setLead:host forStorage:&_host oldStorage:&_oldHost ofKey:@"host"];
    }
}

/** This is used by the parent to set the relationship */
- (void)setParent:(CCComponent *)parent {
    [self setLead:parent forStorage:&_parent oldStorage:&_oldParent ofKey:@"parent"];
}

- (void)setLead:(id)newLead forStorage:(__weak id *)leadStorage oldStorage:(__weak id *)oldStorage ofKey:(NSString *)name {
    if (newLead != *leadStorage) {
        if (*leadStorage) {
            id ol = *oldStorage = *leadStorage;
            [self willChangeValueForKey:name];
            *leadStorage = nil;
            [self didChangeValueForKey:name];
            *leadStorage = ol;
            [self componentRemoved];
            *leadStorage = *oldStorage = nil;
        }
        if (newLead) {
            [self willChangeValueForKey:name];
            *leadStorage = newLead;
            [self componentAdded];
            [self didChangeValueForKey:name];
        }
    }
}

- (BOOL)childrenEnabled {
    for (CCComponent *c in self.componentStore)
        if (!c.enabled)
            return NO;
    return YES;
}

- (void)setChildrenEnabled:(BOOL)childrenEnabled {
    [self.componentStore setValue:[NSNumber numberWithBool:childrenEnabled] forKey:@"enabled"];
}

- (void)componentAdded {
    BLOCK_SAFE_RUN(self.onComponentAdded, self);
}

- (void)componentRemoved {
    BLOCK_SAFE_RUN(self.onComponentRemoved, self);
}

- (void)componentActivated {
    BLOCK_SAFE_RUN(self.onComponentActivated, self);
}

- (void)componentDeactivated {
    BLOCK_SAFE_RUN(self.onComponentDeactivated, self);
}

// even if we know that the parent's activated has changed somehow, we can't reliably tell
// the change in this value
- (BOOL)activated {
    return (!self.parent || self.parent.activated) && self.enabled && [self.host isKindOfClass:[self classForPropertyNamed:@"host"]];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"parent"] || [key isEqualToString:@"activated"] || [key isEqualToString:@"host"])
        return NO;
    return [super automaticallyNotifiesObserversForKey:key];
}

+ (NSSet *)keyPathsForValuesAffectingActivated {
    return [NSSet setWithObjects:@"enabled", @"host", nil];
}

+ (NSSet *)keyPathsForValuesAffectingHost {
    return [NSSet setWithObject:@"parent"];
}

- (void)dealloc {
    // set all the children's parent to nil...?
    [self.componentStore setValue:nil forKey:@"parent"];
}

#pragma mark - Operations

- (void)scheduleUpdate {
    // most of the components are offscreen and won't be scheduled by default implementation
    [[CCDirector sharedDirector].scheduler scheduleSelector:@selector(update:) forTarget:self interval:0.0 paused:NO];
}

- (void)unscheduleUpdate {
    [[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(update:) forTarget:self];
}

- (void)update:(ccTime)step {

}

#pragma mark - Central add and remove

// check if the component has been added
- (BOOL)containsChild:(CCComponent *)comp {
    return [self.componentStore containsObject:comp];
}

- (void)removeChild:(CCComponent *)comp {
    if (comp.parent == self) {
        [self.generalTable removeObjectsForKeys:[self.generalTable allKeysForObject:comp]];
        [self.componentStore removeObject:comp];
        if (self.predicateTable.count) {
            // removes from the caching entries
            for (NSPredicate *p in self.predicateTable.copy) {
                if (self.predicateTable[p] == comp) {
                    [self.predicateLocks removeObject:p];
                    [self.predicateTable removeObjectForKey:p];
                }
            }
        }
        comp.parent = nil;
    }
}

- (void)removeAllChildren {
    // remove all the accessor dictionaries
    [self.generalTable removeAllObjects];
    [self.predicateTable removeAllObjects];
    [self.predicateLocks removeAllObjects];
    // nilling the relationship
    [self.componentStore setValue:nil forKey:@"parent"];
    [self.componentStore removeAllObjects];
}

- (BOOL)addChild:(CCComponent *)component {
    if (!component || component.parent == self)
        return YES;
    // we need to validate
    // 1. its parent attribute matches with self
    if (![self isKindOfClass:[component classForPropertyNamed:@"parent"]])
        return NO;
    // 2. it does not match up with any existing lock
    for (NSPredicate *p in self.predicateLocks.copy) {
        if ([p evaluateWithObject:component] && [self fetchChildForPredicateLock:p])
            return NO;
    }

    [self intakeChild:component];
    return YES;
}

/** if both the old component and the new component are in the manager then the old component
* will be simply removed */
- (BOOL)replaceChild:(CCComponent *)oldcomp withChild:(CCComponent *)newcomp {
    // validation
    // 1. if the attribute matches up
    if (![self isKindOfClass:[newcomp classForPropertyNamed:@"parent"]])
        return NO;
    // 2.if it matches up with any existing lock
    if (oldcomp && [self containsChild:oldcomp]) {
        if (newcomp.parent != self) {
            // we need to check through the lock set if it really can be added
            // copy the predicate locks so that if we later want to change the predicatelocks
            // inside the loop we don't mess it up
            for (NSPredicate *p in self.predicateLocks.copy) {
                if ([p evaluateWithObject:newcomp]) {
                    CCComponent *c = [self fetchChildForPredicateLock:p];
                    if (c && c != oldcomp)
                        return NO;
                }
            }
        }
    }
    // now we can safely removes the old comp
    [self removeChild:oldcomp];
    if (newcomp.parent != self)
        [self intakeChild:newcomp];
    return YES;
}

- (CCComponent *)fetchChildForPredicateLock:(NSPredicate *)p {
    // if the predicateTable hasn't cached result then it means this instance is
    // a copy and the component hasn't been fetched
    if (!self.predicateTable[p]) {
        // we need to fetch the component
        CCComponent *c = [self childForPredicate:p];
        if (!c)
                // need to remove this lock as it's no longer valid
            [self.predicateLocks removeObject:p];
        return c;
    }
    return [self childForPredicateInPredicateCache:p];
}

- (void)intakeChild:(CCComponent *)component {
    // check if the component is already wired to a kit
    if (component.parent)
        [component.parent removeChild:component];
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
    // unset the host (it's not used in a component hierarchy
    component.host = nil;
    // set the delegate
    component.parent = self;
}

- (BOOL)addChildren:(id <NSFastEnumeration>)comps {
    BOOL succeed = YES;
    for (CCComponent *comp in comps) {
        succeed &= [self addChild:comp];
    }
    return succeed;
}

- (NSSet *)filteredChildrenUsingPredicate:(NSPredicate *)predicate {
    return [self.writableComponentStore filteredSetUsingPredicate:predicate];
}


#pragma mark - Tag interface (NSNumber)

- (BOOL)setChild:(CCComponent *)component forTag:(NSInteger)tag {
    return [self setChild:component forKey:[NSNumber numberWithInt:tag]];
}

- (id)childForTag:(NSInteger)tag {
    return [self childForKey:[NSNumber numberWithInt:tag]];
}

- (void)removeChildForTag:(NSInteger)tag {
    [self removeChildForKey:[NSNumber numberWithInt:tag]];
}

- (id)objectAtIndexedSubscript:(NSInteger)tag {
    return [self childForTag:tag];
}

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag {
    [self setChild:component forTag:tag];
}

#pragma mark - General store interface (id)

- (BOOL)setChild:(CCComponent *)component forKey:(id)key {
    if ([self replaceChild:self.generalTable[key] withChild:component]) {
        self.writableGeneralTable[key] = component;
        return YES;
    }
    return NO;
}

- (id)childForKey:(id)key {
    return self.generalTable[key];
}

- (void)removeChildForKey:(id)key {
    [self removeChild:[self childForKey:key]];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self childForKey:key];
}

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)key {
    [self setChild:comp forKey:key];
}

#pragma mark - Predicate Lock interface

- (id)childForPredicate:(NSPredicate *)predicate {
    CCComponent *comp = nil;
    if ([self isCachablePredicate:predicate]) {
        comp = [self childForPredicateInPredicateCache:predicate];
        if (!comp && ![self.predicateQueue containsObject:predicate])
            comp = [self childMatchingPredicateOnLookup:predicate];
    } else
            // we don't bother for caching if it's block based: we can't cache
            // block based predicate
        comp = [self filteredChildrenUsingPredicate:predicate].anyObject;
    return comp;
}

- (CCComponent *)childForPredicateInPredicateCache:(NSPredicate *)predicate {
    CCComponent *comp = self.predicateTable[predicate];
    if (comp && ![predicate evaluateWithObject:comp]) {
        // remove the associated locks if there's any
        [self.predicateLocks removeObject:predicate];
        [self.predicateTable removeObjectForKey:predicate];
        return nil;
    }
    return comp;
}

- (CCComponent *)childMatchingPredicateOnLookup:(NSPredicate *)predicate {
    CCComponent *comp = [self filteredChildrenUsingPredicate:predicate].anyObject;
    if (comp)
            // we obtained the comp ref so we should match up the accessor system
        self.writablePredicateTable[predicate] = comp;
    else
        [self.writablePredicateQueue addObject:predicate];
    return comp;
}

- (BOOL)isCachablePredicate:(NSPredicate *)predicate {
    return ![predicate.predicateFormat hasPrefix:@"BLOCKPREDICATE"];
}

- (BOOL)setChild:(CCComponent *)comp forPredicate:(NSPredicate *)predicate {
    NSAssert(!predicate || [predicate evaluateWithObject:comp], @"Assigning a component that does not evaluate with the predicate to true");
    NSAssert([self isCachablePredicate:predicate], @"Only cachable predicates can be saved without locking out other components. To associate the given component with the predicate, please use predicate lock");
    if ([self addChild:comp]) {
        self.writablePredicateTable[predicate] = comp;
        return YES;
    }
    return NO;
}

/** This method will set the comp to the predicate and ensure that there's no
 * other component that matches up with the given predicate */
- (BOOL)setChild:(CCComponent *)comp forPredicateLock:(NSPredicate *)lock {
    NSAssert(!lock || [lock evaluateWithObject:comp], @"Assigning a component that does not evaluate with the predicate to true");
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
        if ([self addChild:comp]) {
            [self removeChild:oldComp];
            if (comp) {
                self.writablePredicateTable[lock] = comp;
                [self.writablePredicateLocks addObject:lock];
            }
            return YES;
        }
        [self.writablePredicateLocks addObject:lock];
    } else {
        BOOL requiresCleanningUp = ![self.predicateQueue containsObject:lock];
        if ([self addChild:comp]) {
            if (requiresCleanningUp) {
                // we are not sure if there's already any components that
                // match this predicate (because there's no note in the queue)
                // we have to remove all these components and then assign again
                for (CCComponent *c in [self filteredChildrenUsingPredicate:lock]) {
                    if (c != comp)
                        [self removeChild:c];
                }
            }
            if (comp) {
                self.writablePredicateTable[lock] = comp;
                [self.writablePredicateLocks addObject:lock];
            }
            return YES;
        }
    }
    return NO;
}

// To remove a given lock you can only achieve through remove the component (since some predicates
// might not be comparable)

#pragma mark - Class interface (select component by class, derived from predicate lock)

- (id)childForClass:(Class)aClass {
    return [self childForPredicate:[NSPredicate predicateWithKindOfClassFilter:aClass]];
}

/** responsibility assigning method */
- (void)setChild:(CCComponent *)component forClass:(Class)aClass {
    [self setChild:component forPredicate:[NSPredicate predicateWithKindOfClassFilter:aClass]];
}

- (void)setChild:(CCComponent *)component forClassLock:(Class)aClass {
    [self setChild:component forPredicateLock:[NSPredicate predicateWithKindOfClassFilter:aClass]];
}

#pragma mark - Selector interface (select component by selector)

- (id)childForSelector:(SEL)selector {
    return [self childForPredicate:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

- (void)setChild:(CCComponent *)component forSelector:(SEL)selector {
    [self setChild:component forPredicate:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

- (void)setChild:(CCComponent *)component forSelectorLock:(SEL)selector {
    [self setChild:component forPredicateLock:[NSPredicate predicateWithRespondsToSelectorFilter:selector]];
}

#pragma mark - Facilities

- (NSMutableDictionary *)writableGeneralTable {
    if (!_generalTable)
        _generalTable = [NSMutableDictionary dictionary];
    return _generalTable;
}

- (NSMapTable *)writablePredicateTable {
    if (!_predicateTable)
        _predicateTable = [NSMapTable strongToWeakObjectsMapTable];
    return _predicateTable;
}

- (NSMutableSet *)writablePredicateQueue {
    if (!_predicateQueue)
        _predicateQueue = [NSMutableSet set];
    return _predicateQueue;
}

- (NSMutableSet *)writableComponentStore {
    if (!_componentStore)
        _componentStore = [NSMutableSet set];
    return _componentStore;
}

- (NSMutableSet *)writablePredicateLocks {
    if (!_predicateLocks)
        _predicateLocks = [NSMutableSet set];
    return _predicateLocks;
}

- (id)copyWithZone:(NSZone *)zone {
    CCComponent *copy = [[[self class] allocWithZone:zone] init];

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
        copy.predicateLocks = self.predicateLocks.mutableCopy;
    }

    return copy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self childForSelector:aSelector];
}

- (NSSet *)children {
    return self.writableComponentStore;
}
@end