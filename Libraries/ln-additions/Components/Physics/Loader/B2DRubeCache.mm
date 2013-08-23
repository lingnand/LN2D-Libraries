/*!
    @header B2DRubeCache
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/

#include "B2DRUBECache.h"
#include "b2dJson.h"
#include "b2dJsonImage.h"
#import "B2DWorld.h"
#import "B2DRUBEImage.h"
#import "NSMapTable+LnAdditions.h"
#import "B2DBody.h"
#import "CCNode+LnAdditions.h"

@interface B2DRUBECache ()
@property(nonatomic, strong) NSMapTable *bodyImages;
@property(nonatomic, strong) NSMutableDictionary *bodyNodesDict;
@end

@implementation B2DRUBECache {
    b2dJson *_json;
    NSMutableArray *_allRUBEImages;
    NSMutableDictionary *_bodies;
    NSMutableDictionary *_images;
}

+ (id)RUBECacheWithFileName:(NSString *)filename {
    return [[self alloc] initWithFileName:filename];
}

- (NSDictionary *)bodies {
    if (!_bodies) {
        std::vector<b2Body *> bodies;
        _json->getAllBodies(bodies);
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (uint i = 0; i < bodies.size(); i++) {
            // add all the bodies to the dictionary
            b2Body *body = bodies[i];
            [self pushKey:[NSString stringWithUTF8String:_json->getBodyName(body).c_str()] value:[B2DBody bodyWithB2Body:body] inDictionary:dict];
        }
        _bodies = dict;
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

- (NSMapTable *)bodyImages {
    if (!_bodyImages) {
        std::vector<b2dJsonImage *> b2dImages;
        _json->getAllImages(b2dImages);
        NSMapTable *dict = [NSMapTable strongToStrongObjectsMapTable];
        for (uint i = 0; i < b2dImages.size(); i++) {
            b2dJsonImage *img = b2dImages[i];
            B2DBody *body = [B2DBody bodyWithB2Body:img->body];
            NSMutableArray *arr = dict[body];
            if (!arr) {
                dict[body] = arr = [NSMutableArray array];
            }
            [arr addObject:[B2DRUBEImage imageWithJsonImage:img]];
        }
        _bodyImages = dict;
    }
    return _bodyImages;
}

- (NSMutableDictionary *)bodyNodesDict {
    if (!_bodyNodesDict) {
        _bodyNodesDict = [NSMutableDictionary dictionaryWithCapacity:self.bodies.count];
    }
    return _bodyNodesDict;
}

- (id)initWithFileName:(NSString *)filename {
    if (self = [super init]) {
        // initialize the b2djson object
        NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename];

        // This will print out the actual location on disk that the file is read from.
        // When using the simulator, exporting your RUBE scene to this folder means
        // you can edit the scene and reload it without needing to restart the app.
        CCLOG(@"Full path is: %@", fullpath);

        // Create the world from the contents of the RUBE .json file. If something
        // goes wrong, m_world will remain NULL and errMsg will contain some info
        // about what happened.
        _json = new b2dJson;
        std::string errMsg;

        b2World *b2world = _json->readFromFile([fullpath UTF8String], errMsg);
        NSAssert(b2world, [NSString stringWithUTF8String:errMsg.c_str()]);
        CCLOG(@"Loaded JSON ok");

//            // Set up a debug draw so we can see what's going on in the physics engine.
//            // The scale for rendering will be handled by the layer scale, which will affect
//            // the entire layer, so we keep the PTM ratio here to 1 (ie. one physics unit
//            // will be one pixel)
//            //m_debugDraw = new GLESDebugDraw( 1 );
//            // oh wait... actually, this should be 2 if using retina
//            m_debugDraw = new GLESDebugDraw( [[CCDirector sharedDirector] contentScaleFactor] );
//
//            // set the debug draw to show fixtures, and let the world know about it
//            m_debugDraw->SetFlags( b2Draw::e_shapeBit );
//            m_world->SetDebugDraw(m_debugDraw);
//
//            // This body is needed if we want to use a mouse joint to drag things around.
//            b2BodyDef bd;
//            m_mouseJointGroundBody = m_world->CreateBody( &bd );
        _world = [B2DWorld worldWithB2World:b2world];

    }
    return self;
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
            for (B2DBody *body in  bodies) {
                CCNode *node = [CCNode node];
                node.body = body;
                NSArray *images = self.bodyImages[body];
                [node.componentKit addComponents:images];
                node.zOrder = [[images valueForKeyPath:@"@min.zOrder"] integerValue];
                [arr addObject:node];
            }
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
