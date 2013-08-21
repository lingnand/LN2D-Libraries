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

- (void)setComponent:(CCComponent *)component forKey:(id)key;

- (id)componentForKey:(id)key;

- (void)removeComponentForKey:(id)key;

- (id)objectForKeyedSubscript:(id)name;

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)name;

/** Tag interface */
- (void)setComponent:(CCComponent *)component forTag:(NSInteger)tag;

- (id)componentForTag:(NSInteger)tag;

- (void)removeComponentForTag:(NSInteger)tag;

- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag;

/** Class interface */
- (id)componentForClass:(Class)aClass;

- (void)setComponent:(CCComponent *)component forClass:(Class)aClass;

/** Selector interface */
- (id)componentForSelector:(SEL)selector;

- (void)setComponent:(CCComponent *)component forSelector:(SEL)selector;

/** General interface */
- (void)addComponent:(CCComponent *)component;

- (NSSet *)allComponents;

- (NSSet *)filteredComponentsUsingPredicate:(NSPredicate *)predicate;

- (id)copyWithZone:(NSZone *)zone;
@end