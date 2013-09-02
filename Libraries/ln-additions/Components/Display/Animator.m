//
// Created by knight on 22/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "Animator.h"
#import "CCNode+LnAdditions.h"
#import "NSMutableDictionary+LnAddition.h"

#define ANIMATION_LABEL @"animation"

#define REPEAT_LABEL @"repeatForever"

#define RESTORE_LABEL @"restore"

@interface Animator ()
@property(nonatomic, strong) NSMutableDictionary *data;
@property(nonatomic) NSInteger previousAnimation;
@end

@implementation Animator {

}

/** @group Lifecycle */

- (id)init {
    if (self = [super init]) {
        self.data = [NSMutableDictionary dictionary];
        // initalize the currentAnimation state to an unlikely value thus acting as a guard
        _currentAnimation = NSIntegerMin;
    }
    return self;
}

- (void)componentAdded {
    // the delegate should initialize the appearance himself 
    // as animation is more of on-demand stuff
}

/** @group Running animation */

- (void)run:(NSInteger)tag repeatForever:(BOOL)repeat restoreOriginal:(BOOL)restore {
    CCAnimation *animation = self[tag];
    if (animation) {
        CCActionInterval *action = [CCAnimate actionWithAnimation:animation];
        if (repeat) {
            action = [CCRepeatForever actionWithAction:action];
        } else if (restore) {
            action = [CCSequence actions:action, [CCCallBlock actionWithBlock:^{
                self.currentAnimation = self.previousAnimation;
            }], nil];
        }
        self.currentAnimation = tag;

        [self.host stopAllActions];
        [self.host runAction:action];
    }
}

// defaults to read from config
- (void)run:(NSInteger)tag {
    [self   run:tag repeatForever:[[self.data[tag] objectForKey:REPEAT_LABEL] boolValue]
restoreOriginal :[[self.data[tag] objectForKey:RESTORE_LABEL] boolValue]];
}

- (void)setCurrentAnimation:(NSInteger)currentAnimation {
    if (_currentAnimation != currentAnimation) {
        [self willChangeValueForKey:@"currentAnimation"];
        self.previousAnimation = _currentAnimation;
        _currentAnimation = currentAnimation;
        [self run:currentAnimation];
        [self didChangeValueForKey:@"currentAnimation"];
    }
}

/** @group Animation querying */

-(CCAnimation *)objectAtIndexedSubscript:(NSInteger)tag {
    return [self animationForTag:tag];
}

- (CCAnimation *)animationForTag:(NSInteger)tag {
    return [self.data[tag] objectForKey:ANIMATION_LABEL];
}


/** @group Animation setting */

- (void)setAnimation:(CCAnimation *)animation forTag:(NSInteger)tag repeatForever:(BOOL)repeat restoreOriginal:(BOOL)restore {
    self.data[tag] = @{
            ANIMATION_LABEL : animation,
            REPEAT_LABEL : @(repeat),
            RESTORE_LABEL : @(restore)
    };
}

-(void)setAnimation:(CCAnimation *)animation forTag:(NSInteger)tag {
    self.data[tag] = @{
            ANIMATION_LABEL : animation,
    };
}

-(void)setObject:(id)obj atIndexedSubscript:(NSInteger)index {
    [self setAnimation:obj forTag:index];
}

/** @group Helpers */

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"currentAnimation"])
        return NO;
    return [super automaticallyNotifiesObserversForKey:key];
}

@end