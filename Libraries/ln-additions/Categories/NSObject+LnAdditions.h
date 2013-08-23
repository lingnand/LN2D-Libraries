//
// Created by knight on 08/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>

typedef enum {
    KVBindingFollow = 1 << 0,
    KVBindingLead = 1 << 1,
} KVBindingOption;

@protocol ConfigurableObject
- (id)initWithConfig:(id)config;
@end

@interface NSObject (LnAdditions)

- (void)addIdPropertyWithName:(NSString *)name defaultValue:(id)value readonly:(BOOL)readonly;

- (Class)classForPropertyNamed:(NSString *)name;

- (void)addIntPropertyWithName:(NSString *)name defaultValue:(int)value readonly:(BOOL)readonly;

- (void)bind:(NSString *)binding toKeyPath:(NSString *)keyPath ofObject:(id)observableController pairs:(NSDictionary *)pairs option:(KVBindingOption)option;

- (BOOL)respondsToSelectorName:(NSString *)name;
@end