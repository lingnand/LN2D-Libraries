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
2. a component hierarchy (`CCComponent`)

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

#### `componentAdded`

determines what to do when the component is added into a component hierarchy

#### `componentRemoved`

triggered with the component is removed from a component hierarchy

#### `componentActivated`

triggered when the component is activated

#### `componentDeactivated`

triggered when the component is deactivated

The implementation uses Key Value Observing techniques to make sure that the dependencies specified by `keyPathsForValuesAffectingActivated` are monitored all the time and these methods are called (especially `componentActivated` and `componentDeactivated`) whenever the condition turns true/false.

### Components included in the library

## Structure

Structures are subclasses of `CCNode` that act as powerful metaphors for easily combining and creating more advanced nodes from basic elements

## Usage


[cocos2d]: http://cocos2d.org/
