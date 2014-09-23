
#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "bezierDetector.h"
#import "Bots.h"
#import "Paddle.h"
#import "PowerUp.h"
#import "StatsViewController.h"
#import "InstructionsViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface PongScene : CCScene {
@private
}
@end

@class Ball;


@interface PongLayer: CCLayer <CCTouchOneByOneDelegate>{
@private
	Ball *ball;
    Bots *OtherBotL;
    Bots *OtherBotR;
    Bots *PartnerBot;
	Paddle *paddle;
	CGPoint ballStartingVelocity;
    CCSprite *net;
    int yourScore;
    int botScore;
    PowerUp * powerMeter;
    
    int hitsAttempts;
    int hitsKills;
    int hitsErrors;
    int digsMade;
    int assistsMade;
    int powerSpikes;
    int gamesPlayed;
    int gamesWon;
    int pointsFor;
    int pointsAgainst;
    int servesAttempts;
    int servesErrors;
    int servesAces;
}
- (void)doStep:(ccTime)delta;
@property (strong) NSManagedObject * stats;


@end
@interface MenuLayer : CCLayer {
    
}

@end
