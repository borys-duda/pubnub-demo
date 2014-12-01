//
//  MessageViewController.h
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"


@interface MessageViewController : BaseViewController <UIBubbleTableViewDataSource>


@property (weak, nonatomic) IBOutlet UILabel                *labelChannel;
@property (weak, nonatomic) IBOutlet UITextField *senderText;
@property (weak, nonatomic) IBOutlet UITextField            *messageText;
@property (weak, nonatomic) IBOutlet UIButton               *btnSend;
@property (weak, nonatomic) IBOutlet UIBubbleTableView      *messageTable;
@property (nonatomic, strong) NSMutableArray                *messageData;


- (IBAction)onSend:(id)sender;
- (void)addMessage:(NSDictionary*)message;

@end
