
#import "Paddle.h"
#import "cocos2d.h"

@implementation Paddle

@synthesize start,iamhitter,paused;

- (CGRect)rectInPixels
{
	CGSize s = [self.texture contentSizeInPixels];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (CGRect)rect
{
	CGSize s = [self.texture contentSize];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

+ (id)paddleWithTexture:(CCTexture2D *)aTexture
{
	return [[[self alloc] initWithTexture:aTexture] autorelease];
}

- (id)initWithTexture:(CCTexture2D *)aTexture
{
	if ((self = [super initWithTexture:aTexture]) ) {

		state = kPaddleStateUngrabbed;
	}

	return self;
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

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
	CGRect r = [self rectInPixels];
	return CGRectContainsPoint(r, p);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	
    if (paused) return NO;
    if (state != kPaddleStateUngrabbed) return NO;
	if ( ![self containsTouchLocation:touch] ) return NO;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"] isEqualToString:@"kTossing"]) return NO;

    //CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_grabbed.png"];
    //self.texture = paddleTexture2;

	state = kPaddleStateGrabbed;
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{


	NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");
    
        CGPoint touchPoint = [touch locationInView:[touch view]];
        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        
        self.position = CGPointMake(touchPoint.x, touchPoint.y+25);
        float f=.4+(320-self.position.y)/320;
        self.scale=f;
    
    if (self.position.y>181+self.boundingBox.size.height/3){
        self.position = CGPointMake(touchPoint.x, 181+self.boundingBox.size.height/3);
        self.scale = .4+(320-(181+self.boundingBox.size.height/3))/320;
    }

}
-(BOOL) canServe{
    return (self.position.y-self.boundingBox.size.height/2 < 18 && state==kPaddleStateUngrabbed);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kPaddleStateGrabbed, @"Paddle - Unexpected state!");

	state = kPaddleStateUngrabbed;
    //CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman.png"];
    //self.texture = paddleTexture2;
    
    if (self.canServe && [[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"] isEqualToString:@"jPreServe"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"jTossing" forKey:@"stateOfPlay"];
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"stateOfPlay"] isEqualToString:@"jSet"] && iamhitter && self.position.y > 180){
        [self jumpAction];
        [[NSUserDefaults standardUserDefaults] setObject:@"jHitting" forKey:@"stateOfPlay"];

    }

}

- (void) jumpAction{
    id doJump = [CCJumpTo actionWithDuration:1.2 position:self.position height:70 jumps:1];
    [self runAction:doJump];
    CCTexture2D *paddleTexture2 = [[CCTextureCache sharedTextureCache] addImage:@"greenman_serve.png"];
    self.texture = paddleTexture2;

}
@end
