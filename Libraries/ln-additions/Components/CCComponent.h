//
// Created by knight on 02/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>

@interface CCComponent :NSObject <NSCopying>

@property (nonatomic, unsafe_unretained) CCNode *delegate;
@property (nonatomic) BOOL enabled;

+ (id)component;

- (void)scheduleUpdate;

- (void)unscheduleUpdate;

- (void)onAddComponent;

- (void)onRemoveComponent;


@end