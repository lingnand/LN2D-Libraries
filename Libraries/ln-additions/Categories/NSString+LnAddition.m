//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "NSString+LnAddition.h"
#import "PlistDatabase.h"
#import "NSIndexSet+LnAddition.h"


@implementation NSString (LnAddition)

- (NSString *)stringByAppendingFileSuffix:(NSString *)suffix {
    return [[[self stringByDeletingPathExtension]
            stringByAppendingString:suffix]
            stringByAppendingPathExtension:self.pathExtension];
}

+ (NSString *)stringByJoiningWithDot:(NSString *)string, ... {
    va_list args;
    va_start(args, string);
    NSString *result = [self stringByJoiningWith:@"." firstParamenter:string parameterList:args];
    va_end(args);
    return result;
}

- (NSString *)stringByJoiningWithDot:(NSString *)string, ... {
    va_list args;
    va_start(args, string);
    NSString *result = [self.class stringByJoiningWith:@"." firstParamenter:string parameterList:args];
    va_end(args);
    return [self.class stringByJoiningWithDot:self, result, nil];
}

+ (NSString *)stringByJoiningWith:(NSString *)separator firstParamenter:(NSString *)string parameterList:(va_list)valist {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str = string; str != nil; str = va_arg(valist, NSString *)) {
        [array addObject:str];
    }
    return [array componentsJoinedByString:separator];
}

-(NSString *)firstCharacterCapitalizedString {
    return [self stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                      withString:[[self  substringToIndex:1] uppercaseString]];
}

#pragma mark - Scalar transformations

- (CGPoint)CGPointValue {
    return CGPointFromString(self);
}

- (CGRect)rectValue {
    return CGRectFromString(self);
}

- (NSRange)rangeValue {
    return NSRangeFromString(self);
}

- (CGSize)sizeValue {
    return CGSizeFromString(self);
}

- (CGRange)CGRangeValue {
    NSArray *comps = self.arrayValue;
    return (CGRange) {[comps[0] floatValue], [comps[1] floatValue]};
}

- (id)structComponents {
    // base case, no comma
    if ([self rangeOfString:@"{"].location == NSNotFound)
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    // parse the string in the standard struct form, putting all fields in an array
    id characterSet = [NSMutableCharacterSet whitespaceCharacterSet];
    [characterSet addCharactersInString:@"{}"];
    NSMutableArray *array = [NSMutableArray array];
    [[[self stringByTrimmingCharactersInSet:characterSet] componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString *substr, NSUInteger idx, BOOL *stop) {
        [array addObject:substr.structComponents];
    }];
    return array;
}

-(NSArray *)arrayValue {
    id components = self.structComponents;
    if ([components isKindOfClass:[NSArray class]])
        return components;
    return [NSArray arrayWithObject:components];
}

- (NSSet *)setValue {
    return [NSSet setWithArray:self.arrayValue];
}

- (NSIndexSet *)indexSetValue {
    return [NSIndexSet indexSetWithArray:self.arrayValue];
}



@end