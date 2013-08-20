//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "NSObject+LnAdditions.h"


@interface CCComponentKit : CCComponent <ConfigurableObject>

- (id)initWithConfig:(id)config;

- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(CCComponent *)comp forKeyedSubscript:(id)key;

- (void)setComponent:(CCComponent *)component forRef:(const void *)ref;

- (id)componentForRef:(const void *)ref;

- (void)removeComponentForRef:(const void *)ref;

- (id)componentForClass:(Class)aClass;

- (void)setComponent:(CCComponent *)component forClass:(Class)aClass;

- (id)componentForSelector:(SEL)selector;

- (NSArray *)componentsForSelector:(SEL)selector;

- (void)addComponent:(CCComponent *)component;

- (void)setComponent:(CCComponent *)component forTag:(NSInteger)tag;

- (NSArray *)allComponents;

- (NSArray *)filteredComponentsUsingPredicate:(NSPredicate *)predicate;

- (id)componentForTag:(NSInteger)tag;

- (void)removeComponentForTag:(NSInteger)tag;

- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag;

- (void)setComponent:(CCComponent *)component forKey:(id)key;

- (id)copyWithZone:(NSZone *)zone;

- (id)componentForKey:(id)key;

- (void)removeComponentForKey:(id)key;

- (id)componentsForClass:(Class)aClass;
@end