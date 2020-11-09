//
//  UIView+Helper.h
//  Demo
//
//  Created by Dava on 5/10/16.
//  Copyright © 2016 Davaur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helper)


-(BOOL) canAddSubview:(CGRect) subviewFrame withOrigin:(CGPoint) origin withSeparation: (CGFloat) separation;

@end
