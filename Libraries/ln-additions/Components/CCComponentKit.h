//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "NSObject+LnAdditions.h"


@interface CCComponentKit : CCComponent

/** Key interface */

/**
* return value explanation follows addComponent
* @see CCComponentKit#addComponent:
*/
- (BOOL)setComponent:(CCComponent *)component forKey:(id)key;

- (id)componentForKey:(id)key;

- (void)removeComponentForKey:(id)key;

- (id)objectForKeyedSubscript:(id)name;

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)name;

/** Tag interface */

/**
* return value explanation follows addComponent
* @see CCComponentKit#addComponent:
*/
- (BOOL)setComponent:(CCComponent *)component forTag:(NSInteger)tag;

- (id)componentForTag:(NSInteger)tag;

- (void)removeComponentForTag:(NSInteger)tag;

- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag;

/** Class interface */
- (id)componentForClass:(Class)aClass;

- (void)setComponent:(CCComponent *)component forClassLock:(Class)aClass;

/** Selector interface */
- (id)componentForSelector:(SEL)selector;

- (void)setComponent:(CCComponent *)component forSelectorLock:(SEL)selector;

/** General interface */
/**
* Attempting to add the component
* returns YES if the end result is such that the component is added into the kit (it can
* be that the component is already in the kit)
* NO if the component cannot be added into the kit (there's predicate locks that prevent
* it from being added)
*/
- (BOOL)addComponent:(CCComponent *)component;

- (void)removeComponent:(CCComponent *)comp;

- (BOOL)containsComponent:(CCComponent *)comp;

- (NSSet *)allComponents;

- (NSSet *)filteredComponentsUsingPredicate:(NSPredicate *)predicate;

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
- (id)componentForPredicate:(NSPredicate *)predicate;

/**
* This method is useful for locking a certain type of component.
* e.g. You'd like to specify that some component is exclusive with
* other similar ones. This method will remove all other components
* matching the lock and add this component to the manager. It will
* also make sure that no other components that satisfies the lock
* can be added in the future.
*
*/
- (void)setComponent:(CCComponent *)comp forPredicateLock:(NSPredicate *)lock;

@end