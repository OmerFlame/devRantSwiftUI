//
//  CalculationsUtils.h
//  Created by David Martinez Lebron on 5/12/15.
//  Copyright (c) 2015 Davaur_David Martinez. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CalculationsUtils : NSObject



/**
 
 */
+(CGFloat) centerForSuperView:(CGFloat) viewWidth withSize:(CGFloat) subviewSize;



/**
 Calculates the center for an object. If inXAxis is false, calculates using Height and Y location, else uses Width and X location.
 */
+(CGFloat) centerForObjectWithFrame:(CGRect) objectFrame inXAxis:(BOOL) inXAxis;



+(int) numberThatFitInScreen:(CGFloat) width withWidthBetweenViews: (CGFloat) separation;



+(CGFloat) paddingBetweenViewsArray: (NSArray *) viewsArray inSuperView:(UIView *) superView;







@end
