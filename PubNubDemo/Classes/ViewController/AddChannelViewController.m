//
//  AddChannelViewController.m
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "AddChannelViewController.h"
#import "Global.h"


@interface AddChannelViewController ()

@end

@implementation AddChannelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Global applySettingsToButton:self.btnSubmit];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Global setNavigationTitle:@"Add Channel" width:100 target:self];
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

- (IBAction)onSubmit:(id)sender {
    NSString *name = self.channelName.text;
    
    if ([name isEqualToString:@""]) {
        [Global popupAlert:@"Error" message:@"Please input the channel name."];
        return;
    }
    
    [gChannels addObject:name];
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
