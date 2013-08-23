/*!
    @header B2DRubeCache
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/


@class B2DWorld;

/**
* NOTICE:
*
* In RUBE when you add an image the file attribute is *only* the filename of
* the image while when using TexturePacker it might translate the sprite name as
* the path to the image name.
*
* As a result you need to make sure that you've resolved all inconsistencies
* otherwise the RUBEImage component will fail.
*
*/

@interface B2DRUBECache : NSObject

@property (nonatomic, readonly) B2DWorld *world;
/** bodyName -body array pairs
* if the given bodyName is not found; return nil
* otherwise an array containing all matching bodies
*  - that means if it returns an array, the count is at least one
*  - so you can use such expression cache.bodies["head"][0]
* */
@property (nonatomic, readonly) NSDictionary *bodies;
/** imageName - image array pairs */
@property (nonatomic, readonly) NSDictionary *images;


+ (id)RUBECacheWithFileName:(NSString *)filename;

- (id)initWithFileName:(NSString *)filename;

- (id)objectForKeyedSubscript:(id)key;

- (NSArray *)bodyNodesForName:(NSString *)name;
@end

