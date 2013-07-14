//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "Utilities.h"

@interface NSString (LnAddition)


+(NSString *)stringByJoiningWithDot:(NSString *)string,...;

+(NSString *)stringByJoiningWith:(NSString *)separator firstParamenter:(NSString *)string parameterList:(va_list)valist;

-(NSString *)stringByAppendingFileSuffix:(NSString *)suffix;

-(NSString *)stringByJoiningWithDot:(NSString *)string,...;

- (NSString *)firstCharacterCapitalizedString;

-(CGPoint)CGPointValue;

-(CGRect)rectValue;

-(NSRange)rangeValue;

-(CGSize)sizeValue;

- (CGRange)CGRangeValue;

- (id)structComponents;

@end