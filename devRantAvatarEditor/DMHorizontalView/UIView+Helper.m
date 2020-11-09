//
//  UIView+Helper.m
//  Demo
//
//  Created by Dava on 5/10/16.
//  Copyright © 2016 Davaur. All rights reserved.
//

#import "UIView+Helper.h"
#import "UILabel+Subview.h"

@implementation UIView (Helper)

-(BOOL) canAddSubview:(CGRect) subviewFrame withOrigin:(CGPoint) origin withSeparation: (CGFloat) separation {
    
    CGFloat originX = origin.x + separation;
    CGFloat nextOriginX = originX + CGRectGetWidth(subviewFrame);
    CGFloat originY = origin.y;
    
    if (nextOriginX + CGRectGetWidth(subviewFrame) > CGRectGetWidth(self.frame)) {
        
        UILabel *treeDots = [UILabel labelForLastSubviewWithFrame:CGRectMake(originX, originY, CGRectGetWidth(subviewFrame), CGRectGetHeight(subviewFrame))];
        [self addSubview:treeDots];
        
        return false;
    }
    
    return true;
}

@end
