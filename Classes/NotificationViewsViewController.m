//
//  NotificationViewsViewController.m
//  NotificationViews
//
//  Created by Nicholas Spencer on 2/17/10.
//  Copyright (c) 2010 Nicholas Scott Spencer.
//
//	Permission is hereby granted, free of charge, to any person
//	obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without
//	restriction, including without limitation the rights to use,
//	copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following
//	conditions:
//
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//	OTHER DEALINGS IN THE SOFTWARE.

#import "NotificationViewsViewController.h"
#import "NSSNotificationViewController.h"
#import "NSSNotificationView.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation NotificationViewsViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)loadView {
	[super loadView];
	UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, 100.0f, 30.0f)];
	testLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	testLabel.text = @"test";
	[self.view addSubview:testLabel];
	[UILabel release];
}

- (void)changeNotification {
	NSSNotificationView *notification = [[NSSNotificationView alloc] initWithString:@"your new thing has be placed" toTarget:self andSelector:@selector(playSound)];
	notification.backgroundColor = [UIColor colorWithRed:0.348 green:0.499 blue:0.856 alpha:1.000];
	notification.label.textColor = [UIColor whiteColor];
	notification.label.shadowColor = [UIColor blackColor];
	notification.label.shadowOffset = CGSizeMake(1, 1);
	[[NSSNotificationViewController sharedController] showNotificationView:notification withDuration:2.0f];
	[notification release];
}

- (void)playSound {
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"your thing has been placed" message:@"this is a test of the notification view context"  delegate:nil cancelButtonTitle:@"okay" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSSNotificationView *notification1 = [[NSSNotificationView alloc] initWithString:@"23 Things found near 6002 Goliad"];
	notification1.backgroundColor = [UIColor colorWithRed:0.849 green:1.000 blue:0.850 alpha:1.000];
	[[NSSNotificationViewController sharedController] addNotificationView:notification1 withKey:@"TestNotification1"];
	[notification1 release];
	
	NSSNotificationView *notification = [[NSSNotificationView alloc] initWithString:@"the network is down"];
	notification.backgroundColor = [UIColor colorWithRed:0.226 green:0.060 blue:0.050 alpha:1.000];
	[[NSSNotificationViewController sharedController] addNotificationView:notification withKey:@"TestNotification"];
	[notification release];
	
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(changeNotification) userInfo:nil repeats:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return !(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
