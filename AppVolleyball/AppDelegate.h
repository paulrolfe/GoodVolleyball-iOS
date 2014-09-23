//
//  AppDelegate.h
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/10/13.
//  Copyright Paul Rolfe 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "cocos2d.h"

// Added only for iOS 6 support






@interface MyNavigationController : UINavigationController <CCDirectorDelegate>

@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref

}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
