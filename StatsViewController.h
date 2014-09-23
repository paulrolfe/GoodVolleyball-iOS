//
//  StatsViewController.h
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/18/13.
//  Copyright (c) 2013 Paul Rolfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppSpecificValues.h"
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"


@interface StatsViewController : UITableViewController <NSFetchedResultsControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate>{
    GameCenterManager* gameCenterManager;

}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) GameCenterManager *gameCenterManager;


@end
