
#import "cocos2d.h"

@class Paddle;

@interface Ball : CCSprite {
@private
	CGPoint velocity;
}

@property(nonatomic) CGPoint velocity;
@property(nonatomic, readonly) float radius;
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;

+ (id)ballWithTexture:(CCTexture2D *)texture;

- (void) serveAnimation;
- (void) serveBotAnimation;
- (void) passAnimation;
- (void) settingAnimation;
- (void) hittingAnimation;
- (void) passAnimationLow;

-(void)toss;
-(void)tossByBot;
-(void)tossByPartnerBot;

-(void) bounceAround;

- (void) hittingAnimationPower;

@end
