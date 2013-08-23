//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "CCComponent.h"
#import "NSObject+REObserver.h"
#import "CCComponentKit.h"


@implementation CCComponent {
    CCComponentKit *_oldDelegate;
}

- (id)init {
    self = [super init];
    if (self) {
        // the default implementation will be setting enabled to true
        _enabled = YES;
        // monitors the change in the activated value
        [self addObserver:self
               forKeyPath:@"activated"
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                  context:nil];
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"activated"]) {
        BOOL ov = [change[NSKeyValueChangeOldKey] boolValue];
        BOOL nv = [change[NSKeyValueChangeNewKey] boolValue];
        if (nv != ov) {
            BOOL recoverDelegate = !_delegate;
            if (recoverDelegate) {
                NSAssert(_oldDelegate, @"oldDelegate lost");
                _delegate = _oldDelegate;
            }
            if (nv)
                [self activate];
            else {
                [self deactivate];
            }
            if (recoverDelegate)
                _delegate = _oldDelegate = nil;
        }
    } else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

- (CCNode *)host {
    return self.delegate.delegate;
}

- (id)initWithConfig:(id)config {
    return [self init];
}

- (id)copyWithZone:(NSZone *)zone {
    CCComponent *copy = [[[self class] allocWithZone:zone] init];
    // we don't want to copy the delegate property, obviously
    return copy;
}

- (void)setDelegate:(CCComponentKit *)delegate {
    if (delegate != _delegate) {
        // we just route this to the componentKit
        [_delegate removeComponent:self];
        [delegate addComponent:self];
    }
}

- (void)setDelegateDirect:(CCComponentKit *)delegate {
    if (delegate != _delegate) {
        if (_delegate) {
            CCComponentKit *od = _oldDelegate = _delegate;
            [self willChangeValueForKey:@"delegate"];
            _delegate = nil;
            [self didChangeValueForKey:@"delegate"];
            _delegate = od;
            [self onRemoveComponent];
            _delegate = _oldDelegate = nil;
        }
        if (delegate) {
            [self willChangeValueForKey:@"host"];
            _delegate = delegate;
            [self onAddComponent];
            [self didChangeValueForKey:@"host"];
        }
    }
}

- (void)deactivate {

}

- (void)activate {

}

- (BOOL)activated {
    return self.enabled && self.host;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"delegate"])
        return NO;
    return [super automaticallyNotifiesObserversForKey:key];
}

+ (NSSet *)keyPathsForValuesAffectingActivated {
    return [NSSet setWithObjects:@"enabled", @"node", nil];
}

+ (NSSet *)keyPathsForValuesAffectingHost {
    return [NSSet setWithObjects:@"delegate", nil];
}

- (void)update:(ccTime)step {

}

+ (id)component {
    return [self new];
}


- (void)dealloc {
    self.delegate = nil;
}

@end