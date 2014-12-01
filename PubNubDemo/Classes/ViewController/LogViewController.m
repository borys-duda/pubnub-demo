//
//  LogViewController.m
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "LogViewController.h"
#import "Global.h"


@interface LogViewController ()

@end

@implementation LogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.logContents.text = @"";
    for (int i = 0; i < [gLogs count]; i++)
        [self addLogToTextField:[gLogs objectAtIndex:i]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Global setNavigationTitle:@"Logs" width:30 target:self.tabBarController];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onClear:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)onClear:(id)sender {
    [self.logContents setText:@""];
}

- (void)addLog:(NSString*)log {
    [gLogs addObject:log];
    [self addLogToTextField:log];
}

- (void)addLogToTextField:(NSString*)log {
    NSString *newLog = [NSString stringWithFormat:@"%@%@\n", self.logContents.text, log];
    [self.logContents setText:newLog];
}

@end
