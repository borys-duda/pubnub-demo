//
//  AppDelegate.m
//  PubNubDemo
//
//  Created by Borys Duda on 05/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"
#import "BaseViewController.h"

#import "AdSupport/ASIdentifierManager.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

@implementation AppDelegate


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // initialize the global variables.
    gPubNub     = [[PubNub alloc] init];
    gChannels   = [[NSMutableArray alloc] init];
    gMessages   = [[NSMutableArray alloc] init];
    gLogs       = [[NSMutableArray alloc] init];
    
    gCurrentChannel = nil;
    
    // initialize the PubNub.
    [PubNub setDelegate:self];
    [gPubNub setDelegate:self];
    [Global PubNub_connect];
    [Global PubNub_addObserver:self];
    
    NSString *identifier = [self uniqueGlobalDeviceIdentifier];
    NSLog(@"Device Identifier = %@", identifier);
    [gPubNub setClientIdentifier:identifier];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    NSLog(@"DELEGATE: Connected to origin: %@", origin);
    [[self getMainViewController] hideLoadingSymbol];
    [self addLog:[NSString stringWithFormat:@"Connected to origin: %@", origin]];
}

// Delegate looks for subscribe events
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
    NSLog(@"DELEGATE: Subscribed to channel:%@", channels);
    [self addLog:[NSString stringWithFormat:@"Subscribed to channel:%@", channels]];
}

// Delegate looks for message receive events
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog(@"DELEGATE: Message received.");
    [self addLog:[NSString stringWithFormat:@"Message received: %@", message]];
}


// show the loading symbol.
- (void)showLoadingSymbol:(NSString*)text {
    [[self getMainViewController] showLoadingSymbol:text];
}

// hide the loading symbol.
- (void)hideLoadingSymbol {
    [[self getMainViewController] hideLoadingSymbol];
}

// move to the specified tab.
- (void)moveToTab:(NSInteger)tabIndex {
    UINavigationController *navvc = (UINavigationController*)self.window.rootViewController;
    
    for (UIViewController* vc in navvc.childViewControllers) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabvc = (UITabBarController*)vc;
            
            tabvc.selectedIndex = tabIndex;
        }
    }
}

// get the first view controller of tabbar.
- (BaseViewController*)getMainViewController {
    UINavigationController *navvc = (UINavigationController*)self.window.rootViewController;
    
    for (UIViewController* vc in navvc.childViewControllers) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabvc = (UITabBarController*)vc;
            for (UIViewController* vc in tabvc.viewControllers) {
                return (BaseViewController*)vc;
            }
        }
    }
    
    return nil;
}

// send the message to proper view controller.
- (void)addMessage:(NSDictionary*)message {
    UINavigationController *navvc = (UINavigationController*)self.window.rootViewController;
    
    for (UIViewController* vc in navvc.childViewControllers) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabvc = (UITabBarController*)vc;
            for (UIViewController* vc in tabvc.viewControllers) {
                if ([vc respondsToSelector:@selector(addMessage:)])
                    [vc performSelector:@selector(addMessage:) withObject:message];
            }
        }
    }
}

// send the log to proper view controller.
- (void)addLog:(NSString*)log {
    UINavigationController *navvc = (UINavigationController*)self.window.rootViewController;
    
    for (UIViewController* vc in navvc.childViewControllers) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabvc = (UITabBarController*)vc;
            for (UIViewController* vc in tabvc.viewControllers) {
                if ([vc respondsToSelector:@selector(addLog:)])
                    [vc performSelector:@selector(addLog:) withObject:log];
            }
        }
    }
}

// remove the channel from list.
- (void)removeChannel:(NSString*)channel {
    UINavigationController *navvc = (UINavigationController*)self.window.rootViewController;
    
    for (UIViewController* vc in navvc.childViewControllers) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabvc = (UITabBarController*)vc;
            for (UIViewController* vc in tabvc.viewControllers) {
                if ([vc respondsToSelector:@selector(removeChannel:)])
                    [vc performSelector:@selector(removeChannel:) withObject:channel];
            }
        }
    }
}

// get the unique device identifier.
- (NSString *)uniqueGlobalDeviceIdentifier{
	
	// IMPORTANT: iOS 6.0 has a bug when advertisingIdentifier or identifierForVendor occasionally might be empty! We have to fallback to hashed mac address here.
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.1")) {
		// >= iOS6 return advertisingIdentifier or identifierForVendor
		if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
			NSString *uuidString = [[UIDevice currentDevice].identifierForVendor UUIDString];
			if (uuidString) {
				return uuidString;
			}
		}
        
		if ([ASIdentifierManager class]) {
			NSString *uuidString = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
			if (uuidString) {
				return uuidString;
			}
		}
	}
    
	// Fallback on macaddress
    NSString *macaddress = [self macaddress];
    NSString *uniqueDeviceIdentifier = [self stringFromMD5:macaddress];
    
    return uniqueDeviceIdentifier;
}

// get the MD5 string.
- (NSString *)stringFromMD5: (NSString *)val{
    
    if(val == nil || [val length] == 0)
        return nil;
    
    const char *value = [val UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

@end
