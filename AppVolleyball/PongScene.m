
#import "PongScene.h"
#import "Ball.h"


enum tagPlayer {
	kHighPlayer,
	kLowPlayer
} Player;

#define kStatusBarHeight 20.0f
#define k1UpperLimit (320.0f - kStatusBarHeight)


@interface PongLayer ()
@end

@implementation PongScene

float netTop = 251.5;
float netBottom = 203.5;
Bots *theBot;
Bots *otherBot;
CCSprite *background;

float screenScale;

BOOL iamhitter;
BOOL iamserver;

int stillCount;

BOOL lowServed;

BOOL LBotServes;
BOOL RBotServes;
BOOL PBotServes;
BOOL paddleServes;

int powerCount;

CGPoint aPlayerPoint;
CGPoint aBallPoint;

CGPoint whereBallIs;
CGPoint whereBallWas;


- (id)init
{
	if ((self = [super init]) == nil) return nil;
    

	MenuLayer *menuLayer = [MenuLayer node];
	[self addChild:menuLayer];

	return self;
}

- (void)onExit
{
	[super onExit];
}

@end

@implementation PongLayer
@synthesize stats;

- (id)init
{
	if ((self = [super init]) == nil) return nil;
    
    CCDirector *director =  [CCDirector sharedDirector];
    
    [[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    [self resetStats];
	[self resetPositions];
    [[NSUserDefaults standardUserDefaults] setObject:@"jPreServe" forKey:@"stateOfPlay"];
    
    [self schedule:@selector(doStep:)];

	return self;
}
- (void) resetStats{
    yourScore =0;
    botScore =0;
    powerCount=0;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stats"];
    NSMutableArray *rawStatsArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.stats = [rawStatsArray lastObject];
    
    if (self.stats){
        gamesPlayed = [[self.stats valueForKey:@"gamesPlayed"] intValue];
        gamesWon=[[self.stats valueForKey:@"gamesWon"] intValue];
        hitsAttempts=[[self.stats valueForKey:@"hitsAttempts"] intValue];
        hitsKills=[[self.stats valueForKey:@"hitsKills"] intValue];
        hitsErrors=[[self.stats valueForKey:@"hitsErrors"] intValue];
        digsMade=[[self.stats valueForKey:@"digsMade"] intValue];
        assistsMade=[[self.stats valueForKey:@"assistsMade"] intValue];
        powerSpikes=[[self.stats valueForKey:@"powerSpikes"] intValue];
        pointsFor=[[self.stats valueForKey:@"pointsFor"] intValue];
        pointsAgainst=[[self.stats valueForKey:@"pointsAgainst"] intValue];
        servesAces=[[self.stats valueForKey:@"servesAces"] intValue];
        servesAttempts=[[self.stats valueForKey:@"servesAttempts"] intValue];
        servesErrors=[[self.stats valueForKey:@"servesErrors"] intValue];
    }
    else{
        hitsAttempts=0;
        hitsErrors=0;
        hitsKills=0;
        digsMade=0;
        assistsMade=0;
        powerSpikes=0;
        servesErrors=0;
        servesAttempts=0;
        servesAces=0;
    }
}

- (void) resetPositions{
    [self removeAllChildren];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    

    background = [CCSprite spriteWithFile:@"court2.png"];
    background.position = ccp(s.width/2, s.height/2);
    screenScale = s.width/background.boundingBox.size.width;
    background.scaleX = screenScale;
    //background.rotationX=45;
    [self addChild: background z:0];
    
    net = [CCSprite spriteWithFile:@"net.png"];
    net.position = ccp(s.width/2.05, s.height/1.51);
    net.scaleX = .7*background.scaleX;
    net.scaleY = .22;
    
    ballStartingVelocity = CGPointMake(0, 0);//CGPointMake(20.0f, -100.0f);
    
	ball = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"vball.png"]];
	ball.position = CGPointMake(s.width/3*2, 100);
	ball.velocity = ballStartingVelocity;
    
	CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
    
    //create the "paddle" aka the player
    
	paddle = [Paddle paddleWithTexture:paddleTexture];
    paddle.color=ccGREEN;
	paddle.position = CGPointMake(s.width/3*2, 100);
    paddle.start = CGPointMake(s.width/3*2, 100);
    
    //create the player bots
    //random start places
    float xL = s.width/3 + CCRANDOM_0_1() * 30;
    float xR = s.width/3*1.8 + CCRANDOM_0_1() * 30;
    float yL = 230 + CCRANDOM_0_1() * 20;
    float yR = 230 + CCRANDOM_0_1() * 20;
    
    //other side on left
    OtherBotL = [Bots botWithTexture:paddleTexture];
    OtherBotL.color = ccBLUE;
	OtherBotL.position = CGPointMake(xL, yL);
    float scaleF=.4+(320-OtherBotL.position.y)/320;
    OtherBotL.scale=scaleF;
    OtherBotL.start=OtherBotL.position;
    [self addChild:OtherBotL z:1];
    
    //other side on right
	OtherBotR = [Bots botWithTexture:paddleTexture];
    OtherBotR.color = ccBLUE;
	OtherBotR.position = CGPointMake(xR, yR);
    float scaleG=.4+(320-OtherBotR.position.y)/320;
    OtherBotR.scale=scaleG;
    OtherBotR.start=OtherBotR.position;
    [self addChild:OtherBotR z:1];
    
    //partner bot
	PartnerBot = [Bots botWithTexture:paddleTexture];
    PartnerBot.color = ccGREEN;
	PartnerBot.position = CGPointMake(s.width/3, 100);
    float scaleH=.4+(320-PartnerBot.position.y)/320;
    PartnerBot.scale=scaleH;
    PartnerBot.start=PartnerBot.position;
    
    [self addChild:ball z:4];
    
    [self addChild:net z:3];
    
    [self addChild:paddle z:5];

    [self addChild:PartnerBot z:5];
    
    CCTexture2D *powerTexture = [[CCTextureCache sharedTextureCache] addImage:@"powerspike.png"];
    powerMeter = [PowerUp powerWithTexture:powerTexture];
    powerMeter.scale=.2;
    powerMeter.position = ccp(s.width-50, s.height-60);
    powerMeter.start = ccp(s.width-50, s.height-60);
    powerMeter.end = CGPointZero;
    powerMeter.opacity =5+50*powerCount;
    if (powerCount >= 5){
        CCParticleSystem * emitter = [CCParticleFire node];
        emitter.positionType=kCCPositionTypeGrouped;
        emitter.position=CGPointMake(100,50);
        emitter.scale=3;
        emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
        [powerMeter addChild:emitter z:-1 tag:925];
        powerMeter.color = ccRED;
        powerMeter.isLive = YES;
        background.texture=[[CCTextureCache sharedTextureCache] addImage:@"court_black.png"];
    }
    [self addChild:powerMeter z:8];
    
    [self createMenu];
    [[NSUserDefaults standardUserDefaults] setObject:@"kNull" forKey:@"whichSide"];
    iamhitter=NO;
    stillCount = 0;

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[CCDirector sharedDirector].scheduler setTimeScale:1];
    
    [self schedule:@selector(doStep:)];
    
}
-(void) createMenu
{
    CCMenu *menu;
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
    
    CGSize s = [[CCDirector sharedDirector] winSize];

	
	// Pause Button
	CCMenuItemLabel *pause = [CCMenuItemFont itemWithString:@"Pause" block:^(id sender){
        
        //pause all actions
        [self pauseSchedulerAndActions];
        [ball pauseSchedulerAndActions];
        [paddle setPaused:YES];
        [OtherBotL pauseSchedulerAndActions];
        [OtherBotR pauseSchedulerAndActions];
        [PartnerBot pauseSchedulerAndActions];
        
        //grey out the background.
        CCSprite * greyScreen =[CCSprite spriteWithFile:@"blank.png"];
        greyScreen.position = ccp(s.width/2, s.height/2);
        greyScreen.scaleX = screenScale;
        greyScreen.color=ccGRAY;
        greyScreen.opacity=100;
        [self addChild: greyScreen z:7 tag:419];
        
        //display the pause screen w/ continue, restart, quit
        [self pauseMenu];
	}];
	

    
	menu = [CCMenu menuWithItems:pause, nil];
    [menu setColor:ccGRAY];
	
	[menu alignItemsVertically];
	
	[menu setPosition:ccp(30, 200)];
    menu.tag = 420;
	
	[self addChild: menu];
    
    // And the scoring "menu"!
    CCMenu *gameScore;
	[CCMenuItemFont setFontSize:22];
	
	// Bot score
	CCMenuItemLabel *botScoreLabel = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"Bots:%i",botScore] block:^(id sender){
	}];
	// My score
	CCMenuItemLabel *yourScoreLabel = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"You:%i",yourScore] block:^(id sender){

	}];
    yourScoreLabel.color = ccGREEN;
    botScoreLabel.color = ccBLUE;
    
	gameScore = [CCMenu menuWithItems:botScoreLabel, yourScoreLabel, nil];
	
	[gameScore alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[gameScore setPosition:ccp(size.width-40, 200)];
    gameScore.tag = 421;
    [self addChild:gameScore];
    
}
-(void) pauseMenu{
	[CCMenuItemFont setFontSize:22];
    [self removeChildByTag:420];
    
	
	// Continue
	CCMenuItemLabel *cont = [CCMenuItemFont itemWithString:@"Continue" block:^(id sender){
        //unpauses everything and dismisses the menus
        [self resumeSchedulerAndActions];
        [ball resumeSchedulerAndActions];
        [paddle resumeSchedulerAndActions];
        [paddle setPaused:NO];
        [OtherBotL resumeSchedulerAndActions];
        [OtherBotR resumeSchedulerAndActions];
        [PartnerBot resumeSchedulerAndActions];
        
        [self removeChildByTag:422];
        [self removeChildByTag:419];
        [self removeChildByTag:926];
        [self removeChildByTag:421];
        [self createMenu];
	}];
	// retart
	CCMenuItemLabel *restart = [CCMenuItemFont itemWithString:@"Restart" block:^(id sender){
        //restart everything
        [self resumeSchedulerAndActions];
        [ball resumeSchedulerAndActions];
        [paddle resumeSchedulerAndActions];
        [paddle setPaused:NO];
        [OtherBotL resumeSchedulerAndActions];
        [OtherBotR resumeSchedulerAndActions];
        [PartnerBot resumeSchedulerAndActions];

        yourScore =0;
        botScore =0;
        [[NSUserDefaults standardUserDefaults] setObject:@"jPreServe" forKey:@"stateOfPlay"];
        [self resetPositions];

        
	}];
    //Quit
    CCMenuItemLabel *quitItem = [CCMenuItemFont itemWithString:@"Quit" block:^(id sender){
       //goes to main menu. Main menu has... New Game, Statistics, Achievements (GameCenter), Instructions.
        //[self resumeSchedulerAndActions];

        CCScene *scene = [CCScene node];
        [scene addChild:[MenuLayer node]];
        [[CCDirector sharedDirector] replaceScene:scene];
        
	}];
    
    CCMenu *PauseMenu;
	PauseMenu = [CCMenu menuWithItems: cont, restart, quitItem, nil];
	[PauseMenu alignItemsVertically];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Good Volleyball" fontName:@"Helvetica" fontSize:32];
    label.color=ccGREEN;
    [self addChild:label z:100 tag:926];
    [label setPosition: ccp(size.width/2, size.height-40)];
	
	[PauseMenu setPosition:ccp(size.width/2, size.height/2)];
    [self addChild:PauseMenu z:8 tag:422];

}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)resetAndScoreBallForPlayer:(int)player
{
    // scoring + track some stats too!
    if (player == kLowPlayer){
        yourScore=yourScore+1;
        
        powerCount = powerCount+1;
        if (powerCount>5) powerCount=5;
        [[NSUserDefaults standardUserDefaults] setObject:@"jPreServe" forKey:@"stateOfPlay"];
        
        //set the server as the next server.
        if (LBotServes && !lowServed){
            LBotServes=NO;
            RBotServes=YES;
        }
        else if (RBotServes && !lowServed){
            RBotServes=NO;
            LBotServes=YES;
        }

        
    }
    if (player == kHighPlayer){
        botScore=botScore+1;
        
        //set the server as the next server.
        [[NSUserDefaults standardUserDefaults] setObject:@"kPreServe" forKey:@"stateOfPlay"];

        if (PBotServes && lowServed){
            PBotServes=NO;
            paddleServes=YES;
        }
        else if (paddleServes && lowServed){
            paddleServes=NO;
            PBotServes=YES;
        }
    }
    //If the score for either side is equal to 15, then move the end of game scene.
    if (yourScore>=15 && yourScore >= botScore+2){
        //Move to scene of results like with stats and stuff. Likely separate view controllers.
        //For now, show a UIalert and restart on OK.
        UIAlertView * GameOver = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"You won!" delegate:nil cancelButtonTitle:@"Yes! Let's play again!" otherButtonTitles: nil];
        [GameOver show];
        
        //Save the stats or make a new one.
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (self.stats){
            [self.stats setValue:[NSNumber numberWithInt:gamesPlayed+1] forKey:@"gamesPlayed"];
            [self.stats setValue:[NSNumber numberWithInt:gamesWon+1] forKey:@"gamesWon"];
            [self.stats setValue:[NSNumber numberWithInt:hitsAttempts] forKey:@"hitsAttempts"];
            [self.stats setValue:[NSNumber numberWithInt:hitsKills] forKey:@"hitsKills"];
            [self.stats setValue:[NSNumber numberWithInt:hitsErrors] forKey:@"hitsErrors"];
            [self.stats setValue:[NSNumber numberWithInt:digsMade] forKey:@"digsMade"];
            [self.stats setValue:[NSNumber numberWithInt:assistsMade] forKey:@"assistsMade"];
            [self.stats setValue:[NSNumber numberWithInt:powerSpikes] forKey:@"powerSpikes"];
            [self.stats setValue:[NSNumber numberWithInt:pointsFor+yourScore] forKey:@"pointsFor"];
            [self.stats setValue:[NSNumber numberWithInt:pointsAgainst+botScore] forKey:@"pointsAgainst"];
            [self.stats setValue:[NSNumber numberWithInt:servesErrors] forKey:@"servesErrors"];
            [self.stats setValue:[NSNumber numberWithInt:servesAttempts] forKey:@"servesAttempts"];
            [self.stats setValue:[NSNumber numberWithInt:servesAces] forKey:@"servesAces"];
        }
        else{
            // Create a new managed object
            NSManagedObject *newStats = [NSEntityDescription insertNewObjectForEntityForName:@"Stats" inManagedObjectContext:context];
            [newStats setValue:[NSNumber numberWithInt:1] forKey:@"gamesPlayed"];
            [newStats setValue:[NSNumber numberWithInt:1] forKey:@"gamesWon"];
            [newStats setValue:[NSNumber numberWithInt:hitsAttempts] forKey:@"hitsAttempts"];
            [newStats setValue:[NSNumber numberWithInt:hitsKills] forKey:@"hitsKills"];
            [newStats setValue:[NSNumber numberWithInt:hitsErrors] forKey:@"hitsErrors"];
            [newStats setValue:[NSNumber numberWithInt:digsMade] forKey:@"digsMade"];
            [newStats setValue:[NSNumber numberWithInt:assistsMade] forKey:@"assistsMade"];
            [newStats setValue:[NSNumber numberWithInt:powerSpikes] forKey:@"powerSpikes"];
            [newStats setValue:[NSNumber numberWithInt:yourScore] forKey:@"pointsFor"];
            [newStats setValue:[NSNumber numberWithInt:botScore] forKey:@"pointsAgainst"];
            [newStats setValue:[NSNumber numberWithInt:servesErrors] forKey:@"servesErrors"];
            [newStats setValue:[NSNumber numberWithInt:servesAttempts] forKey:@"servesAttempts"];
            [newStats setValue:[NSNumber numberWithInt:servesAces] forKey:@"servesAces"];
        }
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"jPreServe" forKey:@"stateOfPlay"];
        
        [self resetStats];
    }
    if (botScore>=15 && botScore >= yourScore+2){
        //Move to scene of results like with stats and stuff. Likely separate view controllers.
        //For now, show a UIalert and restart on OK.
        UIAlertView * GameOver = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"You lost... give it another try!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        [GameOver show];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (self.stats){
            [self.stats setValue:[NSNumber numberWithInt:gamesPlayed+1] forKey:@"gamesPlayed"];
            [self.stats setValue:[NSNumber numberWithInt:gamesWon] forKey:@"gamesWon"];
            [self.stats setValue:[NSNumber numberWithInt:hitsAttempts] forKey:@"hitsAttempts"];
            [self.stats setValue:[NSNumber numberWithInt:hitsKills] forKey:@"hitsKills"];
            [self.stats setValue:[NSNumber numberWithInt:hitsErrors] forKey:@"hitsErrors"];
            [self.stats setValue:[NSNumber numberWithInt:digsMade] forKey:@"digsMade"];
            [self.stats setValue:[NSNumber numberWithInt:assistsMade] forKey:@"assistsMade"];
            [self.stats setValue:[NSNumber numberWithInt:powerSpikes] forKey:@"powerSpikes"];
            [self.stats setValue:[NSNumber numberWithInt:pointsFor+yourScore] forKey:@"pointsFor"];
            [self.stats setValue:[NSNumber numberWithInt:pointsAgainst+botScore] forKey:@"pointsAgainst"];
            [self.stats setValue:[NSNumber numberWithInt:servesErrors] forKey:@"servesErrors"];
            [self.stats setValue:[NSNumber numberWithInt:servesAttempts] forKey:@"servesAttempts"];
            [self.stats setValue:[NSNumber numberWithInt:servesAces] forKey:@"servesAces"];
        }
        else{
            // Create a new managed object
            
            NSManagedObject *newStats = [NSEntityDescription insertNewObjectForEntityForName:@"Stats" inManagedObjectContext:context];
            [newStats setValue:[NSNumber numberWithInt:1] forKey:@"gamesPlayed"];
            [newStats setValue:[NSNumber numberWithInt:0] forKey:@"gamesWon"];
            [newStats setValue:[NSNumber numberWithInt:hitsAttempts] forKey:@"hitsAttempts"];
            [newStats setValue:[NSNumber numberWithInt:hitsKills] forKey:@"hitsKills"];
            [newStats setValue:[NSNumber numberWithInt:hitsErrors] forKey:@"hitsErrors"];
            [newStats setValue:[NSNumber numberWithInt:digsMade] forKey:@"digsMade"];
            [newStats setValue:[NSNumber numberWithInt:assistsMade] forKey:@"assistsMade"];
            [newStats setValue:[NSNumber numberWithInt:powerSpikes] forKey:@"powerSpikes"];
            [newStats setValue:[NSNumber numberWithInt:yourScore] forKey:@"pointsFor"];
            [newStats setValue:[NSNumber numberWithInt:botScore] forKey:@"pointsAgainst"];
            [newStats setValue:[NSNumber numberWithInt:servesErrors] forKey:@"servesErrors"];
            [newStats setValue:[NSNumber numberWithInt:servesAttempts] forKey:@"servesAttempts"];
            [newStats setValue:[NSNumber numberWithInt:servesAces] forKey:@"servesAces"];
        }
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"jPreServe" forKey:@"stateOfPlay"];
        
        [self resetStats];
    }

    [self resetPositions];
}

