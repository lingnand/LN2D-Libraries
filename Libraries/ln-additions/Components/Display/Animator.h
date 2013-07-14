//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"

@interface Animator : CCComponent
// setting currentAnimation to diffferent states would trigger an animation run
@property(nonatomic) NSInteger currentAnimation;

- (void)run:(NSInteger)tag repeatForever:(BOOL)repeat restoreOriginal:(BOOL)restore;

- (void)run:(NSInteger)tag;

- (CCAnimation *)objectAtIndexedSubscript:(NSInteger)tag;

- (CCAnimation *)animationForTag:(NSInteger)tag;

- (void)setAnimation:(CCAnimation *)animation forTag:(NSInteger)tag repeatForever:(BOOL)repeat restoreOriginal:(BOOL)restore;

- (void)setAnimation:(CCAnimation *)animation forTag:(NSInteger)tag;

- (void)setObject:(id)obj atIndexedSubscript:(NSInteger)index1;
@end