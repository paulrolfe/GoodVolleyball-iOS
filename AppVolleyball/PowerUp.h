
#import "cocos2d.h"


@interface PowerUp : CCSprite <CCTouchOneByOneDelegate> {
@private
}
+ (id)powerWithTexture:(CCTexture2D *)aTexture;
@property CGPoint start;
@property CGPoint end;
@property BOOL isLive;
@property BOOL isGrabbed;

@end