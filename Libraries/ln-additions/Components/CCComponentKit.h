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

- (void)set:(CCComponent *)component ref:(const void *)ref;

- (id)componentForRef:(const void *)ref;

- (void)removeComponentForRef:(const void *)ref;

- (void)add:(CCComponent *)component;

- (void)set:(CCComponent *)component tag:(NSInteger)tag;

- (NSArray *)all;

- (NSArray *)filteredComponentsUsingPredicate:(NSPredicate *)predicate;

- (id)componentForTag:(NSInteger)tag;

- (void)removeComponentForTag:(NSInteger)tag;

- (id)objectAtIndexedSubscript:(NSInteger)tag;

- (void)setObject:(CCComponent *)component atIndexedSubscript:(NSInteger)tag;

- (void)set:(CCComponent *)component key:(id)key;

- (id)copyWithZone:(NSZone *)zone;

- (id)componentForKey:(id)key;

- (void)removeComponentForKey:(id)key;
@end