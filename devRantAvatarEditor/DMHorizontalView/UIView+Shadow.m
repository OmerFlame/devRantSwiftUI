//
//  UIView+Shadow.m
//  LogoPogo_Ver.2_iOS
//
//  Created by David Martinez Lebron on 5/19/15.
//  Copyright (c) 2015 LogoPogo_David Martinez. All rights reserved.
//

#import "UIView+Shadow.h"

@implementation UIView (Shadow)

-(void) addBottomShadow {
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
}

-(void) addShadowWithColor:(UIColor *) shadowColor {
    self.layer.shadowColor = [shadowColor CGColor];
    
    self.layer.shadowOpacity = 1.0;
    
    self.layer.shadowRadius = 2.0;
    
    self.layer.shadowOffset = CGSizeMake(0, 0);
}

-(void) removeShadow {
    self.layer.shadowColor = [[UIColor clearColor] CGColor];
    self.layer.shadowOpacity = 0.0;
    self.layer.shadowRadius = 0.0;
    self.layer.shadowOffset = CGSizeMake(0, 0);
}

@end
