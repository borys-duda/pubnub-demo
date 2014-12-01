//
//  BaseViewController.h
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void)showLoadingSymbol:(NSString *)message;
- (void)hideLoadingSymbol;

@end
