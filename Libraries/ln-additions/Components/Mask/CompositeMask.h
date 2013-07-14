//
// Created by Lingnan Dai on 23/04/2013.
//


#import <Foundation/Foundation.h>
#import "Mask.h"


@interface CompositeMask : Mask
@property(nonatomic, strong) id<NSFastEnumeration> nodeContainer;

- (id)initWithNodeContainer:(id<NSFastEnumeration>)container;

+ (id)maskWithNodeContainer:(id<NSFastEnumeration>)container;
@end