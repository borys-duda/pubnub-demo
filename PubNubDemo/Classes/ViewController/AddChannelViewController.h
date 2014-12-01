//
//  AddChannelViewController.h
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface AddChannelViewController : BaseViewController


@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;


- (IBAction)onSubmit:(id)sender;


@end
