//
//  NCISeries.h
//  Pods
//
//  Created by Lappy on 4/2/15.
//
//

#import <Foundation/Foundation.h>

@interface NCISeries : NSObject //<NSFastEnumeration>
{
@public
    float* _x;
    float* _y;
}

-(id)initWithArrays:(NSUInteger)count xValues:(float *)x yValues:(float*)y;

@property (nonatomic, readonly) NSUInteger count;

@end
