//
//  CalculationsUtils.m
//  Created by David Martinez Lebron on 5/12/15.
//  Copyright (c) 2015 Davaur_David Martinez. All rights reserved.
//
//

#import "CalculationsUtils.h"

@implementation CalculationsUtils

+(CGFloat) centerForSuperView:(CGFloat) viewSize withSize:(CGFloat) subviewSize {
    
    CGFloat (^center)(CGFloat, CGFloat) = ^(CGFloat viewSize, CGFloat subviewSize){
        return ((viewSize/2) - (subviewSize/2));
    };
    
    return center(viewSize, subviewSize);
}


+(CGFloat) centerForObjectWithFrame:(CGRect) objectFrame inXAxis:(BOOL) inXAxis{
    if (inXAxis)
        return objectFrame.origin.x + (objectFrame.size.width/2);
    
    return objectFrame.origin.y + (objectFrame.size.height/2);
}


+(int) numberThatFitInScreen:(CGFloat) width withWidthBetweenViews: (CGFloat) separation {
    
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    return (screenWidth / (width + separation));
}




+(CGFloat) paddingBetweenViewsArray: (NSArray *) viewsArray inSuperView:(UIView *) superView {
    
    CGFloat superViewWidth = CGRectGetWidth(superView.frame);
    
    CGFloat subviewWidth = CGRectGetWidth([viewsArray[0] frame]);

    CGFloat superViewWidthSurplus = superViewWidth - (subviewWidth * viewsArray.count);
    
    CGFloat separation = (superViewWidthSurplus / viewsArray.count);
    
    CGFloat padding = separation/2;
    
    return padding <= 0 ? 1.0f : padding;
}




@end









