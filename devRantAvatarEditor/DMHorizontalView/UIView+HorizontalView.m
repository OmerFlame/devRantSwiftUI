//
//  UIView+HorizontalView.m
//
//  Created by David Martinez Lebron on 5/12/15.
//  Copyright (c) 2015 Davaur_David Martinez. All rights reserved.
//

#import "UIView+HorizontalView.h"
#import "UIView+Helper.h"

//  Size between wallet views in userWalletCell
static CGFloat const kPaddingBetweenSubviews = 16;
static CGFloat const kOverlapValue = 0.8;
static CGFloat const kVerticalMargin = 1.0;
static CGFloat const kDefaultOriginY = -1;
static CGFloat const kAnimationDuration = 0.50f;
static CGFloat const kSpringDamping = 0.50f;
static CGFloat const kHeightMinimumDifference = 2.0f;

@implementation UIView (HorizontalView)


-(void) horizontalViewWithViewsArray:(NSArray<UIView *> *) viewsArray withHorizontalDistribution:(HorizontalDistribution) horizontalDistribution andVerticalLocation:(VerticalLocation) verticalLocation {
    
    // update height constraint
    NSLayoutConstraint *heightConstraint;
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            break;
        }
    }
    
    
    // views array must contain at least one value
    if (viewsArray.count < 1)
        return;
    
    
    /*
     Subviews height must not be larger than superview height.
     Subviews width must not be larger than superview width.
     */
    
    const CGSize subviewSize = [viewsArray[0] frame].size;
    
    if (subviewSize.width > self.frame.size.width)
        return;
    
    if (subviewSize.height > self.frame.size.height) {
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetWidth(self.frame), subviewSize.height + kHeightMinimumDifference);
        heightConstraint.constant = CGRectGetHeight(self.frame);
        [self setNeedsUpdateConstraints];
    }
    
    NSAssert(subviewSize.width < self.frame.size.width, @"Subviews width can't be bigger than superview");
    NSAssert(subviewSize.height <= self.frame.size.height, @"Subviews height can't be bigger than superview");
    
    [self removeAllSubviews];
    
    CGFloat originY = 0;
    
    // prepare vertival location
    switch (verticalLocation) {
        case VerticalLocationTop:
            originY = kVerticalMargin;
            break;
            
        case VerticalLocationCenter:
            originY = [CalculationsUtils centerForSuperView:CGRectGetHeight(self.frame) withSize:subviewSize.height];
            break;
            
        case VerticalLocationBottom:
            originY = (CGRectGetHeight(self.frame) - subviewSize.height) - kVerticalMargin;
            break;
            
        default:
            break;
    }
    
    
    // prepare horizontal distribution
    switch (horizontalDistribution) {
        case HorizontalDistributionFill:
            
            [self prepareDistrutionFill:viewsArray withOriginY:originY];
            
            break;
            
        case HorizontalDistributionOverlap:
            
            [self prepareDistributionOverlap:viewsArray withOriginY:originY];
            
            break;
            
        case HorizontalDistributionNormal:
            
            [self prepareDistributionNormal:viewsArray withOriginY:originY];
            
            break;
            
        default:
            break;
    }
    
    
    [self layoutIfNeeded];
}


-(void) animateWithHorizontalDistribution:(HorizontalDistribution) horizontalDistribution {
    NSMutableArray *subviewsArray = [NSMutableArray array];
    
    for (UIView *subview in [self subviews]) {
        [subviewsArray addObject:subview];
    }
    
    // prepare horizontal distribution
    switch (horizontalDistribution) {
        case HorizontalDistributionFill:
            
            [self animateHoriontalDistrutionFill:subviewsArray];
            
            break;
            
        case HorizontalDistributionOverlap:
            
            [self animateHoriontalDistrutionOverlapped:subviewsArray];
            
            break;
            
        case HorizontalDistributionNormal:
            
            [self animateHoriontalDistrutionNormal:subviewsArray];
            
            break;
            
        default:
            break;
    }
}

