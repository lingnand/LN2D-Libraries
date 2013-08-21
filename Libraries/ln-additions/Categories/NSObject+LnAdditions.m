//
// Created by knight on 08/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//

#import "NSString+LnAddition.h"
#import "NSObject+REResponder.h"
#import "NSObject+SimpleBindings.h"
#import "NSObject+LnAdditions.h"
#import "NSObject+Properties.h"

@implementation NSObject (LnAdditions)

// properties
- (void)addIdPropertyWithName:(NSString *)name defaultValue:(id)value  readonly:(BOOL)readonly {
    __block id property = value;
    [self respondsToSelector:NSSelectorFromString(name) withKey:self usingBlock:^{
        return property;
    }];
    if (!readonly) {
        [self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", [name capitalizedString]]) withKey:self usingBlock:^(id receiver, id newValue) {
            property = newValue;
        }];
    }
}

#pragma mark - Dynamic property class inspection
- (Class)classForPropertyNamed:(NSString *)name {
    // the type string is in the format of T@"<ClassName>"
    const char *type = [self typeOfPropertyNamed:name];
    NSString *cn = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", cn);
    // first search for a T@; if there isn't such a thing, it means it's not a property
    // of object type
    Class c = nil;
    if ([cn hasPrefix:@"T@"]) {
        NSArray *comps = [cn componentsSeparatedByString:@"\""];
        if (comps.count == 3)
            c = NSClassFromString(comps[1]);
    }
    return c;
}


#pragma mark - Dynamic associative array
- (id)objectForKeyedSubscript:(NSString *)key {
    return [self valueForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
    // two situations: 1. the object already has the given property
    if ([self respondsToSelector:NSSelectorFromString(key)]) {
        [self setValue:object forKey:key];
    } else {
        [self addIdPropertyWithName:key defaultValue:object readonly:NO];
    }
}

- (void)addIntPropertyWithName:(NSString *)name defaultValue:(int)value  readonly:(BOOL)readonly {
    __block int property = value;
    [self respondsToSelector:NSSelectorFromString(name) withKey:self usingBlock:^{
        return property;
    }];
    if (!readonly) {
        [self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", name.firstCharacterCapitalizedString]) withKey:self usingBlock:^(id receiver, int newValue) {
            property = newValue;
        }];
    }
}

// in this system we will just eliminate the need for exposeBinding: exposedBindings

// pairs should be a simple dictionary with key-value pairs specifying the bound values for thisObject.keyPath and thatObject.keyPath
- (void)bind:(NSString *)binding toKeyPath:(NSString *)keyPath ofObject:(id)observableController pairs:(NSDictionary *)pairs option:(KVBindingOption)option {
    NSAssert(pairs, @"providing an empty set of value pairs is not allowed!");
    if (option & KVBindingLead) {
        [observableController bind:keyPath toKeyPath:binding ofObject:self withTransformer:^id(id value) {
            id transformed = pairs[value];
            if (!transformed)
                transformed = [observableController valueForKeyPath:keyPath];
            return transformed;
        }];
    }
    if (option & KVBindingFollow) {
        [observableController bind:keyPath toKeyPath:binding ofObject:self pairs:[NSDictionary dictionaryWithObjects:pairs.allKeys forKeys:pairs.allValues] option:KVBindingLead];
    }
}



@end