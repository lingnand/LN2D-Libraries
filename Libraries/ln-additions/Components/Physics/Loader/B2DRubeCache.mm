/*!
    @header B2DRubeCache
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/

#include "B2DRUBECache.h"
#include "b2dJson.h"
#include "b2dJsonImage.h"
#import "B2DSpace_protected.h"
#import "B2DRUBEImage.h"
#import "CCNode+LnAdditions.h"
#import "NSArray+LnAdditions.h"
#import "B2DBody_protected.h"

@interface B2DRUBECache ()
@property(nonatomic, strong) NSMutableDictionary *bodyNodesDict;
@end

@implementation B2DRUBECache {
    b2dJson *_json;
    NSMutableDictionary *_bodies;
    NSMutableDictionary *_images;
}

+ (id)cacheForNewSpaceWithFileName:(NSString *)filename {
    return [[self alloc] initWithSpace:nil fileName:filename];
}

+ (id)cacheForSpace:(B2DSpace *)space withFileName:(NSString *)filename {
    return [[self alloc] initWithSpace:space fileName:filename];
}

- (id)initWithSpace:(B2DSpace *)space fileName:(NSString *)filename {
    if (self = [super init]) {
        // initialize the b2djson object
        NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename];
        NSLog(@"Full path is: %@", fullpath);

        _json = new b2dJson;
        std::string errMsg;

        if (space)
            _json->readIntoWorldFromFile(space.world, [fullpath UTF8String], errMsg);
        else {
            b2World *b2world = _json->readFromFile([fullpath UTF8String], errMsg);
            NSAssert(b2world, [NSString stringWithUTF8String:errMsg.c_str()]);
//            NSLog(@"Loaded JSON ok");
            // print out all the bodies
//            b2Body *b = b2world->GetBodyList();
//            while (b) {
//                // add the body
//                NSLog(@"name of body = %s, pointer = %p", _json->getBodyName(b).c_str(), b);
//                b = b->GetNext();
//            }
            space = [B2DSpace spaceWithB2World:b2world];

        }
        _space = space;
    }
    return self;
}

- (NSDictionary *)bodies {
    if (!_bodies) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        // get all the bodies in the world
        for (B2DBody *b in self.space.allBodies) {
            // if there's no name associated with this body it would be ""
            [self pushKey:[NSString stringWithUTF8String:_json->getBodyName(b.body).c_str()]
                    value:b
             inDictionary:dict];
        }
        _bodies = dict;
        // we then need to loop through all the images to associate them with the bodies
        std::vector<b2dJsonImage *> b2dImages;
        _json->getAllImages(b2dImages);
        for (uint i = 0; i < b2dImages.size(); i++) {
            b2dJsonImage *img = b2dImages[i];
            B2DBody *body = [B2DBody bodyFromB2Body:img->body];
            NSAssert(body, @"the image is referencing a body that is not captured in the all bodies array");
            [body addChild:[B2DRUBEImage imageWithJsonImage:img]];
            // we need to modify the body to make it using the information from the images correctly
            body.onComponentActivated = ^(CCComponent *component) {
                component.host.zOrder = [[component.children valueForKeyPath:@"@min.zOrder"] integerValue];
            };
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
        bodyNodes = nil;
        if (bodies) {
            bodyNodes = [NSMutableArray arrayWithCapacity:bodies.count];
            for (B2DBody *body in  bodies)
                [bodyNodes addObject:[CCNode nodeWithRootComponent:[CCComponent componentWithChild:body]]];
            self.bodyNodesDict[name] = bodyNodes;
        }
    }
    return bodyNodes;
}

- (NSArray *)allBodyNodes {
    if (self.bodies.count != self.bodyNodesDict.count) {
       // cache incomplete
        // loop through all bodies to get the bodyNodes
        for (NSString *name in self.bodies.allKeys) {
            [self bodyNodesForName:name];
        }
    }
    return [self.bodyNodesDict.allValues flattened];
}

- (void)dealloc {
    delete _json;
}


@end
