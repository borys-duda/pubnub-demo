//
//  AppDelegate.h
//  PubNubDemo
//
//  Created by Borys Duda on 05/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, PNDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showLoadingSymbol:(NSString*)text;
- (void)hideLoadingSymbol;
- (void)addMessage:(NSDictionary*)message;
- (void)addLog:(NSString*)log;
- (void)removeChannel:(NSString*)channel;
- (void)moveToTab:(NSInteger)tabIndex;

@end
