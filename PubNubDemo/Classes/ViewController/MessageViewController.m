//
//  MessageViewController.m
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "MessageViewController.h"
#import "Global.h"


@interface MessageViewController ()

@end

@implementation MessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageData = [[NSMutableArray alloc] initWithObjects:nil];
    self.messageTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    self.messageTable.snapInterval = 60 * 60 * 24;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    self.messageTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    self.messageTable.typingBubble = NSBubbleTypingTypeNobody;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Global setNavigationTitle:@"Messages" width:30 target:self.tabBarController];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onClear:)];
    
    if (gCurrentChannel)
        self.labelChannel.text = [NSString stringWithFormat:@"Current Channel: %@", gCurrentChannel.name];
    else
        self.labelChannel.text = @"No available channel";
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

- (IBAction)onSend:(id)sender {
    NSString *senderName    = self.senderText.text;
    NSString *message       = self.messageText.text;
    
    if ([message isEqualToString:@""]) {
        [Global popupAlert:@"Error" message:@"Please input the message."];
        return;
    }

    [Global PubNub_sendMessage:message sender:senderName];
    
    [self.messageText setText:@""];
    [self.messageText resignFirstResponder];
}

- (IBAction)onClear:(id)sender {
    [self.messageText setText:@""];
    
    [self.messageData removeAllObjects];
    [self.messageTable reloadData];
}

- (void)addMessage:(NSDictionary*)message {
    NSBubbleData *sayBubble = [NSBubbleData dataWithDictionary:message type:BubbleTypeMine];
    
    [self.messageData addObject:sayBubble];
    [self.messageTable reloadData];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [self.messageData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [self.messageData objectAtIndex:row];
}

@end
