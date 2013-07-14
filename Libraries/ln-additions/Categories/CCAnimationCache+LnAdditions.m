//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCAnimationCache+LnAdditions.h"


@implementation CCAnimationCache (LnAdditions)

- (void)addAnimation:(CCAnimation *)animation tag:(id)tag {
    [self addAnimation:animation name:tag];
}

- (CCAnimation *)animationByTag:(id)tag {
    return [self animationByName:tag];
}


-(void)setObject:(id)value forKeyedSubscript:(id)key {
    [self addAnimation:value tag:key];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self animationByTag:key];
}

@end