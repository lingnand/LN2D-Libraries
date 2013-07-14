//
// Created by knight on 03/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "RandomGenerator.h"

@interface RandomGenerator ()

@end

@implementation RandomGenerator {

}

//
- (int)nextInt {
    id next = [self nextValue];
    if ([next respondsToSelector:@selector(intValue)])
        return [next intValue];
    else
        [NSException raise:@"Asking an int from a generator that generates objects instead" format:@"The object you get is %@", next];
}

@end