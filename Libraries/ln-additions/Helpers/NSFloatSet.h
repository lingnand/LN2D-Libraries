//
// Created by knight on 03/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>


typedef union
{
    NSUInteger intValue;
    float floatValue;
} FloatIndex;

FloatIndex floatIndexWithInt(NSUInteger i) {
    FloatIndex fi;
    fi.intValue = i;
    return fi;
}

FloatIndex floatIndexWithFloat(float f) {
    FloatIndex fi;
    fi.floatValue = f;
    return fi;
}

NSUInteger indexFromFloat(float f) {
    return floatIndexWithFloat(f).intValue;
}

float  floatFromIndex(NSUInteger i) {
    return floatIndexWithInt(i).floatValue;
}


@interface NSFloatSet : NSObject
+ (NSFloatSet *)floatSetWithFloats:(float)firstFloat, ...;

+ (NSFloatSet *)floatSetWithFloat:(float)f;

- (void)addFloat:(float)f;

- (void)enumerateFloatsUsingBlock:(void (^)(float, BOOL *))block;

- (float)firstFloat;

- (float)lastFloat;

- (NSUInteger)count;

- (BOOL)containsFloat:(float)f;

- (BOOL)containsFloats:(NSFloatSet *)floatSet;

- (float)sum;


@end