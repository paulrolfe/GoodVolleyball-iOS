//
//  StatsViewController.m
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/18/13.
//  Copyright (c) 2013 Paul Rolfe. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController
@synthesize gameCenterManager,fetchedResultsController;

NSArray * categories;
NSMutableArray * statStrings;
//NSMutableArray * rawStats;

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        return YES;
    }
    if (interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        return YES;
    }
    
    return YES;
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.title=@"Stats";
    
    //create the cell names.
    categories = [[NSArray alloc] initWithObjects:@"Games Played", @"Games Won (winning %)",@"Average point differential", @"Total Hits (hitting %)", @"Total Kills (kills/game)",@"Aces (serving %)" , @"Total Digs (digs/game)", @"Total Assists (assists/game)", @"Total POWER SPIKES", nil];
    
    // Fetch the stats from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stats"];
    NSMutableArray *rawStatsArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (rawStatsArray.count !=0){
    
        NSManagedObject * rawStats = [rawStatsArray lastObject];
    
        gamesPlayed = [[rawStats valueForKey:@"gamesPlayed"] intValue];
        gamesWon=[[rawStats valueForKey:@"gamesWon"] intValue];
        hitsAttempts=[[rawStats valueForKey:@"hitsAttempts"] intValue];
        hitsKills=[[rawStats valueForKey:@"hitsKills"] intValue];
        hitsErrors=[[rawStats valueForKey:@"hitsErrors"] intValue];
        digsMade=[[rawStats valueForKey:@"digsMade"] intValue];
        assistsMade=[[rawStats valueForKey:@"assistsMade"] intValue];
        powerSpikes=[[rawStats valueForKey:@"powerSpikes"] intValue];
        pointsFor=[[rawStats valueForKey:@"pointsFor"] intValue];
        pointsAgainst=[[rawStats valueForKey:@"pointsAgainst"] intValue];
        servesAces=[[rawStats valueForKey:@"servesAces"] intValue];
        servesAttempts=[[rawStats valueForKey:@"servesAttempts"] intValue];
        servesErrors=[[rawStats valueForKey:@"servesErrors"] intValue];
        
    
        if (gamesPlayed != 0 && hitsAttempts != 0){
            float winPerc=((float)gamesWon/(float)gamesPlayed)*100;
            float pointsDiff=((float)pointsFor-(float)pointsAgainst)/(float)gamesPlayed;
            float hitPerc=((float)hitsKills-(float)hitsErrors)/(float)hitsAttempts*100;
            float killPerc=((float)hitsKills/(float)gamesPlayed);
            float digPerc=((float)digsMade/(float)gamesPlayed);
            float assistPerc=((float)assistsMade/(float)gamesPlayed);
            float powerPerc=((float)powerSpikes/(float)gamesPlayed);
            float servePerc = (((float)servesAttempts-(float)servesErrors)/(float)servesAttempts)*100;

        
            statStrings = [[NSMutableArray alloc] init];
            [statStrings addObject:[NSString stringWithFormat:@"%d",gamesPlayed]]; //Game played
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f%%)",gamesWon, winPerc]]; //Games won
            [statStrings addObject:[NSString stringWithFormat:@"%f",pointsDiff]]; //Point differential
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f%%)",hitsAttempts,hitPerc]]; //Hits
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f)",hitsKills, killPerc]]; //Kills
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f)",servesAces, servePerc]]; //Aces (serve%)
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f)",digsMade, digPerc]]; //Digs
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f)",assistsMade,assistPerc ]]; //Assists
            [statStrings addObject:[NSString stringWithFormat:@"%d (%.2f)",powerSpikes,powerPerc ]]; //PowerSpikes
         
        }
    }

    self.navigationController.navigationBarHidden=NO;
    UIBarButtonItem * Achievements = [[UIBarButtonItem alloc]initWithTitle:@"Achievements" style:UIBarButtonItemStylePlain target:self action:@selector(showAchievements)];
    self.navigationItem.rightBarButtonItem=Achievements;

}
-(void) viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;

}
-(void) viewDidAppear:(BOOL)animated{
    if([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager= [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate: self];
		[self.gameCenterManager authenticateLocalUser];
		
        [self checkAchievements];
    }
	else
	{
		[self showAlertWithTitle: @"Game Center Support Required!"
						 message: @"The current device does not support Game Center, which this sample requires."];
	}
}
- (void) showAlertWithTitle: (NSString*) title message: (NSString*) message
{
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: title message: message
                                                   delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] autorelease];
	[alert show];
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [categories objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [statStrings objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) showAchievements
{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
		[self presentViewController:achievements animated:YES completion:nil];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
{
	[self dismissViewControllerAnimated: YES completion:nil];
	[viewController release];
}
- (void) checkAchievements
{
	NSString* identifier= NULL;
	double percentComplete= 0;
    
    if (gamesPlayed >= 1){
        identifier=kAchievementFirstGame;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    
    //gamesPlayed Achievements
    if (gamesPlayed >= 5){
        identifier=kAchievement5GamesPlayed;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (gamesPlayed >= 25){
        identifier=kAchievement25GamesPlayed;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (gamesPlayed >= 50){
        identifier=kAchievement50GamesPlayed;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (gamesPlayed >= 100){
        identifier=kAchievement100GamesPlayed;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    
    //gamesWon Achievements
    if (gamesWon>= 10){
        identifier=kAchievement10GamesWon;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (gamesWon >= 25){
        identifier=kAchievement25GamesWon;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (gamesWon >= 50){
        identifier=kAchievement50GamesWon;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (gamesWon >= 100){
        identifier=kAchievement100GamesWon;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    
    //Kills achievements
    if (hitsKills>= 100){
        identifier=kAchievement100Kills;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (hitsKills >= 500){
        identifier=kAchievement500Kills;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
    if (hitsKills >= 1000){
        identifier=kAchievement1000Kills;
        percentComplete=100.0;
        [self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
