//
//  LogViewController.h
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface LogViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextView *logContents;

- (void)addLog:(NSString*)log;

@end
