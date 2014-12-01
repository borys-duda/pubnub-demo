//
//  Global.m
//  PubNubDemo
//
//  Created by Borys Duda on 05/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "Global.h"
#import "Config.h"
#import "AppDelegate.h"


@implementation Global

// connect the PubNub server.
+ (void)PubNub_connect {
    
    // define client configuration.
    PNConfiguration *config = [PNConfiguration configurationForOrigin:ORIGIN_HOSTNAME
                                                           publishKey:KEY_PUBLISH
                                                         subscribeKey:KEY_SUBSCRIBE
                                                            secretKey:KEY_SECRET
                            ];
    
    // make the configuration active.
    [gPubNub setConfiguration:config];
    
    // connect to the PubNub.
    [gPubNub connect];
}

// add observers for PubNub.
+ (void)PubNub_addObserver:(id<PNDelegate>)delegate {
    AppDelegate* appDelegate = (AppDelegate*)delegate;
    
    // add observer to look for connection events.
    [gPubNub.observationCenter addClientConnectionStateObserver:delegate withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
            [appDelegate addLog:@"Successful Connection!"];
        }
        else if (!connected || connectionError)
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
            [appDelegate addLog:[NSString stringWithFormat:@"Error %@, Connection Failed!", connectionError.localizedDescription]];
        }
    }];
    
    // add Observer to look for subscribe events.
    [gPubNub.observationCenter addClientChannelSubscriptionStateObserver:delegate withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
                NSLog(@"OBSERVER: Subscribed to Channel: %@", channels[0]);
                [appDelegate addLog:[NSString stringWithFormat:@"Subscribed to Channel: %@", channels[0]]];
                break;
            case PNSubscriptionProcessNotSubscribedState:
                NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
                [appDelegate addLog:[NSString stringWithFormat:@"Not subscribed to Channel: %@, Error: %@", channels[0], error]];
                break;
            case PNSubscriptionProcessWillRestoreState:
                NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
                [appDelegate addLog:[NSString stringWithFormat:@"Will re-subscribe to Channel: %@", channels[0]]];
                break;
            case PNSubscriptionProcessRestoredState:
                NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
                [appDelegate addLog:[NSString stringWithFormat:@"Re-subscribed to Channel: %@", channels[0]]];
                break;
        }
    }];
    
    // add Observer to look for message received events.
    [gPubNub.observationCenter addMessageReceiveObserver:delegate withBlock:^(PNMessage *message) {
        NSLog(@"OBSERVER: Channel: %@, Message: %@", message.channel.name, message.message);
        
        if ([message.message isKindOfClass:[NSDictionary class]] && [message.message objectForKey:@"message"]) {
            [appDelegate addMessage:message.message];
            [appDelegate addLog:[NSString stringWithFormat:@"Channel: %@, Message: %@", message.channel.name, message.message]];
        }
        else
            [appDelegate addLog:[NSString stringWithFormat:@"Unknown type of message - Channel: %@, Message: %@", message.channel.name, message.message]];
    }];
}

// subscribe the specified channel.
+ (void)PubNub_subscribeChannel:(NSString*)channel {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate showLoadingSymbol:@"Subscribing..."];
    
    PNChannel *newChannel = [PNChannel channelWithName:channel shouldObservePresence:YES];
    
    [gPubNub subscribeOn:@[newChannel]
                withClientState:nil
     andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
        if (state == PNSubscriptionProcessSubscribedState || subscriptionError) {
            if (subscriptionError) {
                [appDelegate addLog:[NSString stringWithFormat:@"%@", subscriptionError.localizedFailureReason]];
                [Global popupAlert:@"Error" message:@"Subscription Failed."];
            }
            else {
                gCurrentChannel = newChannel;
                
                // add logs.
                [appDelegate addLog:@"Subscription Success!"];
                [appDelegate addLog:[NSString stringWithFormat:@"Subscription State: %lu", state]];
                
                // move to the message tab.
                [appDelegate moveToTab:1];
            }
            
            [appDelegate hideLoadingSymbol];
        }
    }];
    
    int64_t delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // grab global occupancy list 5s later
        [gPubNub requestParticipantsListWithClientIdentifiers:NO clientState:YES];
    });
}

// subscribe the specified channel.
+ (void)PubNub_unsubscribeChannel:(NSString*)channel {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate showLoadingSymbol:@"Unsubscribing..."];
    
    PNChannel *newChannel = [PNChannel channelWithName:channel shouldObservePresence:YES];
    
    [gPubNub unsubscribeFrom:@[newChannel]
        withCompletionHandlingBlock:^(NSArray *channels, PNError *subscriptionError) {
        if (subscriptionError) {
            [appDelegate addLog:[NSString stringWithFormat:@"%@", subscriptionError.localizedFailureReason]];
            [Global popupAlert:@"Error" message:@"Unsubscription Failed."];
        }
        else {
            gCurrentChannel = newChannel;
                
            // add logs.
            [appDelegate addLog:@"Unsubscription Success!"];
                
            // move to the message tab.
            [appDelegate removeChannel:channel];
        }
            
        [appDelegate hideLoadingSymbol];
    }];
    
    int64_t delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // grab global occupancy list 5s later
        [gPubNub requestParticipantsListWithClientIdentifiers:NO clientState:YES];
    });
}

// send the message through the current channel.
+ (void)PubNub_sendMessage:(NSString*)message sender:(NSString*)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (gCurrentChannel == nil) {
        [Global popupAlert:@"Error" message:@"There is no available channel to send the message."];
        // move to the channel tab.
        [appDelegate moveToTab:0];
        
        return;
    }
    
    [appDelegate showLoadingSymbol:@"Sending..."];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *date = [DateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *msg = @{
                            @"sender":          sender,
                            @"message":         message,
                            @"timestamp":       date
                        };
    
    [gPubNub sendMessage:msg
               toChannel:gCurrentChannel
     withCompletionBlock:^(PNMessageState state, id object) {
        if (state == PNMessageSendingError) {
            [appDelegate addLog:[NSString stringWithFormat:@"Message Error: %@", (PNError*)object]];
        }
        else if (state == PNMessageSent) {
            [appDelegate addLog:[NSString stringWithFormat:@"Message Sent: %@", message]];
        }
        
        [appDelegate hideLoadingSymbol];
    }];
}


// create new UIBarButton for left or right of navigation bar.
+ (UIButton*)createUIBarButton:(NSString*)title width:(int)width target:(id)target clickSelector:(SEL)clickSelector {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setFrame:CGRectMake(0, 0, width, 30)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [btn addTarget:target
            action:clickSelector
  forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
    
}

// set the navigation title with new font and color for UIViewController.
+ (void)setNavigationTitle:(NSString*)title width:(int)width target:(UIViewController*)target {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    label.text = title;
    
    target.title = title;
    [target.navigationItem setTitleView:label];
}

// apply settings (font, color, border, etc) to button.
+ (void)applySettingsToButton:(UIButton*)btn {
    
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [[UIColor blackColor] CGColor];
    btn.layer.cornerRadius = 3;
    btn.clipsToBounds = TRUE;
}

// popup alert with title and message (not delegate).
+ (void)popupAlert:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil
                          ];
    [alert show];
}


@end