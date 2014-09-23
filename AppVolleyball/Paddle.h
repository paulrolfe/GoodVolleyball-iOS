
#import "cocos2d.h"

typedef enum tagPaddleState {
	kPaddleStateGrabbed,
	kPaddleStateUngrabbed
} PaddleState;

@interface Paddle : CCSprite <CCTouchOneByOneDelegate> {
@private
	PaddleState state;

}

@property(nonatomic, readonly) CGRect rect;
@property(nonatomic, readonly) CGRect rectInPixels;
@property (nonatomic) CGPoint start;
@property BOOL iamhitter;
@property BOOL paused;

+ (id)paddleWithTexture:(CCTexture2D *)texture;
- (BOOL) canServe;
@end
