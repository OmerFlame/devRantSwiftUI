//
//  UILabel+Subview.m
//  Created by David Martinez Lebron on 5/12/15.
//  Copyright (c) 2015 Davaur_David Martinez. All rights reserved.
//
//

#import "UILabel+Subview.h"

@implementation UILabel (Subview)


+(UILabel *) labelForLastSubviewWithFrame: (CGRect) rect {
    UILabel *periods = [[UILabel alloc] initWithFrame:rect];
    [periods setText:@"..."];
    [periods setBackgroundColor:[UIColor clearColor]];
    [periods setTextColor:[UIColor lightGrayColor]];
    return periods;
}

@end
