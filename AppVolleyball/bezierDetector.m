//
//  bezierDetector.m
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/13/13.
//  Copyright (c) 2013 Paul Rolfe. All rights reserved.
//

#import "bezierDetector.h"

@implementation bezierDetector


- (BOOL)pointIsInHighCourt:(CGPoint) point{
    

    UIImage * background = [UIImage imageNamed:@"court2.png"];
    CGSize s = [[CCDirector sharedDirector] winSize];
    float screenScale = s.width/background.size.width*2;
    
    //define the boundaries of the court two. with trCorner, etc. (for a 4 inch screen)
    
    UIBezierPath *highCourtBounds;
    CGPoint tlCorner = CGPointMake(114*screenScale,260.5);
    CGPoint trCorner = CGPointMake(440.5*screenScale, 260.5);
    CGPoint midrCorner = CGPointMake(468*screenScale, 180);
    CGPoint midlCorner = CGPointMake(87*screenScale, 179);
    
    highCourtBounds = [UIBezierPath bezierPath];
    highCourtBounds.usesEvenOddFillRule=YES;
    highCourtBounds.lineWidth=4.0f;
    [highCourtBounds moveToPoint:midlCorner];
    [highCourtBounds addLineToPoint:tlCorner];
    [highCourtBounds addLineToPoint:trCorner];
    [highCourtBounds addLineToPoint:midrCorner];
    [highCourtBounds closePath]; // Implicitly does a line between p4 and p1
    
    if ([highCourtBounds containsPoint:point])
        return YES;
    
    else return NO;
}

- (BOOL)pointIsInLowCourt:(CGPoint) point{
    
    //define the boundaries of the court two. with trCorner, etc. (for a 4 inch screen)
    UIImage * background = [UIImage imageNamed:@"court2.png"];
    CGSize s = [[CCDirector sharedDirector] winSize];
    float screenScale = s.width/background.size.width*2;
    
    UIBezierPath *lowCourtBounds;
    CGPoint blCorner = CGPointMake(25*screenScale,11);
    CGPoint brCorner = CGPointMake(525.5*screenScale,10);
    CGPoint midrCorner = CGPointMake(468*screenScale, 180);
    CGPoint midlCorner = CGPointMake(88.5*screenScale, 179);
    
    lowCourtBounds = [UIBezierPath bezierPath];
    lowCourtBounds.usesEvenOddFillRule=YES;
    [lowCourtBounds moveToPoint:blCorner];
    [lowCourtBounds addLineToPoint:midlCorner];
    [lowCourtBounds addLineToPoint:midrCorner];
    [lowCourtBounds addLineToPoint:brCorner];
    [lowCourtBounds closePath]; // Implicitly does a line between p4 and p1
    [lowCourtBounds setLineWidth:1];
    
    
    if ([lowCourtBounds containsPoint:point])
        return YES;
    
    else return NO;
}




@end