//helper function because selector won't send the right object.
- (void) scoreForLowPlayer{
    [self resetAndScoreBallForPlayer:kLowPlayer];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSString * stateOfPlay =[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"];

    if ([stateOfPlay isEqualToString:@"jTossed"]) return YES;
    if ([stateOfPlay isEqualToString:@"jHitting"] && iamhitter) return YES;
    else return NO;
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint fingerLocation = [self convertTouchToNodeSpace: touch];
    CGPoint myv = ccp(fingerLocation.x-ball.position.x, fingerLocation.y-ball.position.y);
    

    if (iamhitter && ball.position.y > netTop && paddle.position.x < paddle.start.x +30 && paddle.position.x > paddle.start.x
        -30){
        
        if (CGRectContainsPoint(CGRectMake(paddle.position.x-20, paddle.position.y, paddle.boundingBox.size.width+20, paddle.boundingBox.size.height+50), ball.position)){
            ball.velocity=fingerLocation;
            ball.end = fingerLocation;
        
            [ball stopActionByTag:4];
            [ball hittingAnimation];
            [self removeChildByTag:100];
            ball.zOrder=2;
        
            //make the endBall
            Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
            endBall.position = ball.end;
            endBall.scale =.4+(320-endBall.position.y)/320;
            endBall.color = ccRED;
            endBall.opacity=100;
            [self addChild:endBall z:0 tag:100];
            
            hitsAttempts=hitsAttempts+1;
        
            //Tell operator the ball is on their side
            [[NSUserDefaults standardUserDefaults] setObject:@"kOtherSide" forKey:@"whichSide"];
            
        
            [[NSUserDefaults standardUserDefaults] setObject:@"jHit" forKey:@"stateOfPlay"];
        }

    }
    CGRect serveBox = CGRectOffset(paddle.boundingBox, 0, 25);
    
    if (!iamhitter && CGRectContainsPoint(serveBox, ball.position)) {
        ball.start=ball.position;
        ball.end=fingerLocation;
        [self serveWithVelocity:myv];
        servesAttempts=servesAttempts+1;
    }
}
- (void)serveWithVelocity:(CGPoint )serveVelocity{
    ball.velocity=serveVelocity;
    [ball stopActionByTag:1];
    [ball serveAnimation];
    
    //make the endBall
    Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
	endBall.position = ball.end;
    endBall.scale =.4+(320-endBall.position.y)/320;
    endBall.color = ccRED;
    endBall.opacity=100;
    [self addChild:endBall z:0 tag:100];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"kInAir" forKey:@"stateOfPlay"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self schedule:@selector(doStep:)];
    //[OtherBotL moveToPosition: ball.end];
}
- (void)hitWithPower{
    if (iamhitter && ball.position.y > netTop && paddle.position.x < paddle.start.x +30 && paddle.position.x > paddle.start.x-30){
        ball.velocity=powerMeter.end;
        ball.end = powerMeter.end;
        
        CCParticleSystem * emitter = [CCParticleSun node];
        emitter.positionType=kCCPositionTypeFree;
        emitter.position=CGPointMake(ball.boundingBox.size.width/2, ball.boundingBox.size.height/2);
        emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
        [ball addChild:emitter z:-1 tag:924];
        [ball stopActionByTag:4];
        [ball hittingAnimationPower];

        //remove the old redball
        [self removeChildByTag:100];
        
        //make the endBall
        Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
        endBall.position = ball.end;
        endBall.scale =.4+(320-endBall.position.y)/320;
        endBall.color = ccRED;
        endBall.opacity=100;
        [self addChild:endBall z:0 tag:100];
        
        powerCount=0;
        [powerMeter removeChildByTag:925];
        powerMeter.opacity=0;
        powerMeter.isLive=NO;
        powerSpikes=powerSpikes+1;
        
        //Tell operator the ball is on their side
        [[NSUserDefaults standardUserDefaults] setObject:@"kOtherSide" forKey:@"whichSide"];
        ball.zOrder=2;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"jHitPower" forKey:@"stateOfPlay"];
    }
}

