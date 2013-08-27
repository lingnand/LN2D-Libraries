/*!
    @header B2DFixture
    @copyright LnStudio
    @updated 25/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "b2Shape.h"
#import "b2Fixture.h"

@class B2DBody;


@interface B2DFixture : NSObject <NSCopying>
@property (nonatomic) B2DBody *body;
@property (nonatomic) float density;
@property (nonatomic) float friction;
@property (nonatomic) float restitution;
@property (nonatomic) BOOL isSensor;
@property (nonatomic) b2Filter filter;
/** return the next fixture if there's one (only valid if it's already wired up to a body) */
@property (nonatomic) B2DFixture *next;

- (id)initWithB2Fixture:(b2Fixture *)fixture;

/** This pair acts as a property (but because of the const issue we
 * have to declare them as methods rather than standard properties */
- (const b2Shape *)shape;
- (void)setShape:(b2Shape *)shape;

- (id)copyWithZone:(NSZone *)zone;

+ (id)fixtureFromB2Fixture:(b2Fixture *)fixture;

+ (id)fixtureWithB2Fixture:(b2Fixture *)fixture;
@end