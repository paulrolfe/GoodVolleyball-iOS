//
//  InstructionsViewController.m
//  AppVolleyball
//
//  Created by Paul Rolfe on 10/19/13.
//  Copyright (c) 2013 Paul Rolfe. All rights reserved.
//

#import "InstructionsViewController.h"

@interface InstructionsViewController ()

@end

@implementation InstructionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWebView *aboutHTML = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height,self.view.bounds.size.width)];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://goodvolleyball.weebly.com/instructions.html"]];
    [aboutHTML loadRequest:urlRequest];
    [self.view addSubview:aboutHTML];
    
    self.navigationController.navigationBarHidden=NO;
}
- (void)loadAboutHTML {
    UIWebView *aboutHTML = [[UIWebView alloc] init];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"webpage" ofType:@"html"]]];
    [aboutHTML loadRequest:urlRequest];
    [self.view addSubview:aboutHTML];
}

-(void) viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