#pragma Mark- Distribution Normal
-(void) prepareDistributionNormal: (NSArray<UIView *>*) viewsArray withOriginY:(CGFloat) originY {
    
    const CGFloat kHorizontalDistributionNormalPadding = 5.0f;

    //  Calculates View location to be centered if horizontalDistribution == true else, sets initial x = 0
    CGFloat originX = 0;
    
    CGFloat lastSubviewOriginX = 0.0;
    
    for (UIView *subview in viewsArray) {
        
        if (originY == kDefaultOriginY)
            originY = subview.frame.origin.y;
        
        if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:kHorizontalDistributionNormalPadding]) {
            return;
        }
        
        if (lastSubviewOriginX > 0.0) {
            originX = lastSubviewOriginX + (CGRectGetWidth(subview.frame));
            originX += kHorizontalDistributionNormalPadding;
        }
        
        else{
            originX = 1;
        }
        
        [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        lastSubviewOriginX = subview.frame.origin.x;
        
        [self addSubview:subview];
    }
}

#pragma Mark- Distribution Overlap
-(void) prepareDistributionOverlap:(NSArray<UIView *>*) viewsArray withOriginY:(CGFloat) originY {
    
    CGFloat lastSubviewOriginX = 0.0;
    
    //  Calculates View location to be centered if horizontalDistribution == true else, sets initial x = 0
    CGFloat originX = 0;
    
    for (UIView *subview in viewsArray) {
        
        if (originY == kDefaultOriginY)
            originY = subview.frame.origin.y;
        
        // add borders with the same color of the superview
        [[subview layer] setBorderWidth:1.0f];
        [[subview layer] setBorderColor:[self backgroundColor].CGColor];
        
        if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:kOverlapValue]) {
            return;
        }
        
        if (lastSubviewOriginX > 0.0) {
            originX = lastSubviewOriginX + (kOverlapValue * CGRectGetWidth(subview.frame));
        }
        
        else
            originX = 1;
        
        
        [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        lastSubviewOriginX = subview.frame.origin.x;
        
        [self addSubview:subview];
    }

}

#pragma Mark- Distribution Fill
-(void) prepareDistrutionFill: (NSArray<UIView *>*) viewsArray withOriginY:(CGFloat) originY {
    
    const CGFloat padding = [CalculationsUtils paddingBetweenViewsArray:viewsArray inSuperView:self];
    CGFloat originX = 0;
    NSMutableArray *subviewsArray = [NSMutableArray array];
    
    for (UIView *subview in viewsArray) {
        
        originX += padding;
        
        if (originY == kDefaultOriginY)
            originY = subview.frame.origin.y;
        
        if (subview != viewsArray.lastObject) {
            if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:padding]) {
                break;
            }
        }
        
        [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        [subviewsArray addObject:subview];
        
        originX += padding; // add separation between subviews
        originX += (CGRectGetWidth(subview.frame)); // add the width of the subview
        
        [self addSubview:subview];
    }
}

#pragma mark- Animations
-(void) animateHoriontalDistrutionFill: (NSArray<UIView *>*) viewsArray {
    
    const CGSize kViewSize = [viewsArray[0] frame].size;
    const CGFloat originY = [viewsArray[0] frame].origin.y;
    
    CGFloat padding = 2.0f;
    CGFloat originX = 0;
    NSMutableArray *subviewsArray = [NSMutableArray array];
    
    // get number of UIViews that will fit on the screen
    const int numberOfViews = [CalculationsUtils numberThatFitInScreen:kViewSize.width withWidthBetweenViews:padding];
    
    // re-distribute separation
    if (viewsArray.count < numberOfViews) {
        padding = [CalculationsUtils paddingBetweenViewsArray:viewsArray inSuperView:self];
    }
    
    for (UIView *subview in viewsArray) {
        
        originX += padding;
        
        if (subview != viewsArray.lastObject) {
            if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:padding]) {
                break;
            }
        }
        
        // animates subview
        [UIView animateWithDuration:kAnimationDuration delay:0.0 usingSpringWithDamping:kSpringDamping initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        } completion:nil];
        
        [subviewsArray addObject:subview];
        
        originX += padding; // add separation between subviews
        originX += (CGRectGetWidth(subview.frame)); // add the width of the subview

    }
}

