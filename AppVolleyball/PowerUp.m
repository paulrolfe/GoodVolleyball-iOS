
#import "PowerUp.h"
#import "cocos2d.h"
#import "Ball.h"

@implementation PowerUp
@synthesize start;

+ (id)powerWithTexture:(CCTexture2D *)aTexture
{
	return [[[self alloc] initWithTexture:aTexture] autorelease];
}

- (void)onEnter
{
	CCDirector *director =  [CCDirector sharedDirector];
    
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	CCDirector *director = [CCDirector sharedDirector];
    
	[[director touchDispatcher] removeDelegate:self];
	[super onExit];
}
- (CGRect)rectInPixels
{
	CGSize s = [self.texture contentSizeInPixels];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
	CGRect r = [self rectInPixels];
	return CGRectContainsPoint(r, p);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSString * stateOfPlay =[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"];

    
	if ( ![self containsTouchLocation:touch] ) return NO;
    if ( ![stateOfPlay isEqualToString:@"jHitting"] || !self.isLive) return NO;
    
    self.isGrabbed=YES;
    
	return YES;
    
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    self.position = touchPoint;

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.isGrabbed=NO;
    id backHome = [CCMoveTo actionWithDuration:.2 position:start];
    
    [self setEnd:self.position];
    
    [self runAction:backHome];
    
}

@end
