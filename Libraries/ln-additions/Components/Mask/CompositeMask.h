//
// Created by Lingnan Dai on 23/04/2013.
//


#import <Foundation/Foundation.h>
#import "Mask.h"


@interface CompositeMask : Mask
@property(nonatomic, strong) id<NSFastEnumeration> container;

- (id)initWithContainer:(id<NSFastEnumeration>)container;

- (id)copyWithZone:(NSZone *)zone;

+ (id)maskWithContainer:(id<NSFastEnumeration>)container;
@end