//
//  ChannelViewController.h
//  PubNubDemo
//
//  Created by Borys Duda on 05/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface ChannelViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *channelTableView;

- (IBAction)onAddChannel:(id)sender;
- (void)removeChannel:(NSString*)channel;

@end
