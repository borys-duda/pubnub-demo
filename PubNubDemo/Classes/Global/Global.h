//
//  Global.h
//  PubNubDemo
//
//  Created by Borys Duda on 05/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//


#import <Foundation/Foundation.h>


NSMutableArray      *gChannels;
NSMutableArray      *gLogs;
NSMutableArray      *gMessages;

PNChannel           *gCurrentChannel;
PubNub              *gPubNub;


@interface Global : NSObject

// PubNub functions
+ (void)PubNub_connect;
+ (void)PubNub_addObserver:(id<PNDelegate>)delegate;
+ (void)PubNub_subscribeChannel:(NSString*)channel;
+ (void)PubNub_unsubscribeChannel:(NSString*)channel;
+ (void)PubNub_sendMessage:(NSString*)message sender:(NSString*)sender;

// UI functions
+ (UIButton*)createUIBarButton:(NSString*)title width:(int)width target:(id)target clickSelector:(SEL)clickSelector;
+ (void)setNavigationTitle:(NSString*)title width:(int)width target:(id)target;
+ (void)applySettingsToButton:(UIButton*)btn;
+ (void)popupAlert:(NSString*)title message:(NSString*)message;

@end
