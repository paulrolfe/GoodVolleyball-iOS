
#import "Ball.h"
#import "Paddle.h"

@implementation Ball

@synthesize velocity,start,end;

- (float)radius
{
	return self.texture.contentSize.width / 2;
}

+ (id)ballWithTexture:(CCTexture2D *)aTexture
{
	return [[[self alloc] initWithTexture:aTexture] autorelease];
}

-(void)toss{
    id actionUp = [CCJumpTo actionWithDuration:2 position:self.position height:80 jumps:1];
    [self runAction:actionUp].tag=1;
    [self performSelector:@selector(resetState) withObject:self afterDelay:2];
    
}
-(void)tossByBot{
    id actionUp = [CCJumpTo actionWithDuration:1 position:self.position height:40 jumps:1];
    [self runAction:actionUp].tag=11;
    [[NSUserDefaults standardUserDefaults] setObject:@"kBotTossed" forKey:@"stateOfPlay"];
    
}
-(void)tossByPartnerBot{
    id actionUp = [CCJumpTo actionWithDuration:2 position:self.position height:80 jumps:1];
    [self runAction:actionUp].tag=12;
    [[NSUserDefaults standardUserDefaults] setObject:@"kBotTossed" forKey:@"stateOfPlay"];
    
}
- (void) serveBotAnimation{
    //CGSize s = [[CCDirector sharedDirector] winSize];
    
    
    //I want this curve to be the opposite of the other serving curve.
	ccBezierConfig bezier;
    bezier.controlPoint_1 = ccp(.5*velocity.x,20);
	bezier.controlPoint_2 = ccp(velocity.x,.5*velocity.y);
	bezier.endPosition = velocity;
    
    
	
    //Make the duration be in relation to the distance traveling.
	id bezierForward = [CCBezierBy actionWithDuration:1.2 bezier:bezier];
    
    float scaleF = .4+(320-end.y)/320;

    //id straightMove = [CCMoveTo actionWithDuration:1.2 position:self.velocity];
    id zoomWithT = [CCScaleTo actionWithDuration:1.2 scale:scaleF];
    
    id action = [CCSpawn actions:
				 bezierForward,
				 zoomWithT,
				 nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"kBotTossed" forKey:@"stateOfPlay"];

    
    [self runAction:action].tag=32;
    
}

- (void) serveAnimation{
    //CGSize s = [[CCDirector sharedDirector] winSize];
    
	// sprite 1
	ccBezierConfig bezier;
	bezier.controlPoint_1 = ccp(0,self.velocity.y-5);
	bezier.controlPoint_2 = ccp(self.velocity.x,self.velocity.y+80);
	bezier.endPosition = self.velocity;
    
    float scaleF = .4+(320-end.y)/320;

	
    //Make the duration be in relation to the distance traveling.
	id bezierForward = [CCBezierBy actionWithDuration:1.2 bezier:bezier];
    id zoomWithT = [CCScaleTo actionWithDuration:1.2 scale:scaleF];
    
    id action = [CCSpawn actions:
				 bezierForward,
				 zoomWithT,
				 nil];
    
    [self runAction:action].tag=33;
    
}
- (void) passAnimation{
    ccBezierConfig bezier;
	bezier.controlPoint_1 = ccp(0,0);
	bezier.controlPoint_2 = ccp(self.velocity.x/2,self.velocity.y+200);
	bezier.endPosition = self.velocity;
    
    float scaleF = .4+(320-end.y)/320;
	
    //Make the duration be in relation to the distance traveling.
	id bezierForward = [CCBezierBy actionWithDuration:1.4 bezier:bezier];
    id zoomWithT = [CCScaleTo actionWithDuration:1.4 scale:scaleF];
    
    id action = [CCSpawn actions:
				 bezierForward,
				 zoomWithT,
				 nil];
    
    [self runAction:action].tag=2;
}
- (void) settingAnimation{
    ccBezierConfig bezier;
	bezier.controlPoint_1 = ccp(0,self.velocity.y+10);
	bezier.controlPoint_2 = ccp(self.velocity.x/2,self.velocity.y+200);
	bezier.endPosition = self.velocity;
    
    //Make the duration be in relation to the distance traveling.
	id bezierForward = [CCBezierBy actionWithDuration:1.5 bezier:bezier];
    
    [self runAction:bezierForward].tag=4;
}
- (void) hittingAnimation{
    //Make the duration be in relation to the distance traveling.
	id hit = [CCMoveTo actionWithDuration:.7 position:velocity];
    
    float scaleF = .4+(320-velocity.y)/320;
    id rotate = [CCRotateBy actionWithDuration:.7 angle:1080];
    id zoomWithT = [CCScaleTo actionWithDuration:.7 scale:scaleF];
    
    id action = [CCSpawn actions:
				 hit,
				 zoomWithT,
                 rotate,
				 nil];

    
    [self runAction:action].tag=44;
}
- (void) hittingAnimationPower{
    //Make the duration be in relation to the distance traveling.
	id hit = [CCMoveTo actionWithDuration:3 position:velocity];
    
    float scaleF = .4+(320-velocity.y)/320;
    //id rotate = [CCRotateBy actionWithDuration:3 angle:1080];
    id zoomWithT = [CCScaleTo actionWithDuration:3 scale:scaleF];
    
    id action = [CCSpawn actions:
				 hit,
				 zoomWithT,
				 nil];
    
    
    [self runAction:action].tag=44;
}
- (void) passAnimationLow{
    ccBezierConfig bezier;
	bezier.controlPoint_1 = ccp(0,self.velocity.y+10);
	bezier.controlPoint_2 = ccp(self.velocity.x/2,self.velocity.y+200);
	bezier.endPosition = self.velocity;
    
    float scaleF = .4+(320-end.y)/320;

	
    //Make the duration be in relation to the distance traveling.
	id bezierForward = [CCBezierBy actionWithDuration:1.4 bezier:bezier];
    id zoomWithT = [CCScaleTo actionWithDuration:1.4 scale:scaleF];
    
    id action = [CCSpawn actions:
				 bezierForward,
				 zoomWithT,
				 nil];
    
    [self runAction:action].tag=5;
}


- (void)resetState{
    NSString *stateOfPlay=[[NSUserDefaults standardUserDefaults]objectForKey:@"stateOfPlay"];
    if ([stateOfPlay isEqualToString:@"jTossed"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"jMissedServe" forKey:@"stateOfPlay"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void) bounceAround{

    id pass = [CCJumpBy actionWithDuration:1.4 position:velocity height:80 jumps:1];
    id pass_back = [pass reverse];//[CCJumpTo actionWithDuration:1.4 position:start height:80 jumps:1];
    id both = [CCSequence actionOne:pass two:pass_back];
    id repeat_both = [CCRepeatForever actionWithAction:both];
    [self runAction:repeat_both];
    
}

@end
