//
//  MSTimeRowHeaderBackground.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSTimeRowHeaderBackground.h"
#import "OremiaMobile2-Swift.h"

@implementation MSTimeRowHeaderBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [LoadingOverlay updateBlur:self];
    }
    return self;
}

@end