-(void) restartSteps{
    NSString * stateOfPlay =[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"];
    if ([stateOfPlay isEqualToString:@"jMissedServe"]) {
        if (PBotServes || paddleServes){
            [[NSUserDefaults standardUserDefaults] setObject:@"jPreServe" forKey:@"stateOfPlay"];
        }
    }
    [self schedule:@selector(doStep:)];
}

-(BOOL) oppositeSigns:(float)pointA and:(float)pointB{
    if (pointA<0 && pointB>0){
        return YES;
    }
    if (pointA>0 && pointB<0){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)doStep:(ccTime)delta
{
    //CGSize s = [[CCDirector sharedDirector] winSize];
    NSString * stateOfPlay =[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"];
    NSString * whichSide = [[NSUserDefaults standardUserDefaults] objectForKey:@"whichSide"];
    
    BOOL isDead = NO;
    
    whereBallIs = ball.position;
    
    bezierDetector * check = [[bezierDetector alloc]init];

        if ([stateOfPlay isEqualToString:@"kPreServe"]){
            if (LBotServes){
                CGPoint f = ccp(OtherBotL.position.x+5,OtherBotL.position.y);
                ball.position=f;
                ball.zOrder=2;
                ball.scale =.4+(320-ball.position.y)/320;
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_preserve.png"];
                OtherBotL.texture = paddleTexture2;
                [OtherBotL moveInDirection:CGPointMake(0,17) time:delta];
                theBot=OtherBotL;
                if (theBot.position.y-theBot.boundingBox.size.height/2 > 260){
                    [[NSUserDefaults standardUserDefaults] setObject:@"kTossing" forKey:@"stateOfPlay"];
                }
            }
            if (RBotServes){
                CGPoint f = ccp(OtherBotR.position.x+5,OtherBotR.position.y);
                ball.position=f;
                ball.zOrder=2;
                ball.scale =.4+(320-ball.position.y)/320;
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_preserve.png"];
                OtherBotR.texture = paddleTexture2;
                [OtherBotR moveInDirection:CGPointMake(0,17) time:delta];
                theBot=OtherBotR;
                if (theBot.position.y-theBot.boundingBox.size.height/2 > 260){
                    [[NSUserDefaults standardUserDefaults] setObject:@"kTossing" forKey:@"stateOfPlay"];
                }

            }
            lowServed = NO;

        }

        if ([stateOfPlay isEqualToString:@"jPreServe"]){
            
            if (yourScore == 0 && botScore ==0){
                //"nextServer" means they should be holding the ball.
                RBotServes=NO;
                LBotServes=YES;
                PBotServes=NO;
                paddleServes=YES;
            }
            if (PBotServes){
                CGPoint f = ccp(PartnerBot.position.x+15,PartnerBot.position.y+5);
                ball.position=f;
                ball.scale =.4+(320-ball.position.y)/320;
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_preserve.png"];
                PartnerBot.texture = paddleTexture2;
                [PartnerBot movePartnerInDirection:CGPointMake(0,-20) time:delta];
                theBot=PartnerBot;
                if (theBot.position.y-theBot.boundingBox.size.height/2 < 18){
                    [[NSUserDefaults standardUserDefaults] setObject:@"jBotTossing" forKey:@"stateOfPlay"];
                }
            }
            if (paddleServes){
                CGPoint f = ccp(paddle.position.x+15,paddle.position.y+5);
                ball.position=f;
                ball.scale =.4+(320-ball.position.y)/320;
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_preserve.png"];
                paddle.texture = paddleTexture2;
                iamserver=YES;
            }
            lowServed=YES;
        }
    
    if ([stateOfPlay isEqualToString:@"jBotTossing"]){
        [ball tossByPartnerBot];

    }
    if ([stateOfPlay isEqualToString:@"kTossing"]){
        [ball tossByBot];
    }
        if ([stateOfPlay isEqualToString:@"kBotTossed"]){
            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_serve.png"];
            theBot.texture = paddleTexture2;
            
        //how partner bot serves
            if (theBot==PartnerBot){
                if (whereBallIs.y<whereBallWas.y){
                    
                    //detect when the hit is and make the moves.
                    if (CGRectContainsPoint(theBot.boundingBox, ball.position)){
                        
                        float x = 93 * screenScale + CCRANDOM_0_1() * 369 * screenScale;
                        float y = 210 + CCRANDOM_0_1() * 60;
                        
                        CGPoint myv = ccp(x-ball.position.x,y-ball.position.y);
                        ball.end=ccp(x,y);
                        ball.velocity=myv;
                        [ball serveAnimation];
                        [ball stopActionByTag:12];
                        ball.zOrder=4;
                        
                        //make the endBall
                        Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
                        endBall.position = ball.end;
                        endBall.scale =.4+(320-endBall.position.y)/320;
                        endBall.color = ccRED;
                        endBall.opacity=100;
                        [self addChild:endBall z:0 tag:100];
                    
                        CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                        theBot.texture = paddleTexture2;
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"kInAir" forKey:@"stateOfPlay"];
                    }
                }
            }
            //how opponents serve
            else{
                if (whereBallIs.y<whereBallWas.y){
                
                    //serve for the other bots
                    if (CGRectContainsPoint(theBot.boundingBox, ball.position)){
                    
                        float x = 22 * screenScale + CCRANDOM_0_1() * 524 * screenScale;
                        float y = CCRANDOM_0_1() * 160;
                    
                        CGPoint myv = ccp(x-ball.position.x,y-ball.position.y);
                        ball.start=ball.position;
                        ball.end=ccp(x,y);
                        ball.velocity=myv;
                        
                        [ball serveBotAnimation];
                        [ball stopActionByTag:11];
                        ball.zOrder=4;
                    
                        //make the endBall
                        Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
                        endBall.position = ball.end;
                        endBall.scale =.4+(320-endBall.position.y)/320;
                        endBall.color = ccRED;
                        endBall.opacity=100;
                        [self addChild:endBall z:0 tag:100];
                    
                        CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                        theBot.texture = paddleTexture2;
                    
                        [[NSUserDefaults standardUserDefaults] setObject:@"kHit" forKey:@"stateOfPlay"];
                        stillCount=0;
                        [[NSUserDefaults standardUserDefaults] setObject:@"kMySide" forKey:@"whichSide"];

                    }
                }
            }

        }

        if ([stateOfPlay isEqualToString:@"jTossing"]){
            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_serve.png"];
            paddle.texture = paddleTexture2;
            [ball toss];
            [self unschedule:@selector(doStep:)];
            [self performSelector:@selector(restartSteps) withObject:self afterDelay:2.05];
            [[NSUserDefaults standardUserDefaults] setObject:@"jTossed" forKey:@"stateOfPlay"];
        }
    
        if ([stateOfPlay isEqualToString:@"kInAir"]){
            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
            paddle.texture = paddleTexture2;
            if (ball.position.y >netTop ){
                [[NSUserDefaults standardUserDefaults] setObject:@"kOtherSide" forKey:@"whichSide"];
                [[NSUserDefaults standardUserDefaults] setObject:@"kCrossedNet" forKey:@"stateOfPlay"];
            }
            if (ball.position.y <=netTop){
                [[NSUserDefaults standardUserDefaults] setObject:@"kMySideOnNet" forKey:@"whichSide"];
            }
            //controlling the bots --->

                //find the distance to the ball.end for both players
                //the one with shortest difference moves toward ball.end ... with a max velocity of [something reasonable]
                float rDistance = ccpDistance(OtherBotR.position, ball.end);
                float lDistance = ccpDistance(OtherBotL.position, ball.end);
                
                if (rDistance > lDistance){
                    theBot = OtherBotL;
                    otherBot = OtherBotR;
                    
                }
                if (lDistance > rDistance){
                    theBot = OtherBotR;
                    otherBot = OtherBotL;
                }
            CGPoint myv = ccp(ball.end.x-theBot.start.x, ball.end.y-theBot.start.y);
            CGPoint oneUnit = ccpNormalize(myv);
            
            //if these here points are opposite of myv then stop the motion.
            if ([self oppositeSigns:ball.end.x-theBot.position.x and:ball.end.x-theBot.start.x] && [self oppositeSigns:ball.end.y-theBot.position.y and:ball.end.y-theBot.start.y]){
                oneUnit = ccp(0,0);
            }
            if ([check pointIsInHighCourt:ball.end]){
                [theBot moveInDirection:oneUnit time:80*(.4+(320-theBot.position.y)/320)*delta];
            }


        }
        if ([stateOfPlay isEqualToString:@"kCrossedNet"]){
            //continue moving the guy and find out if he got to the ball
            ball.zOrder=2;

            CGPoint myv = ccp(ball.end.x-theBot.start.x, ball.end.y-theBot.start.y);
            CGPoint oneUnit = ccpNormalize(myv);
            
            //if these here points are opposite of myv then stop the motion.
            if ([self oppositeSigns:ball.end.x-theBot.position.x and:ball.end.x-theBot.start.x] && [self oppositeSigns:ball.end.y-theBot.position.y and:ball.end.y-theBot.start.y]){
               oneUnit = ccp(0,0);
            }
            if ([check pointIsInHighCourt:ball.end]){
                [theBot moveInDirection:oneUnit time:85*(.4+(320-theBot.position.y)/320)*delta];
            }
            if (![check pointIsInHighCourt:ball.end]){
                ball.zOrder=0;
            }
            
            CGRect platformBox = CGRectOffset(theBot.boundingBox, 0, -10);
            
            if (CGRectContainsPoint(platformBox, ball.position) && ball.scale <=(.42+(320-ball.end.y)/320)){
                [[NSUserDefaults standardUserDefaults] setObject:@"kPassing" forKey:@"stateOfPlay"];
                iamserver= NO;


            }
        }
        if ([stateOfPlay isEqualToString:@"kPassing"]){
            //call an animation from the ball.
            aBallPoint = ball.position;
            aPlayerPoint = theBot.position;
            
            [PartnerBot moveToPosition:PartnerBot.start];

            
            CGPoint passToPoint = ccp(278*screenScale,202);
            
            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_passing.png"];
            theBot.texture = paddleTexture2;
            
            
            CGPoint myv = ccp(passToPoint.x-aBallPoint.x, passToPoint.y-aBallPoint.y);
            ball.velocity=myv;
            ball.end = passToPoint;
            [ball passAnimation];
            [ball stopActionByTag:33];
            [ball stopActionByTag:44];
            [self removeChildByTag:100];
            
            //make the endBall
            Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
            endBall.position = ball.end;
            endBall.scale =.4+(320-endBall.position.y)/320;
            endBall.color = ccRED;
            endBall.opacity=100;
            [self addChild:endBall z:0 tag:100];
            
            //changed the state to kPassed.
            [[NSUserDefaults standardUserDefaults] setObject:@"kPassed" forKey:@"stateOfPlay"];

        }
        if ([stateOfPlay isEqualToString:@"kPassed"]){
            //move player to set the ball.
            
            CGPoint myvForPasser = ccp(theBot.start.x-aPlayerPoint.x, theBot.start.y-aPlayerPoint.y);
            CGPoint oneUnitForPasser = ccpNormalize(myvForPasser);
            if ([self oppositeSigns:theBot.start.x-theBot.position.x and:theBot.start.x-aPlayerPoint.x]){
                oneUnitForPasser = ccp(0,0);
            }
            [theBot moveInDirection:oneUnitForPasser time:90*(.4+(320-theBot.position.y)/320)*delta];
            
            CGPoint myv = ccp(278*screenScale-otherBot.start.x, 210-otherBot.start.y);
            CGPoint oneUnit = ccpNormalize(myv);
            if ([self oppositeSigns:ball.end.x-otherBot.position.x and:ball.end.x-otherBot.start.x]){
                oneUnit = ccp(0,0);
            }
            
            [otherBot moveInDirection:oneUnit time:80*(.4+(320-otherBot.position.y)/320)*delta];
            
            //Change the state to kSetting if the other bot position contains the ball
            if (CGRectContainsPoint(otherBot.boundingBox, ball.position)){
                [[NSUserDefaults standardUserDefaults] setObject:@"kSetting" forKey:@"stateOfPlay"];
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                theBot.texture = paddleTexture2;
                aPlayerPoint=theBot.position;
                

            }
        }
        if ([stateOfPlay isEqualToString:@"kSetting"]){
            
            aBallPoint = ball.position;
            //change bot avatar to hands up
            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_setting.png"];
            otherBot.texture = paddleTexture2;
            
            //start the setting animation on the ball
            CGPoint setToPoint = ccp(theBot.start.x, 251.5);
            [PartnerBot moveToPosition:PartnerBot.start];

            CGPoint myv = ccp(setToPoint.x-aBallPoint.x, setToPoint.y-aBallPoint.y);
            ball.velocity=myv;
            ball.end = setToPoint;
            [ball settingAnimation];
            [ball stopActionByTag:2];
            [self removeChildByTag:100];
            
            //make the endBall
            Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
            endBall.position = ball.end;
            endBall.scale =.4+(320-endBall.position.y)/320;
            endBall.color = ccRED;
            endBall.opacity=100;
            [self addChild:endBall z:ball.zOrder tag:100];
            
            //change the state to kSet
            [[NSUserDefaults standardUserDefaults] setObject:@"kSet" forKey:@"stateOfPlay"];
            [[NSUserDefaults standardUserDefaults] setObject:@"kOtherSideOnNet" forKey:@"whichSide"];
        }
        if ([stateOfPlay isEqualToString:@"kSet"]){
            //move thebot into attacking position
            CGPoint myv = ccp(theBot.start.x-aPlayerPoint.x, 208-aPlayerPoint.y);
            CGPoint oneUnit = ccpNormalize(myv);
            if ([self oppositeSigns:ball.end.x-theBot.position.x and:ball.end.x-aPlayerPoint.x]){
                oneUnit = ccp(0,0);
            }
            [theBot moveInDirection:oneUnit time:80*(.4+(320-theBot.position.y)/320)*delta];
            
            
            //when player reaches myv... change to kJumping and trigger the jump
            if (theBot.position.x <= theBot.start.x+5 && theBot.position.x >= theBot.start.x-5 && theBot.position.y <= 208+5 && theBot.position.y >= 208-5){
                [theBot performSelector:@selector(jumpAction) withObject:theBot afterDelay:10*delta];
                
                //change avatar to serve img.
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_serve.png"];
                theBot.texture = paddleTexture2;
                [[NSUserDefaults standardUserDefaults] setObject:@"kJumping" forKey:@"stateOfPlay"];
                
            }
            
        }
        if ([stateOfPlay isEqualToString:@"kJumping"]){
            //when ball is in hit box range of avatar switch to state of hitting (like platformbox but higher on the avatar)
            //CGRect swingbox = CGRectMake(theBot.position.x-20, theBot.position.y+20, 40, 20);
            if (CGRectContainsPoint(theBot.boundingBox, ball.position) && ball.position.y > netTop){
                [[NSUserDefaults standardUserDefaults] setObject:@"kHitting" forKey:@"stateOfPlay"];
                [ball stopActionByTag:4];
                
            }
        }
        if ([stateOfPlay isEqualToString:@"kHitting"]){
            //switch image to greenman.png
            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
            theBot.texture = paddleTexture2;
            CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
            otherBot.texture = paddleTexture;
            
            //send the ball on it's hitting path. create a randomizer to determine the trajectory.
            float x = 20 * screenScale + CCRANDOM_0_1() * 528 * screenScale;
            float y = CCRANDOM_0_1() * 170;
            
            CGPoint myv = ccp(x,y);
            ball.velocity=myv;
            ball.end = myv;
            [ball hittingAnimation];
            [self removeChildByTag:100];
            
            //make the endBall
            Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
            endBall.position = ball.end;
            endBall.scale =.4+(320-endBall.position.y)/320;
            endBall.color = ccRED;
            endBall.opacity=100;
            [self addChild:endBall z:0 tag:100];
            
            //Tell operator the ball is on myside
            [[NSUserDefaults standardUserDefaults] setObject:@"kMySide" forKey:@"whichSide"];
            ball.zOrder=4;
            
            [[NSUserDefaults standardUserDefaults] setObject:@"kHit" forKey:@"stateOfPlay"];
        }
        if ([stateOfPlay isEqualToString:@"kHit"]){
            float partnerDistance = ccpDistance(PartnerBot.position, ball.end);
            float myDistance = ccpDistance(paddle.start, ball.end);
            
            theBot=nil;
            otherBot=nil;
            
            //if (partnerDistance > myDistance){
            CGRect passingBox=CGRectOffset(paddle.boundingBox, 0, -15);
            
                //I'm passing.
                if (CGRectContainsPoint(passingBox, ball.position)){
                    //change the texture of passing bot
                    [ball stopActionByTag:44];
                    [ball stopActionByTag:32];
                    CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_passing.png"];
                    paddle.texture = paddleTexture2;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"jPassing" forKey:@"stateOfPlay"];
                    iamhitter =YES;
                    paddle.iamhitter = YES;
                    [self removeChildByTag:100];
                    digsMade=digsMade+1;
                }
            
                
            //}
            if (myDistance > partnerDistance){
                //PartnerBot should pass the ball
                CGPoint myv = ccp(ball.end.x-PartnerBot.start.x, ball.end.y-PartnerBot.start.y);
                CGPoint oneUnit = ccpNormalize(myv);
                
                //stop the bot if he goes too far
                if ([self oppositeSigns:ball.end.x-PartnerBot.position.x and:ball.end.x-PartnerBot.start.x] && [self oppositeSigns:ball.end.y-PartnerBot.position.y and:ball.end.y-PartnerBot.start.y]){
                    oneUnit = ccp(0,0);
                }
                if ([check pointIsInLowCourt:ball.end]){
                    [PartnerBot movePartnerInDirection:oneUnit time:100*delta];
                }
                
                CGRect platformBox = CGRectOffset(PartnerBot.boundingBox, 0, -15);
                
                if (CGRectContainsPoint(platformBox, ball.position) && [check pointIsInLowCourt:ball.end]){
                    
                    //change the texture of passing bot
                    CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_passing.png"];
                    PartnerBot.texture = paddleTexture2;
                    [ball stopActionByTag:44];
                    [ball stopActionByTag:32];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"jPassing" forKey:@"stateOfPlay"];
                    iamhitter=NO;
                    paddle.iamhitter = NO;
                    [self removeChildByTag:100];
                    
                }
            }
        }
        if ([stateOfPlay isEqualToString:@"jPassing"]){
            //call an animation from the ball.
            CGPoint passToPoint = ccp(278*screenScale,180);
            aPlayerPoint = PartnerBot.position;
            aBallPoint = ball.position;

            CGPoint myv = ccp(passToPoint.x-aBallPoint.x, passToPoint.y-aBallPoint.y);
            ball.velocity=myv;
            ball.end = passToPoint;
            [ball passAnimationLow];
            [self removeChildByTag:100];
            
            //make the endBall
            Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
            endBall.position = ball.end;
            endBall.scale =.4+(320-endBall.position.y)/320;
            endBall.color = ccRED;
            endBall.opacity=100;
            [self addChild:endBall z:0 tag:100];
            
            //move the other players to starting positions.
            [OtherBotL stopAllActions];
            [OtherBotR stopAllActions];
            [OtherBotL moveToPosition:OtherBotL.start];
            [OtherBotR moveToPosition:OtherBotR.start];
            
            //changed the state to jPassed.
            [[NSUserDefaults standardUserDefaults] setObject:@"jPassed" forKey:@"stateOfPlay"];
            [[NSUserDefaults standardUserDefaults] setObject:@"kMySideOnNet" forKey:@"whichSide"];


        }
        if ([stateOfPlay isEqualToString:@"jPassed"]){
            //move the other player to the setting spot if necessary.
            if (!iamhitter){
                
                CGPoint myvForPasser = ccp(PartnerBot.start.x-aPlayerPoint.x, PartnerBot.start.y-aPlayerPoint.y);
                CGPoint oneUnitForPasser = ccpNormalize(myvForPasser);
                if ([self oppositeSigns:PartnerBot.start.x-PartnerBot.position.x and:PartnerBot.start.x-aPlayerPoint.x]){
                    oneUnitForPasser = ccp(0,0);
                }
                [PartnerBot movePartnerInDirection:oneUnitForPasser time:85*delta];
                
                if (CGRectContainsPoint(paddle.boundingBox, ball.position)){
                    [[NSUserDefaults standardUserDefaults] setObject:@"jSetting" forKey:@"stateOfPlay"];
                }
            }
            else {
                
                
                //move player to set the ball.
                CGPoint myv = ccp(278*screenScale-PartnerBot.start.x, 180-PartnerBot.start.y);
                CGPoint oneUnit = ccpNormalize(myv);
                if ([self oppositeSigns:ball.end.x-PartnerBot.position.x and:ball.end.x-PartnerBot.start.x]){
                   oneUnit = ccp(0,0);
                }
                [PartnerBot movePartnerInDirection:oneUnit time:100*delta];
                
                //Change the state to kSetting if the bot position contains the ball
                
                if (CGRectContainsPoint(PartnerBot.boundingBox, ball.position)){
                    [[NSUserDefaults standardUserDefaults] setObject:@"jSetting" forKey:@"stateOfPlay"];
                    
                }

            }
            //change to jSetting if the ball is in the setting platform of the setting player
            
        }
        if ([stateOfPlay isEqualToString:@"jSetting"]){
            
            aBallPoint=ball.position;

            
            theBot = nil;
            otherBot = nil;

            
            if (iamhitter){
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_setting.png"];
                PartnerBot.texture = paddleTexture2;
                
                CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                paddle.texture = paddleTexture;
                
                //start the setting animation on the ball
                CGPoint setToPoint = ccp(paddle.start.x, 250);
                
                CGPoint myv = ccp(setToPoint.x-aBallPoint.x, setToPoint.y-aBallPoint.y);
                ball.velocity=myv;
                ball.end = setToPoint;
                [ball settingAnimation];
                [ball stopActionByTag:5];
                [self removeChildByTag:100];
                
                //make the endBall
                Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
                endBall.position = ball.end;
                endBall.scale =.4+(320-endBall.position.y)/320;
                endBall.color = ccRED;
                endBall.opacity=100;
                [self addChild:endBall z:ball.zOrder tag:100];
                
                //change the state to jSet
                [[NSUserDefaults standardUserDefaults] setObject:@"jSet" forKey:@"stateOfPlay"];
                
            }
            else{
                //change the image
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_setting.png"];
                paddle.texture = paddleTexture2;
            
                CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                PartnerBot.texture = paddleTexture;
                //start the setting animation on the ball
                CGPoint setToPoint = ccp(PartnerBot.start.x, 250);
            
                CGPoint myv = ccp(setToPoint.x-aBallPoint.x, setToPoint.y-aBallPoint.y);
                ball.velocity=myv;
                ball.end = setToPoint;
                [ball settingAnimation];
                [ball stopActionByTag:5];
                [self removeChildByTag:100];
                
                //make the endBall
                Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
                endBall.position = ball.end;
                endBall.scale =.4+(320-endBall.position.y)/320;
                endBall.color = ccRED;
                endBall.opacity=100;
                [self addChild:endBall z:ball.zOrder tag:100];
            
                //change the state to jSet
                [[NSUserDefaults standardUserDefaults] setObject:@"jSet" forKey:@"stateOfPlay"];
            }
            aPlayerPoint=PartnerBot.position;

        }
        if ([stateOfPlay isEqualToString:@"jSet"]){
            
            if (!iamhitter){
            
            //move thebot into attacking position
            CGPoint myv = ccp(PartnerBot.start.x-aPlayerPoint.x, 200-aPlayerPoint.y);
            CGPoint oneUnit = ccpNormalize(myv);
            [PartnerBot movePartnerInDirection:oneUnit time:100*delta];
                
            //when player reaches myv... change to kJumping and trigger the jump
            //if (PartnerBot.position.x <= PartnerBot.start.x+4 && PartnerBot.position.x >= PartnerBot.start.x-4 && PartnerBot.position.y <= 225+4 && PartnerBot.position.y >= 225-4){
                if (whereBallIs.y< whereBallWas.y){
                    //do the jumping
                    [PartnerBot jumpAction];
                    //[PartnerBot performSelector:@selector(jumpAction) withObject:PartnerBot afterDelay:20*delta];
                
                    //change avatar to serve img.
                    CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_serve.png"];
                    PartnerBot.texture = paddleTexture2;
                    CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                    paddle.texture = paddleTexture;
                
                [[NSUserDefaults standardUserDefaults] setObject:@"jJumping" forKey:@"stateOfPlay"];
            }
            }
            else{
                //the paddle controller handles it. And skips to jHitting if successful
            }
            
        }
        if ([stateOfPlay isEqualToString:@"jJumping"]){
            
            //when ball is in hit box range of avatar switch to state of hitting (like platformbox but higher on the avatar)
            if (CGRectContainsPoint(PartnerBot.boundingBox, ball.position) && ball.position.y > netTop){
                [[NSUserDefaults standardUserDefaults] setObject:@"jHitting" forKey:@"stateOfPlay"];
                [ball stopActionByTag:4];
                
            }

        }
        if ([stateOfPlay isEqualToString:@"jHitting"]){
            
            if (!iamhitter){
                //switch image to greenman.png
                CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                PartnerBot.texture = paddleTexture2;
            
                //send the ball on it's hitting path. create a randomizer to determine the trajectory.
                float x = 87*screenScale + CCRANDOM_0_1() * 388 * screenScale;
                float y = 181 + CCRANDOM_0_1() * 94;
            
                CGPoint myv = ccp(x,y);
                //CGPoint myv = ccp(200,300);
                ball.velocity=myv;
                ball.end = myv;
                [ball hittingAnimation];
                [self removeChildByTag:100];
                
                //make the endBall
                Ball * endBall = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ball.png"]];
                endBall.position = ball.end;
                endBall.scale =.4+(320-endBall.position.y)/320;
                endBall.color = ccRED;
                endBall.opacity=100;
                [self addChild:endBall z:0 tag:100];
            
                //Tell operator the ball is on theirside
                [[NSUserDefaults standardUserDefaults] setObject:@"kOtherSide" forKey:@"whichSide"];
                ball.zOrder=2;
            
                [[NSUserDefaults standardUserDefaults] setObject:@"jHit" forKey:@"stateOfPlay"];
            }
            //what the paddle does while hitting.
            else{
                CCTexture2D *paddleTexture = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
                PartnerBot.texture = paddleTexture;
                //listen for the touch to know where to hit.
                //If you want to use the power up. whereever the power is released is where the ball should be hit...
                //In the case that the meter is grabbed, the responsibility to signal the ball velocity and end falls on the power up...
                
                
                if (powerMeter.isLive){
                    if (powerMeter.isGrabbed){
                        [[CCDirector sharedDirector].scheduler setTimeScale:0.3];
                    }
                    if (!powerMeter.isGrabbed){
                        [[CCDirector sharedDirector].scheduler setTimeScale:1];
                    }
                    if (!CGPointEqualToPoint(powerMeter.end, CGPointZero)){
                        [self hitWithPower];
                    }
                }
            }
        }
        if ([stateOfPlay isEqualToString:@"jHit"]){

            CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
            paddle.texture = paddleTexture2;
            //find the distance to the ball.end for both players
            //the one with shortest difference moves toward ball.end ... with a max velocity of [something reasonable]
            float rDistance = ccpDistance(OtherBotR.position, ball.velocity);
            float lDistance = ccpDistance(OtherBotL.position, ball.velocity);
            
            if (rDistance > lDistance){
                theBot = OtherBotL;
                otherBot = OtherBotR;
                
            }
            if (lDistance > rDistance){
                theBot = OtherBotR;
                otherBot = OtherBotL;
            }
            CGPoint myv = ccp(ball.velocity.x-theBot.start.x, ball.velocity.y-theBot.start.y);
            CGPoint oneUnit = ccpNormalize(myv);
            
            //if these here points are opposite of myv then stop the motion.
            if ([self oppositeSigns:ball.end.x-theBot.position.x and:ball.end.x-theBot.start.x] || [self oppositeSigns:ball.end.y-theBot.position.y and:ball.end.y-theBot.start.y]){
                oneUnit = ccp(0,0);
            }
            if ([check pointIsInHighCourt:ball.end]){
                [theBot moveInDirection:oneUnit time:90*(.4+(320-theBot.position.y)/320)*delta];
            }
            if (![check pointIsInHighCourt:ball.end]){
                ball.zOrder=0;
            }
            
            if (CGRectContainsPoint(theBot.boundingBox, ball.position) && ball.scale <=(.42+(320-ball.end.y)/320) && [check pointIsInHighCourt:ball.end]){
                [[NSUserDefaults standardUserDefaults] setObject:@"kPassing" forKey:@"stateOfPlay"];
                iamhitter=NO;
                
            }

        }
    if ([stateOfPlay isEqualToString:@"jHitPower"]){
        
        CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
        paddle.texture = paddleTexture2;
        
        CCTexture2D *paddleTextureL = [[CCTextureCache sharedTextureCache] addImage:@"greenman_passing.png"];
        OtherBotL.texture = paddleTextureL;
        OtherBotR.texture = paddleTextureL;
        
        //find the distance to the ball.end for both players
        //the one with shortest difference moves toward ball.end ... with a max velocity of [something reasonable]
        float rDistance = ccpDistance(OtherBotR.position, ball.velocity);
        float lDistance = ccpDistance(OtherBotL.position, ball.velocity);
        
        if (rDistance > lDistance){
            theBot = OtherBotL;
            otherBot = OtherBotR;
            
        }
        if (lDistance > rDistance){
            theBot = OtherBotR;
            otherBot = OtherBotL;
        }
        CGPoint myv = ccp(ball.velocity.x-theBot.start.x, ball.velocity.y-theBot.start.y);
        CGPoint oneUnit = ccpNormalize(myv);
        
        
        //if these here points are opposite of myv then stop the motion.
        if ([self oppositeSigns:ball.end.x-theBot.position.x and:ball.end.x-theBot.start.x] || [self oppositeSigns:ball.end.y-theBot.position.y and:ball.end.y-theBot.start.y]){
            oneUnit = ccp(0,0);
        }
        if ([check pointIsInHighCourt:ball.end]){
            [theBot moveInDirection:oneUnit time:2*delta];
        }
        [otherBot stopAllActions];

        
        if (CGRectContainsPoint(theBot.boundingBox, ball.position) && ball.scale <= (.405+(320-ball.end.y)/320) && [check pointIsInHighCourt:ball.end]){
            [[NSUserDefaults standardUserDefaults] setObject:@"kPassing" forKey:@"stateOfPlay"];
            CCTexture2D *backgroundTexture = [[CCTextureCache sharedTextureCache] addImage:@"court2.png"];
            background.texture=backgroundTexture;
            [self stopActionByTag:923];
            [ball removeChildByTag:924];
            iamhitter=NO;
            
        }

    }

        //determine if the ball is dead
        //(whereBallWas.y == whereBallIs.y && whereBallWas.x ==whereBallIs.x)
        //do this as is dead and then check all of the states.
        BOOL isStill = ((whereBallIs.x == whereBallWas.x && whereBallIs.y ==whereBallIs.y));
        if (isStill){
            stillCount = stillCount+1;
        }
        if (!isStill){
            stillCount=0;
        }
        isDead = (stillCount > 3);

        // if the ball is dead.
        if (isDead){
            
            if ([whichSide isEqualToString:@"kOtherSide"] && [check pointIsInHighCourt:ball.position]){
                //Animate the player
                id actionUp = [CCJumpTo actionWithDuration:1 position:paddle.position height:40 jumps:2];
                [paddle runAction:actionUp];
                id actionUp2 = [CCJumpTo actionWithDuration:1 position:PartnerBot.position height:40 jumps:2];
                [PartnerBot runAction:actionUp2];
                
                //reset the score after animation ends.
                [self performSelector:@selector(scoreForLowPlayer) withObject:self afterDelay:1];
                [self unschedule:@selector(doStep:)];
                
                if (iamhitter){
                    hitsKills=hitsKills+1;
                }
                if (!iamhitter && !iamserver){
                    assistsMade=assistsMade+1;
                }
                if (iamserver){
                    servesAces=servesAces+1;
                }
                
            }
            if ([whichSide isEqualToString:@"kOtherSide"] && ![check pointIsInHighCourt:ball.position]){
                //Animate the player
                id actionUp = [CCJumpTo actionWithDuration:1 position:OtherBotR.position height:40 jumps:2];
                [OtherBotR runAction:actionUp];
                id actionUp2 = [CCJumpTo actionWithDuration:1 position:OtherBotL.position height:40 jumps:2];
                [OtherBotL runAction:actionUp2];
                
                //reset the score after animation ends.
                [self performSelector:@selector(resetAndScoreBallForPlayer:) withObject:kHighPlayer afterDelay:1];
                [self unschedule:@selector(doStep:)];
                
                if (iamhitter){
                    hitsErrors=hitsErrors+1;
                }
                if (iamserver){
                    servesErrors=servesErrors+1;
                }
                
            }
            if ([whichSide isEqualToString:@"kMySideOnNet"]){
                //animate the net
                net.color=ccRED;
                id action1 = [CCBlink actionWithDuration:1 blinks:10];
                [net runAction:action1].tag=923;
                
                id actionUp = [CCJumpTo actionWithDuration:1 position:OtherBotR.position height:40 jumps:2];
                [OtherBotR runAction:actionUp];
                id actionUp2 = [CCJumpTo actionWithDuration:1 position:OtherBotL.position height:40 jumps:2];
                [OtherBotL runAction:actionUp2];
                
                //reset the score after animation ends.
                [self performSelector:@selector(resetAndScoreBallForPlayer:) withObject:kHighPlayer afterDelay:1];
                [self unschedule:@selector(doStep:)];
                
                if (iamhitter){
                    hitsErrors=hitsErrors+1;
                }
                if (iamserver){
                    servesErrors=servesErrors+1;
                }


            }
            if ([whichSide isEqualToString:@"kOtherSideOnNet"]){
                //animate the net
                net.color=ccRED;
                id action1 = [CCBlink actionWithDuration:1 blinks:10];
                [net runAction:action1];
                
                id actionUp = [CCJumpTo actionWithDuration:1 position:paddle.position height:40 jumps:2];
                [paddle runAction:actionUp];
                id actionUp2 = [CCJumpTo actionWithDuration:1 position:PartnerBot.position height:40 jumps:2];
                [PartnerBot runAction:actionUp2];
                
                //reset the score after animation ends.
                [self performSelector:@selector(scoreForLowPlayer) withObject:self afterDelay:1];
                [self unschedule:@selector(doStep:)];
            }
            if ([whichSide isEqualToString:@"kMySide"] && [check pointIsInLowCourt:ball.position]){
                //Animate the player
                id actionUp = [CCJumpTo actionWithDuration:1 position:OtherBotR.position height:40 jumps:2];
                [OtherBotR runAction:actionUp];
                id actionUp2 = [CCJumpTo actionWithDuration:1 position:OtherBotL.position height:40 jumps:2];
                [OtherBotL runAction:actionUp2];
                
                
                //reset the score after animation ends.
                [self performSelector:@selector(resetAndScoreBallForPlayer:) withObject:kHighPlayer afterDelay:1];
                [self unschedule:@selector(doStep:)];
                


            }
            if ([whichSide isEqualToString:@"kMySide"] && ![check pointIsInLowCourt:ball.position] && ![stateOfPlay isEqualToString:@"kInAir"]){
                //Animate the player
                id actionUp = [CCJumpTo actionWithDuration:1 position:paddle.position height:40 jumps:2];
                [paddle runAction:actionUp];
                id actionUp2 = [CCJumpTo actionWithDuration:1 position:PartnerBot.position height:40 jumps:2];
                [PartnerBot runAction:actionUp2];
                
                //reset the score after animation ends.
                [self performSelector:@selector(scoreForLowPlayer) withObject:self afterDelay:1];
                [self unschedule:@selector(doStep:)];

            }
        }
        
        else {
            //I don't know what else there could be.
        }
    
//Last thing before the step ends.
    whereBallWas=ball.position;

}