-(void) animateHoriontalDistrutionOverlapped: (NSArray<UIView *>*) viewsArray {
    
    CGFloat lastSubviewOriginX = 0.0;
    const CGFloat originY = [viewsArray[0] frame].origin.y;
    
    //  Calculates View location to be centered if horizontalDistribution == true else, sets initial x = 0
    CGFloat originX = 0;
    
    for (UIView *subview in viewsArray) {
        
        // add borders with the same color of the superview
        [[subview layer] setBorderWidth:1.0f];
        [[subview layer] setBorderColor:[self backgroundColor].CGColor];
        
        if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:kOverlapValue]) {
            return;
        }
        
        if (lastSubviewOriginX > 0.0) {
            originX = lastSubviewOriginX + (kOverlapValue * CGRectGetWidth(subview.frame));
        }
        
        else
            originX = 1;
        
        // animates subview
        [UIView animateWithDuration:kAnimationDuration delay:0.0 usingSpringWithDamping:kSpringDamping initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        } completion:nil];
        
        lastSubviewOriginX = subview.frame.origin.x;
    }
}

-(void) animateHoriontalDistrutionNormal: (NSArray<UIView *>*) viewsArray {
    
    const CGFloat kHorizontalDistributionNormalPadding = 5.0f;
    const CGFloat originY = [viewsArray[0] frame].origin.y;
    
    //  Calculates View location to be centered if horizontalDistribution == true else, sets initial x = 0
    CGFloat originX = 0;
    
    CGFloat lastSubviewOriginX = 0.0;
    
    for (UIView *subview in viewsArray) {
        
        if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:kHorizontalDistributionNormalPadding]) {
            return;
        }
        
        if (lastSubviewOriginX > 0.0) {
            originX = lastSubviewOriginX + (CGRectGetWidth(subview.frame));
            originX += kHorizontalDistributionNormalPadding;
        }
        
        else{
            originX = 1;
        }
        
        // animates subview
        [UIView animateWithDuration:kAnimationDuration delay:0.0 usingSpringWithDamping:kSpringDamping initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        } completion:nil];
        
        lastSubviewOriginX = subview.frame.origin.x;
    }
}


-(CGFloat) divideIntoSegmentsWithObjects:(NSArray<UIView *> *) objectsArray {
    
    void (^addSubViewInSegment)(id, CGRect) = ^(id object, CGRect rect){
        
        [object setFrame:rect];
        
        [self addSubview:object];
        
        object = nil;
    };
    
    
    [self removeAllSubviews];
    
    NSInteger numberOfSegments = [objectsArray count];
    NSInteger divisors = numberOfSegments - 1;
    NSInteger screenSize = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat viewWidth = (CGFloat)screenSize;
    
    const CGFloat distance = (viewWidth - kPaddingBetweenSubviews)/numberOfSegments;
    
    CGFloat originX = distance;
    
    for (int i=0; i < numberOfSegments; i++){
        
        if (i == 0){
            [self addLineFromX:originX];
        }
        
        else if (i < divisors){
            [self addLineFromX:originX];
        }
        
        //
        //  Asserts that the number of images in the array are equal to the number of segments
        //
        if (objectsArray){
            NSAssert(objectsArray.count == numberOfSegments, @"The number of objects in the array must be equivalent to the number of segments");
            //
            //  Takes the first xLocation = distance + 0
            //
            //  and substract distance/2 to get the center of the previous segment
            //
            
            id object = objectsArray[i];
            
            addSubViewInSegment(object, CGRectMake((originX - (distance/2)) - (CGRectGetWidth([object frame])/2), 2, CGRectGetWidth([object frame]), CGRectGetHeight([object frame])));
        }
        
        originX += distance;
    }
    return distance;
}


-(void) addLineFromX:(CGFloat) xLocation{
    
    CGFloat viewHeight = self.bounds.size.height;
    
    static CGFloat startingY = 10.0;
    
    CGFloat endingY = viewHeight - 10.0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(xLocation, startingY)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.strokeColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    shapeLayer.lineWidth = 1.5;
    
    [self.layer addSublayer:shapeLayer];
    
    [path addLineToPoint:CGPointMake(xLocation, endingY)];
    
    shapeLayer.path = path.CGPath;
    
    path = nil;
    
    shapeLayer = nil;
    
    //
    //  This code only works inside a drawRect
    //
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    //    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    //
    //    // Draw them with a 2.0 stroke width so they are a bit more visible.
    //    CGContextSetLineWidth(context, 2.0f);
    //
    //    CGContextMoveToPoint(context, xLocation, startingY); //start at this point
    //
    //    CGContextAddLineToPoint(context, xLocation, endingY); //draw to this point
    //
    //    // and now draw the Path!
    //    CGContextStrokePath(context);
    
    //
    //  Ends
    //
}


@end
