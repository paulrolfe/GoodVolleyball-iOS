//
//  PlayerBots.h
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/13/13.
//  Copyright 2013 Paul Rolfe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Bots : CCSprite {
    
}

@property (nonatomic) CGPoint start;

+ (id)botWithTexture:(CCTexture2D *)aTexture;
- (void) moveToPosition:(CGPoint)point;
- (void) moveInDirection: (CGPoint)velocity time:(ccTime)delta;
- (void) movePartnerInDirection: (CGPoint)velocity time:(ccTime)delta;

- (void) jumpAction;
-(void) wiggle;

@end
