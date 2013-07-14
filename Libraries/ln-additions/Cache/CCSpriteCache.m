//
// Created by Lingnan Dai on 25/06/2013.
//


#import "CCSpriteCache.h"


@interface CCSpriteCache ()
@property(nonatomic, strong) NSMutableSet *spriteCache;
@end

@implementation CCSpriteCache {

}

+ (id)cacheWithCapacity:(NSUInteger)capacity {
    return [[self alloc] initWithCapacity:capacity];
}

+ (id)cache {
    return [[self alloc] initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        self.spriteCache = [NSMutableSet setWithCapacity:capacity];
        if (capacity > 0)
            self.size = capacity;
    }
    return self;
}

-(void)recycleNode:(CCNode *)node {
    [node removeFromParentAndCleanup:YES];
    if ([node isKindOfClass:[CCSprite class]]) {
        // need to make sure that it has no children
        [self.spriteCache addObject:node];
    }
    for (CCNode *child in node.children) {
        [self recycleNode:child];
    }
}

- (void)setSize:(NSUInteger)size {
    // size needs to be at least 1
    size = MAX(size, 1);
    if (size < _size) {
        for (; size < _size && self.spriteCache.count > 0; _size--) {
            [self.spriteCache removeObject:self.spriteCache.anyObject];
        }
    } else if (size > _size) {
        for (; size > _size; _size++) {
            [self.spriteCache addObject:[CCSprite node]];
        }
    }
}

-(CCSprite *)anySprite {
    if (self.spriteCache.count == 0) {
        self.size *= 2;
    }
    CCSprite *sprite = self.spriteCache.anyObject;
    [self.spriteCache removeObject:sprite];
    return sprite;
}
@end