//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
/**
* The main design of Component is modeled on NSSet.
* You can add arbitrary children and query via complex predicates.
* To facilitate the access though, it also comes with a dictionary
* that you can reference components via keys easily
*
* So in total the component is a hybrid of dictionary and set.
*
* Clearing the confusion on predicates:
*
* The main aim of associating components with predicates is for dynamic
* lookup of component.
*
* Oftentimes operations involve asking the parent component: do you have a
* component that matches this and this condition? To answer this the parent
* will do a dynamic lookup on the components and cache the result.
*
* Now sometimes you want to make sure that if someone else asks this type of
* question the componentManager will return the component that you'd like it
* to return as an answer. You have two options:
* 1. use a predicateLock
*   A predicateLock works for all predicates. Basically it adds this component and
*   makes sure that no other components matching this predicate will be added (existing
*   matching instances will be removed as well). This means that when you ask another
*   canonically identical question but expressed in a different way, the manager will
*   also return the same instance
* 2. use a predicate
*   The component manager will remember this question and return the assigned component
*   when it sees the SAME question expressed in the SAME way. This doesn't work for
*   some predicates e.g. blocks, because a block cannot be remembered and compared reliably.
*   However, this does work for some format-based predicates, to a certain extent. The
*   main advantage of this approach is that it does not lock out other components, thus
*   allowing more flexibility.
*
*/

@class CCComponent;

typedef void (^ComponentCallback) (CCComponent *);

@interface CCComponent : NSObject <NSCopying>

@property (nonatomic, weak) CCNode *host;
@property (nonatomic, weak, readonly) CCComponent *parent;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL childrenEnabled;
@property (nonatomic, readonly) BOOL activated;
+ (NSSet *)keyPathsForValuesAffectingActivated;
/** These blocks provide a convenient way to modify the component on the go */
@property (nonatomic, copy) ComponentCallback onComponentActivated;
@property (nonatomic, copy) ComponentCallback onComponentDeactivated;
@property (nonatomic, copy) ComponentCallback onComponentAdded;
@property (nonatomic, copy) ComponentCallback onComponentRemoved;

/** Initializers */
+ (id)component;

+ (id)componentWithChild:(CCComponent *)comp;

+ (id)componentWithChildren:(id <NSFastEnumeration>)comps;

/** Key interface */
/**
* Set the component for the given key. The old component associated with the key will be removed
* return value explanation follows addComponent
* @see CCComponentKit#addComponent:
*/
- (BOOL)setChild:(CCComponent *)component forKey:(id)key;

- (id)childForKey:(id)key;

- (void)removeChildForKey:(id)key;

- (id)objectForKeyedSubscript:(id)name;

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)name;

/** Tag interface */

/**
* Set the component for the given tag. The old component associated with the tag will be removed
* return value explanation follows addComponent
* @see CCComponentKit#addComponent:
*/
- (BOOL)setChild:(CCComponent *)component forTag:(NSInteger)tag;

- (id)childForTag:(NSInteger)tag;

- (void)removeChildForTag:(NSInteger)tag;

- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag;

/** Class interface */
- (id)childForClass:(Class)aClass;

- (void)setChild:(CCComponent *)component forClass:(Class)aClass;
- (void)setChild:(CCComponent *)component forClassLock:(Class)aClass;

/** Selector interface */
- (id)childForSelector:(SEL)selector;

- (void)setChild:(CCComponent *)component forSelector:(SEL)selector;
- (void)setChild:(CCComponent *)component forSelectorLock:(SEL)selector;

/** General interface */
/**
* Attempting to add the component
* returns YES if the end result is such that the component is added into the kit (it can
* be that the component is already in the kit)
* NO if the component cannot be added into the kit (there's predicate locks that prevent
* it from being added)
*
* the component added will be anonymous -- it won't be referencable through keys
* BUT it might be able to get referenced through predicates -- (class, selector, so on)
*/
- (BOOL)addChild:(CCComponent *)component;

/**
* This will try to add all the components and return the ANDed result of
* the individual results
*/
- (BOOL)addChildren:(id <NSFastEnumeration>)comps;

- (void)removeChild:(CCComponent *)comp;

- (void)removeAllChildren;

- (BOOL)containsChild:(CCComponent *)comp;

- (NSSet *)children;

- (NSSet *)filteredChildrenUsingPredicate:(NSPredicate *)predicate;

- (id)copyWithZone:(NSZone *)zone;

/**
* Predicate interface (advanced)
* Note: To make these two methods really useful make sure that your
* predicates are comparable (they are made out of format, for example)
* Otherwise the locking can be expensive.
*/

/**
* Return (any) component matching the predicate. If you've called `setComponent:forPredicateLock:`
* Then you can be sure that when you call with the same predicate again it will return the
* same component. (even if you've added other components between the two operations or later)
*/
- (id)childForPredicate:(NSPredicate *)predicate;

/** This will set the component in the predicate cache table but will not lock out other predicates
* Due to this nature uncachable predicates are not allowed */
/** Note that this method will NEVER remove any existing components. It simply associates an component with a predicate */
- (BOOL)setChild:(CCComponent *)comp forPredicate:(NSPredicate *)predicate;
/**
* This method is useful for locking a certain type of component.
* e.g. You'd like to specify that some component is exclusive with
* other similar ones. This method will remove all other components
* matching the lock and add this component to the manager. It will
* also make sure that no other components that satisfies the lock
* can be added in the future.
*
* This method returns true if the lock is successfully established;
* otherwise false if setting this component will contradict other
* locks
*
* NOTE: if comp argument is nil, the behavior is to remove this particular
* lock if there's any
*
* Some interesting behaviour:
* 1. add a block-based predicate lock and you won't be able to associate
* this predicate with any other comp unless you remove the previous component
* 2. if you have set up multiple locks on one component, most likely you
* won't succeed in setting another component for one of these locks as the
* new component might very likely match the other locks for the old component
*/
- (BOOL)setChild:(CCComponent *)comp forPredicateLock:(NSPredicate *)lock;

- (void)componentAdded;

- (void)componentRemoved;

/** this is triggered when 'activated' flag turns from NO to YES
* The default activated implementation ensures that now when this method is
* called -- delegate is set and enabled is turned to YES
* */
- (void)componentActivated;

/** this is triggered when 'activated' flag turns from YES to NO
* To ease the userability the connection with the component manager is maintained
* when this method is triggered (you can still call self.delegate or self.host)
* otherwise other conditions hold true (activated == NO)
* */
- (void)componentDeactivated;

- (void)scheduleUpdate;

- (void)unscheduleUpdate;

- (void)update:(ccTime)step;

@end
