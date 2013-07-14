//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>

@interface CCAnimationCache (LnAdditions)


- (void)addAnimation:(CCAnimation *)animation tag:(id)tag;

- (CCAnimation *)animationByTag:(id)tag;

- (void)setObject:(id)value forKeyedSubscript:(id)key;

- (id)objectForKeyedSubscript:(id)key;
@end