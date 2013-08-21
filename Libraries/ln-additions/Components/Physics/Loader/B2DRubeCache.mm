/*!
    @header B2DRubeCache
    @copyright LnStudio
    @updated 15/07/2013
    @author lingnan
*/

#include "B2DRubeCache.h"
#include "b2dJson.h"
#include "b2dJsonImage.h"
#import "B2DWorld.h"
#import "B2DRUBEImage.h"
#import "B2DBody.h"
#import "CCNode+LnAdditions.h"

@implementation B2DRubeCache {
    b2dJson *_json;
}

/**
* Now we need to think about how to synchronize the coordinate system between B2D
* and cocos2d. one option is to have all the rube objects neglect the coordinate in the rube
* file i.e. the objects loaded in rube only provides information about the body and fixtures,
* and the position of the body object is determined when the body is added to the given node.
*
* CGPoint p = [self.delegate.position convertToWorldSpace];
* body->SetPosition(p.x * ptmRatio, p.y * ptmRatio);
*
*
* However, the problem with this approach is that the world then becomes immovable (cannot be
* moved around; bound to the world coordinate as the reason). To solve this problem you might
* want to bound a world object to a parent object, so the b2dworld uses the internal coordinate
* of that internal world i.e. when it's moved around the body coordinates do not change and thus
* nothing changes specifically. To do this the best way might be through a NSNotification? but
* we are setting up a relationship and this doesn't seem that sound...
*
* How about this. each B2DWorld will be a component (of course), and once it is added it will
* hold the reference to the delegate. And then when the child nodes are added to this B2DWorld,
* the B2DBody can know about the delegate of the B2DWorld and a transformation matrix can be
* generated to transform the position in the world.delegate into the body.delegate; then all
* the later translation between the B2DWorld coordinates and the Cocos2D coordinates will be
* relying on this transformation matrix;
*   negative: you'll need to recompute the transformation matrix each time if you want to be
*   accurate; and that can be VERY expensive if you are moving positions constantly;
*
* How to get hold onto a world component? the topmost node can have a property as the world,
* and later when a body is created it can get hold to that world property using the global
* object.
*
* Using the notification approach: when the world is added to/removed from the delegate, it
* sends a notification; and all bodies objects receiving that notification will perform the
* necessary operations to wire up the world (if this world is the world the body is bound to)
* then whenever a body is added it will also post a notification asking about whether there's
* a world, if yes then the world will respond with another message.
*
* The notification approach does seem cool... it lets you bypass the problem of passing A world
* COMPONENT around as a global object. We can specify the rule that only the nearest parent's world
* is considered the world to wire up to
*
*/

- initWithFileName:(NSString *)filename {
    if (self = [super init]) {
        // initialize the b2djson object
        NSString *fullpath = [CCFileUtils fullPathFromRelativePath:filename];

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


- (B2DRUBEImage *)RUBEImageBodyForName:(NSString *)name {
    b2dJsonImage *img = _json->getImageByName([name cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    CCLOG(@"Loading image: %s", img->file.c_str());
    return [B2DRUBEImage bodyWithJsonImage:img];
}

- (B2DBody *)bodyForName:(NSString *)name {
    b2Body *body = _json->getBodyByName([name cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    return [B2DBody bodyWithB2Body:body];
}

- (NSArray *)allRUBEImageBodies {
    // ask the json to spit out all the images
    std::vector<b2dJsonImage*> b2dImages;
    _json->getAllImages(b2dImages);
    NSMutableArray *arr = [NSMutableArray array];
    for (uint i = 0; i < b2dImages.size(); i++) {
        [arr addObject:[B2DRUBEImage bodyWithJsonImage:b2dImages[i]]];
    }
    return arr;
}

- (void)dealloc {
    delete _json;
}


@end
