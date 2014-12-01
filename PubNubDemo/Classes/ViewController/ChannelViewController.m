//
//  ChannelViewController.m
//  PubNubDemo
//
//  Created by Borys Duda on 05/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "ChannelViewController.h"
#import "Global.h"


@interface ChannelViewController ()

@end


#define TAG_LABEL       1000

@implementation ChannelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.channelTableView.delegate = self;
    self.channelTableView.dataSource = self;

    [self showLoadingSymbol:@"Connecting..."];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Global setNavigationTitle:@"Channels" width:100 target:self.tabBarController];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddChannel:)];
    
    [self.channelTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddChannel:(id)sender {
    [self performSegueWithIdentifier:@"toAddChannel" sender:self];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gChannels count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellForChannel"];
    
    UILabel* label = (UILabel*)[cell viewWithTag:TAG_LABEL];
    label.text = [gChannels objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0)
        return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription"
                                                    message:@"Please select the operation for this channel."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Subscribe", @"Unsubscribe", nil
                        ];
    [alert show];
}


#pragma mark -
#pragma mark UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [self.channelTableView indexPathForSelectedRow];
    
    switch (buttonIndex) {
        case 1:             // Subscribe button
            if (indexPath) {
                [Global PubNub_subscribeChannel:gChannels[indexPath.row]];
            }
            break;
            
        case 2:             // Unsubscribe button
            if (indexPath) {
                [Global PubNub_unsubscribeChannel:gChannels[indexPath.row]];
            }
            break;
    }
}

- (void)removeChannel:(NSString*)channel {
    [gChannels removeObject:channel];
    [self.channelTableView reloadData];
}


@end
