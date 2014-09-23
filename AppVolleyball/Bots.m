//
//  PlayerBots.m
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/13/13.
//  Copyright 2013 Paul Rolfe. All rights reserved.
//

#import "Bots.h"
#import "Ball.h"
#import "bezierDetector.h"


@implementation Bots
@synthesize start;

+ (id)botWithTexture:(CCTexture2D *)aTexture
{
	return [[[self alloc] initWithTexture:aTexture] autorelease];
}

- (void)onEnter
{
    
	[super onEnter];
}

- (void)onExit
{
    
	[super onExit];
}
- (void) moveToPosition:(CGPoint)point{
    
    float scaleF = .4+(320-point.y)/320;

    id actionUp = [CCMoveTo actionWithDuration:1 position:point];
    id zoomWithT = [CCScaleTo actionWithDuration:1 scale:scaleF];
    
    id action = [CCSpawn actions:
				 actionUp,
				 zoomWithT,
				 nil];
    [self runAction:action];
}
-(void) moveInDirection:(CGPoint)velocity time:(ccTime)delta{
    float maxY = 181+self.boundingBox.size.height/2;
    
    if (self.position.y<maxY){
        velocity = ccp(velocity.x,0);
    }
    
    self.position = ccpAdd(self.position, ccpMult(velocity, delta));

    float scaleF=.4+(320-self.position.y)/320;
    self.scale=scaleF;
}
-(void) movePartnerInDirection:(CGPoint)velocity time:(ccTime)delta{
    float maxY = 181+self.boundingBox.size.height/3;
    
    if (self.position.y>maxY){
        velocity = ccp(0,0);
    }
    
    self.position = ccpAdd(self.position, ccpMult(velocity, delta));
    
    float scaleF=.4+(320-self.position.y)/320;
    self.scale=scaleF;
}

- (void) jumpAction{
    id doJump = [CCJumpTo actionWithDuration:1.2 position:self.position height:70 jumps:1];
    [self runAction:doJump];
}
- (void) wiggle{
    CCPointArray *array = [CCPointArray arrayWithCapacity:20];
    
	[array addControlPoint:ccp(0,0)];
	[array addControlPoint:ccp(30,0)];
	[array addControlPoint:ccp(30,30)];
	[array addControlPoint:ccp(-30,30)];
	[array addControlPoint:ccp(-30,-30)];
	[array addControlPoint:ccp(0,-30)];
	[array addControlPoint:ccp(0,0)];
    
	CCCatmullRomBy *action = [CCCatmullRomBy actionWithDuration:2 points:array];
	id reverse = [action reverse];
	
	CCSequence *seq = [CCSequence actions:action, reverse, nil];
	
	[self runAction: seq].tag=844;
}


@end
