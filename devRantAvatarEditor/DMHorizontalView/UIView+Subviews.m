//
//  UIView+Subviews.m
//  DMHorizontalView
//
//  Created by David Martinez Lebron on 4/3/16.
//  Copyright © 2016 Davaur. All rights reserved.
//

#import "UIView+Subviews.h"

@implementation UIView (Subviews)


-(void) removeAllSubviews {
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
}


@end
