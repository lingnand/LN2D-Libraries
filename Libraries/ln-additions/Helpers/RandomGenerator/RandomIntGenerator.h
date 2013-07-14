//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "FiniteRandomGenerator.h"


@interface RandomIntGenerator : FiniteRandomGenerator


-(id)initWithLowInt:(int)low highInt:(int)high;

-(id)initWithLowInt:(int)low highIntInclusive:(int)high;

-(id)initWithHighInt:(int)high;

-(id)initWithHighIntInclusive:(int)high;

-(id)nextValue;

+(id)generatorWithLowInt:(int)low highInt:(int)high;

+(id)generatorWithLowInt:(int)low highIntInclusive:(int)high;

+(id)generatorWithHighInt:(int)high;

+(id)generatorWithHighIntInclusive:(int)high;
@end