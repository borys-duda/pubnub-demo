//
//  BaseViewController.m
//  PubNubDemo
//
//  Created by Borys Duda on 06/10/14.
//  Copyright (c) 2014 Borys Duda. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end


#define     TAG_LOADING         100


@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


// show the loading symbol.
- (void)showLoadingSymbol:(NSString *)message {
    UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	
    UILabel *waitingLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 140, 20)];
	waitingLable.text = message;
    waitingLable.textColor = [UIColor whiteColor];
    waitingLable.font = [UIFont systemFontOfSize:16];
    waitingLable.backgroundColor = [UIColor clearColor];
    
    CGRect frame = [self.view frame];
	frame = CGRectMake((frame.size.width - 200) / 2, (frame.size.height - 40) / 2, 200, 40);
    UIView *theView = [[UIView alloc] initWithFrame:frame];
	theView.layer.cornerRadius = 7;
    theView.backgroundColor = [UIColor blackColor];
    theView.alpha = 0.6;
    [theView addSubview:progressInd];
    [theView addSubview:waitingLable];
	
	UIView *pageView = [[UIView alloc] initWithFrame:self.view.frame];
	pageView.backgroundColor = [UIColor clearColor];
	pageView.tag = TAG_LOADING;
	[pageView addSubview:theView];
	
    [self.navigationController.view addSubview:pageView];
    [self.navigationController.view bringSubviewToFront:pageView];
}

// hide the loading symbol.
- (void)hideLoadingSymbol
{
    UIView *v = [self.navigationController.view viewWithTag:TAG_LOADING];
    if (v) [v removeFromSuperview];
}

@end
