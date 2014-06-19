LN2D-Libraries
==============

[LN2D](http://ln2d.lynnard.tk) is a library designed for anyone to easily create game objects/scenes for iOS/Mac.

## Dependencies

* [Cocos2D][cocos2d]: the base library containing the lower level code

## Architecture

LN2D uses a component-based architecture that makes intuitive sense in the following scenarios

* hierarchical composition of multiple game objects
* interfacing between models and views
* dynamic addition/removing of *capabilities* from a game object
    * each *capability* is realized via one or a set of components
* reuse of existing components

While the prevalent form of game architecture in the industry is still based on object hierarchies at the moment, component-based approaches are gathering more and more momentum due to the flexibility and dynamism afforded by such frameworks. Some of the notable ones include:

* [cistron](http://code.google.com/p/cistron/)
* [artemis](http://gamadu.com/artemis/)

## Game object

Each game object is composed of two parts

1. a view (achieved via the native `CCNode` functionalities from [Cocos2D][cocos2d])
2. a component hierarchy (`CCComponent`) for logic and model

In implementation, this is achieved by having a property of type `CCComponent` called `rootComponent` for each `CCNode`. So for example if you want to add a component to a given node:

    [node.rootComponent addChild:someComponent];

## CCComponent

Each `CCComponent` can contain an infinite number of sub `CCComponent`s.

Each of these sub-components can be *enabled/disabled* dynamically on the go by toggling its `enabled` property.

Note that the library makes a distinction between *enabled* and *activated*:

* when a component is enabled, it might not get activated
    * an example is that a component depending on some sub-components won't be activated unless those sub-components are enabled and activated first
* when it's disabled, it will definitely be deactivated

You can specify the exact condition for *activation* by overriding `activated` and also its dependencies by overriding the `keyPathsForValuesAffectingActivated` method.

### Querying/adding/removing sub components

#### Key interface

Associate a sub-component with a key. The old component associated with the key will be removed.

    setChild:forKey:
    childForKey:
    removeChildForKey:

#### Tag (number) interface

Associate a sub-component with a tag. The old component associated with the tag will be removed.

    setChild:forTag:
    childForTag:
    removeChildForTag

#### Class interface

Associate a sub-component with a `class`.  This is useful as it allows us to assign *responsibilities* for each sub-component. For example we can assign a subclass of `Body` component to the class `Body` to handle all physics related calculation concerning the body of a game object. A different subclass of `Body`, when added to the same object, is thus able to *replace* the old component handling the body calculation.

    childForClass:
    setChild:forClass:
    setChild:forClassLock:

Note: the `ClassLock` version removes all components matching the given class argument before adding the child and associate it with that class.

#### Selector interface

Associate a sub-component with a `SEL`. Similar to before, this is useful for differentiating components by their responsibilities. In particular, this looks at what message the component responds to.

    childForSelector:
    setChild:forSelector:
    setChild:forSelectorLock:

Again, the `Lock` version removes all components responding to the same message.

#### General predicate interface

In fact, the [class interface](#class-interface) and [selector interface](#selector-interface) are just variants of the predicate interface. The predicate interface allows us to associate components with *an arbitrary predicate*, including *block*-based ones.

    childForPredicate:
    setChild:forPredicate:
    setChild:forPredicateLock:

To make all these possible, the implementation makes use of a complex predicate caching mechanism to cache recent predicate queries and return results faster.

### Life-cycle

* `componentAdded`: determines what to do when the component is added into a component hierarchy
* `componentRemoved`: triggered with the component is removed from a component hierarchy
* `componentActivated`: triggered when the component is activated
* `componentDeactivated`: triggered when the component is deactivated

The implementation uses Key Value Observing techniques to make sure that the dependencies specified by `keyPathsForValuesAffectingActivated` are monitored all the time and these methods are called (especially `componentActivated` and `componentDeactivated`) whenever the condition turns true/false.

### Message passing

By default components can intercept messages sent to their masters. This happens when the master does not respond to a message, in which case the first component that responds to the message is selected as the receiver. 

### Components included in the library

#### Physics

LN2D provides a variety of physics environment for you to easily plug in to your game application.

For each physics environment, there is a dedicated `Body` component that should be attached to the objects which you wish to drive. The `Body` component defines the physical properties about the object, including mass, velocity, acceleration, etc. It might also have a `ContactListener` which triggers a function when it collides with certain objects (as informed by the physics environment).

In addition, you should also set up a `Space` component and attach it to the outermost node that contains all the physical objects with `Body`s. The `Body` component interacts with the `Space` component, gets the environmental properties, e.g., gravity, collision, relative positioning, and updates its master properly.

By using such a design, we are also able to localise the environments e.g., you can have an environment for one group of nodes, and another for some other group.

##### Simple physics environment

`TranslationalBody` provides the simplest implementation of a body. You can define its starting `position`, `velocity` and `acceleration`, and it will update the position of its master at every tick.

If you need simple gravity, you should attach a `PhysicsSpace` on the outermost node containing the nodes with `TranslationalBody`s. The `PhysicsSpace` will automatically search for the bodies and wire up the connections so that there is nothing more for you to do.

If you also need collision, you should replace the use of `TranslationalBody` with `MaskedBody`. Each `MaskedBody` is initialised with a `Mask` that defines the boundary of the object for collision checking by `PhysicsSpace`. You should also attach a `ContactListener` to the `MaskedBody`, which is just a simple wrap-up of functions to be called when the body makes a contact with another `MaskedBody`.

###### Mask

There are a variety of masks (you can also write your own). The library comes with a number of them that should cater to most use cases.

* `RectMask`: uses `CCNode`'s `boundingBox` as the mask
* `PixelMask`: uses an image as the mask
    * for each pixel, if it's above an `alphaThreshold` then it's considered a *solid* point that makes up the object
    * these information is saved in a `PixelMaskData`, which transforms an image to a `BitMask` (the underlying data structure for fast intersection checking)
    * for performance, the library provides a `MaskDataCache` that recycles the `PixelMaskData` so that the same image doesn't get processed twice (wasting CPU as well as storage)
    * you initialize a `PixelMask` by asking the cache for the `PixelMaskData`; then you attach the `PixelMask` to the `MaskedBody`; the remaining will be automatically worked out by the system
* `AutoPixelMask`: an even simpler alternative to `PixelMask`, `AutoPixelMask` attaches to the `MaskedBody` of a `CCSprite` and use the displaying sprite as the mask; you need to do nothing about setting up the mask anymore
    * an added benefit is that whenever the `CCSprite` changes its displaying frame, the `AutoPixelMask` adjusts accordingly
    * this is very useful for sprite animations

##### Box2D environment

LN2D provides a complete component interface of the [Box2D](http://box2d.org) physics engine.

Each node to be managed should include a `B2DBody` component (objective-C wrapper of `b2Body`); it supports `B2DFixture` (wrapper of `b2Fixture`) and `B2DContactListener`.

The world container node should have a `B2DSpace` component (wrapper of `b2World`).

If you use [R.U.B.E.](https://www.iforce2d.net/rube/) to edit Box2D worlds, there is also `B2DRUBECache` for you to easily load RUBE generated json file into components.

An example usage is shown below

        B2DRUBECache *cache = [B2DRUBECache cacheForSpace:space withFileName:@"player.json"];
        cache.space.ptmRatio = 50;
        [layer.rootComponent addChild:cache.space];
        // add Box2D objects as CCNodes with loaded B2DBody components
        [layer addChildren:[cache allBodyNodes]];


#### Spawner

`Spawner` is a component designed to simplify the logic concerning spawning and respawning certain game objects (e.g., enemies). It takes a `RandomPointGenerator` (a helper class that generates random points given a range/region) and simply moves its master to a random point generated by the `RandomPointGenerator` when its `spawn` method is called.

#### Display

##### Animator

`Animator` is component that handles the task of animating a `CCSprite`. You can set animations with the method `setAnimation:forTag:repeatForever:restoreOriginal:`, and after that you can simply playback an animation by its tag i.e. `run:`.

##### DisplayRandomizer

`DisplayRandomizer` shuffles the sprite frame for a `CCSprite`. It taks a `RandomStringGenerator` that generates the name of the sprite frame that its master should display at random, and after that you can simply call its `setNextDisplayFrame` to shuffle the display frame of its master. This is useful for recycling sprites e.g., you can an enemy class with a few different appearances, you can spawn them at random using `Spawner` and set a random appearance with `DisplayRandomizer`.

## Structure

Structures are subclasses of `CCNode` that act as powerful metaphors for easily combining and creating advanced nodes from basic elements.

### GridNode

A `GridNode` is a node that holds a rectangular grid of sub `CCNode`s. With `GridNode` you can easily create tile maps, floors, etc.

The best thing about this structure is that it utilizes the *objective* feature of the language as much as possible. For example:

```
GridNode *grid = [GridNode gridWithGap:0];
grid.rows[0] = [GridLine lineWithWidth:50];
grid[0][0] = [CCSprite spriteAnchoredAtOriginWithSpriteFrameName:@"backgroundLayer/bridge_flat_base1.png"];
grid[1][0] = [CCSprite spriteAnchoredAtOriginWithSpriteFrameName:@"backgroundLayer/bridge_flat_repeat1.png"];
[grid.rows[0] insertCell:[CCSprite spriteAnchoredAtOriginWithSpriteFrameName:@"backgroundLayer/bridge_flat_repeat1.png"] atIndex:0];
[grid.cols addLine:grid.cols.cutFirst];
```
The above demonstrates just a few things `GridNode` is capable of.

Some points to note:

* `grid[x][y]` points to a cell at `x`'th column and `y`'th row
* `grid.rows[y]` represents the `y`'th row of the grid as a `GridLine` object with an interface similar to that of a `NSArray`
    * you can add/insert/set/remove elements, and these changes propagate to the entire grid - columns are inserted/updated/removed when necessary, etc.
* similarly, `grid.cols[x]` represents the `x`'th column as a `GridLine`

### SpawnDispatcher

`SpawnDispatcher` is a group of structures that manages spawn-able objects. 

#### PeriodicSpawnDispatcher

`PeriodicSpawnDispatcher` periodically (with the period you specify) *spawns* its children with a tag equal to the specified value; here *spawn* means sending the children a message to respawn themselves (usually they have a `Spawner` component that will respond to the message).

## Usage

A typical usage of LN2D revolves around *compositing* the range of components. When a functionality does not yet exist in the component library, you should write a new `CCComponent` so that you can reuse the same functionality in the future.

For example, say I want to program a new `Player` object to represent the player in the game. I can composite it as `Animator`+`B2DBody` (of course adding `B2DSpace` to the outer container node).

Similarly, for an enemy class `Enemy`, I can composite it as `Animator`+`B2DBody`+`Spawner` and instantiate a number of its instances in a `SpawnDispatcher` to have a respawn-able, randomly changing, and recycled group of enemies.

[cocos2d]: http://cocos2d.org/
