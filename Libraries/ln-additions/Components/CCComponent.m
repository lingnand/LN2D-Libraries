//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponent.h"


@implementation CCComponent {

}

- (void)scheduleUpdate {
    // most of the components are offscreen and won't be scheduled by default implementation
    [[CCDirector sharedDirector].scheduler scheduleSelector:@selector(update:) forTarget:self interval:0.0 paused:NO];
}

- (void)unscheduleUpdate {
    [[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(update:) forTarget:self];
}

- (void)onAddComponent {

}

- (void)onRemoveComponent {

}

- (id)initWithConfig:(id)config {
    return [self init];
}

- (id)copyWithZone:(NSZone *)zone {
    CCComponent *copy = [[[self class] allocWithZone:zone]init];
    // we don't want to copy the delegate property, obviously
    return copy;
}

- (void)setDelegate:(CCNode *)delegate {
    if (delegate != _delegate) {
        if (delegate) {
            _delegate = delegate;
            self.enabled = YES;
            [self onAddComponent];
        } else {
            [self onRemoveComponent];
            self.enabled = NO;
            _delegate = delegate;
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled != _enabled) {
        _enabled = enabled;
        if (_enabled) {
            [self enable];
        } else {
            [self disable];
        }
    }
}

- (void)disable {

}

- (void)enable {

}

+ (id)component {
    return [self new];
}


- (void)dealloc {
    self.delegate = nil;
}

@end