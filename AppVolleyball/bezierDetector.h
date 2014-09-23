//
//  bezierDetector.h
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/13/13.
//  Copyright (c) 2013 Paul Rolfe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDirector.h"

@interface bezierDetector : NSObject

- (BOOL)pointIsInHighCourt:(CGPoint) point;
- (BOOL)pointIsInLowCourt:(CGPoint) point;

@end
