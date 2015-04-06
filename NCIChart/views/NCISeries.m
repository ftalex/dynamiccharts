//
//  NCISeries.m
//  Pods
//
//  Created by Lappy on 4/2/15.
//
//

#import "NCISeries.h"


@implementation NCISeries

@synthesize count = _count;

- (id)init
{
    self = [super init];
    if (self) {
        _count = 0;
        _x = 0;
        _y = 0;
    }
    return self;
}

-(id)initWithCount:(NSUInteger)count xValues:(float *)x yValues:(float*)y
{
    self = [super init];
    if (self) {
        _count = count;
        _x = x;
        _y = y;
    }
    return self;
}

- (void)dealloc
{
    free(_x);
    free(_y);
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