- (void)dealloc
{
	[ball release];
	[paddle release];
    [OtherBotR release];
    [OtherBotL release];
    [PartnerBot release];
	[super dealloc];
}

@end

#pragma Main Menu Layer

@implementation MenuLayer

- (id)init
{
	if ((self = [super init]) ){
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Good Volleyball" fontName:@"Helvetica" fontSize:32];
        label.color=ccGREEN;
        [self addChild:label z:100];
        [label setPosition: ccp(s.width/2, s.height-50)];
        
        CCSprite *background;
        background = [CCSprite spriteWithFile:@"court2.png"];
        background.position = ccp(s.width/2, s.height/2);
        screenScale = s.width/background.boundingBox.size.width;
        background.scaleX = screenScale;
        //background.rotationX=45;
        [self addChild: background];
        
        CCSprite *net = [CCSprite spriteWithFile:@"net.png"];
        net.position = ccp(s.width/2.05, s.height/1.51);
        net.scaleX = .7*background.scaleX;
        net.scaleY = .22;
        [self addChild:net];
        
        Ball *ball = [Ball ballWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"vball.png"]];
        ball.position = CGPointMake(s.width/3*2.2, 100);
        ball.start=CGPointMake(s.width/3*2.2, 100);
        ball.end = CGPointMake(s.width/3*2, 200);
        ball.velocity = ccp(ball.end.x-ball.start.x, ball.end.y-ball.start.y);
        [self addChild:ball z:2];
        [ball bounceAround]; //bounces the ball around the screen.
        
        //other side on right
        CCSprite * OtherBotR =[CCSprite spriteWithFile:@"greenman_passing.png"];
        OtherBotR.color = ccBLUE;
        OtherBotR.position = CGPointMake(s.width/3*2, 200);
        float scaleG=.4+(320-OtherBotR.position.y)/320;
        OtherBotR.scale=scaleG;
        [self addChild:OtherBotR z:1];
        
        //partner bot
        CCSprite *PartnerBot = [CCSprite spriteWithFile:@"greenman_passing.png"];
        PartnerBot.color = ccGREEN;
        PartnerBot.position = CGPointMake(s.width/3*2.2, 100);
        float scaleH=.4+(320-PartnerBot.position.y)/320;
        PartnerBot.scale=scaleH;
        [self addChild:PartnerBot z:3];
    
        CCMenu *menu;
        // Default font size will be 22 points.
        [CCMenuItemFont setFontSize:22];
    	
        // New Game Button
        CCMenuItemLabel *newGame = [CCMenuItemFont itemWithString:@"New Game" block:^(id sender){
            CCScene *scene = [CCScene node];
            [scene addChild:[PongLayer node]];
            [[CCDirector sharedDirector] replaceScene:scene];
        
        }];
        CCMenuItemLabel *stats = [CCMenuItemFont itemWithString:@"Stats" block:^(id sender){

            StatsViewController * stats = [[StatsViewController alloc]init];
            AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
            [app.navController pushViewController:stats animated:YES];

            //show stats like games played, total wins w/ winning percentage, hits and hitting percentage, kills and kills/ game, digs and per game average, assists and per game average,

        }];
        /*CCMenuItemLabel *leaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender){
            //present the game center.
            
        }];*/
        CCMenuItemLabel *instructions = [CCMenuItemFont itemWithString:@"Instructions" block:^(id sender){
            //present a modal view with text instructions
            InstructionsViewController * structs = [[InstructionsViewController alloc]init];
            AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
            [app.navController pushViewController:structs animated:YES];
            
        }];
	
    
        menu = [CCMenu menuWithItems:newGame, stats, instructions, nil];
        [menu setColor:ccBLACK];
        [menu alignItemsVertically];
        [menu setPosition:ccp(s.width/2, s.height/2)];
        menu.tag = 401;
	
        [self addChild: menu];
        
    }

	return self;
}
- (void) dealloc
{
	[super dealloc];
}


@end

