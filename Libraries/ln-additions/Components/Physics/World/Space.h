/*!
    @header PhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "CCComponent.h"
@class Body;

#define DEFAULT_GRAVITY (ccp(0.0f, -100.0f))
#define DEFAULT_STEP (1.0f / 60.0f)
@interface Space : CCComponent
/** The subclass should provide the correct initializers for these properties */
/** The gravity is ALWAYS relative to the world */
@property(nonatomic) CGPoint gravity;

+(id)space;

- (Class)bodyClass;

- (BOOL)addBody:(Body *)body;

- (void)onAddingNewBody:(Body *)body;

- (BOOL)removeBody:(Body *)body;

- (void)onRemovingBody:(Body *)body;

- (NSSet *)allBodies;
@end
