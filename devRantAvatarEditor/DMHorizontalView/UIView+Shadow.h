//
//  UIView+Shadow.h
//  LogoPogo_Ver.2_iOS
//
//  Created by David Martinez Lebron on 5/19/15.
//  Copyright (c) 2015 LogoPogo_David Martinez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shadow)

/**
 Adds bottom shadow to UIView.
 */
-(void) addBottomShadow;

-(void) addShadowWithColor:(UIColor *) shadowColor;

-(void) removeShadow;

@end
