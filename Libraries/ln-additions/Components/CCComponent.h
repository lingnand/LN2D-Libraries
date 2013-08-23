//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>

@class CCComponentManager;

@interface CCComponent :NSObject <NSCopying>

@property (nonatomic, readonly) CCNode *host;
@property (nonatomic, weak) CCComponentManager *delegate;
@property (nonatomic) BOOL enabled;
/** the difference between enabled and activated:
* enabled is a toggle that user can control; whereas
* the activated flag indicates whethter the component is
* actually activated:
* In more detail: if (enabled == NO); the component should guarantee to be not activated
* if (enabled == YES); the component might or might not be activated depending on the
* necessary conditions
* */
@property (nonatomic, readonly) BOOL activated;

/** this is triggered when 'activated' flag turns from YES to NO*/
- (void)deactivate;

/** this is triggered when 'activated' flag turns from NO to YES*/
- (void)activate;

+ (NSSet *)keyPathsForValuesAffectingActivated;

- (void)update:(ccTime)step;

+ (id)component;

- (void)scheduleUpdate;

- (void)unscheduleUpdate;

- (void)onAddComponent;

- (void)onRemoveComponent;


@end