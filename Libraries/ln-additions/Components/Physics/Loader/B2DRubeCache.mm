/*!
    @header B2DRubeCache
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/

#include "B2DRUBECache.h"
#include "b2dJson.h"
#include "b2dJsonImage.h"
#import "B2DWorld_protected.h"
#import "B2DRUBEImage.h"
#import "NSMapTable+LnAdditions.h"
#import "CCNode+LnAdditions.h"

@interface B2DRUBECache ()
@property(nonatomic, strong) NSMutableDictionary *bodyNodesDict;
@end

@implementation B2DRUBECache {
    b2dJson *_json;
    NSMutableDictionary *_bodies;
    NSMutableDictionary *_images;
}

+ (id)cacheForNewWorldWithFileName:(NSString *)filename {
    return [[self alloc] initWithWorld:nil fileName:filename];
}

+ (id)cacheForWorld:(B2DWorld *)world WithFileName:(NSString *)filename {
    return [[self alloc] initWithWorld:world fileName:filename];
}

- (id)initWithWorld:(B2DWorld *)world fileName:(NSString *)filename {
    if (self = [super init]) {
        // initialize the b2djson object
        NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename];
        CCLOG(@"Full path is: %@", fullpath);

        _json = new b2dJson;
        std::string errMsg;

        if (world)
            _json->readIntoWorldFromFile(world.world, [fullpath UTF8String], errMsg);
        else {
            b2World *b2world = _json->readFromFile([fullpath UTF8String], errMsg);
            NSAssert(b2world, [NSString stringWithUTF8String:errMsg.c_str()]);
            CCLOG(@"Loaded JSON ok");
            world = [B2DWorld worldWithB2World:b2world];
        }
        _world = world;
    }
    return self;
}

- (NSDictionary *)bodies {
    if (!_bodies) {
        std::vector<b2Body *> bodies;
        _json->getAllBodies(bodies);
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (uint i = 0; i < bodies.size(); i++) {
            // add all the bodies to the dictionary
            b2Body *body = bodies[i];
            [self pushKey:[NSString stringWithUTF8String:_json->getBodyName(body).c_str()]
                    value:[B2DRUBEBody bodyWithB2Body:body]
             inDictionary:dict];
        }
        _bodies = dict;
        // we then need to loop through all the images to associate them with the bodies
        std::vector<b2dJsonImage *> b2dImages;
        _json->getAllImages(b2dImages);
        for (uint i = 0; i < b2dImages.size(); i++) {
            b2dJsonImage *img = b2dImages[i];
            B2DRUBEBody *body = [B2DRUBEBody bodyFromB2Body:img->body];
            NSAssert(body, @"the image is referencing a body that is not captured in the all bodies array");
            [body.imageManager addComponent:[B2DRUBEImage imageWithJsonImage:img]];
        }
    }
    return _bodies;
}

- (void)pushKey:(id)key value:(id)value inDictionary:(NSMutableDictionary *)dict {
    NSMutableArray *arr = dict[key];
    if (!arr) {
        dict[key] = arr = [NSMutableArray array];
    }
    [arr addObject:value];
}

- (NSDictionary *)images {
    if (!_images) {
        std::vector<b2dJsonImage *> b2dImages;
        _json->getAllImages(b2dImages);
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (uint i = 0; i < b2dImages.size(); i++) {
            B2DRUBEImage *img = [B2DRUBEImage imageWithJsonImage:b2dImages[i]];
            [self pushKey:img.name value:img inDictionary:dict];
        }
        _images = dict;
    }
    return _images;
}

- (NSMutableDictionary *)bodyNodesDict {
    if (!_bodyNodesDict) {
        _bodyNodesDict = [NSMutableDictionary dictionaryWithCapacity:self.bodies.count];
    }
    return _bodyNodesDict;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self bodyNodesForName:key];
}

- (NSArray *)bodyNodesForName:(NSString *)name {
    id bodyNodes = self.bodyNodesDict[name];
    if (!bodyNodes) {
        NSArray *bodies = self.bodies[name];
        id arr = nil;
        if (bodies) {
            arr = [NSMutableArray arrayWithCapacity:bodies.count];
            for (B2DRUBEBody *body in  bodies)
                [arr addObject:[CCNode nodeWithComponentManager:[CCComponentManager managerWithComponent:body]]];
        } else
            arr = [NSNull null];
        bodyNodes = self.bodyNodesDict[name] = arr;
    }
    return bodyNodes == [NSNull null] ? nil : bodyNodes;
}

- (void)dealloc {
    delete _json;
}


@end
