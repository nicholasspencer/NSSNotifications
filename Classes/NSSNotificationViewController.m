//
//  NotificationViewController.m
//  PlaceThings
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

#import "NSSNotificationViewController.h"

@interface NSSNotificationViewController (PrivateMethods)
-(void)orientationChanged:(NSNotification *)notification;
-(void)updateOrientationChange;
-(void)reframeView;
-(void)presentNotificationView:(NSSNotificationView *)notificationView;
-(void)presentNotificationView:(NSSNotificationView *)notificationView forDuration:(NSTimeInterval)duration;
-(void)presentNextNotificationView;
-(void)dismissCurrentNotificationView;
-(void)spawnDurationTimerWithTimerInterval:(NSTimeInterval)duration;
-(void)spawnPauseTimer;
-(void)durationTimerFired:(NSTimer *)timer;
-(void)pauseTimerFired:(NSTimer *)timer;
@end


NSSNotificationViewController *_sharedController;
@implementation NSSNotificationViewController
@synthesize defaultDuration = _defaultDuration, pauseDuration = _pauseDuration, backgroundView = _backgroundView;

+(NSSNotificationViewController *)sharedController {
	if(_sharedController == nil) {
		_sharedController = [[NSSNotificationViewController alloc] init];
	}
	return _sharedController;
}

- (id)init {
	if (self = [super init]) {
		
		//Start observing the status bar's orientation so we can copy any rotational changes
		self.wantsFullScreenLayout = YES;
		
		_pauseDuration = 5.0f;
		_defaultDuration = 20.0f;
		
		_notifications = [[NSMutableDictionary dictionary] retain];
		_keys = [[NSMutableArray array] retain];
		
		_fadeTransition = [[CATransition animation] retain];
		_fadeTransition.delegate = self;
		_fadeTransition.type = kCATransitionFade;
		_fadeTransition.duration = 0.15;
		
		_currentIndex = 0;
		_currentAnimationState = kAnimationStateFinished;
		
		_backgroundView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
		_backgroundView.backgroundColor = [UIColor blackColor];
		
		_notificationBar = [[UIView alloc] initWithFrame:_backgroundView.frame];
		_notificationBar.backgroundColor = [UIColor clearColor];
		
		_interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	}
	return self;
}

- (void)loadView {
	[super loadView];
	[self.view addSubview:_backgroundView];
	[self.view addSubview:_notificationBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	
	self.view.frame = _backgroundView.frame;
	//self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark animation delegate methods

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	//NSLog(@"animationDidStop:::");
	if ([theAnimation isEqual:(CAAnimation *)_fadeTransition]) {
		return;
	}
	if (_currentAnimationState==kAnimationStateDismissing) {
		//pop the view
		[(UIView *)[_notificationBar.subviews objectAtIndex:0] removeFromSuperview];
	} else if (_currentAnimationState==kAnimationStatePresenting) {
		//while the subview count is greater than one, pop the first subview
		while ([_notificationBar.subviews count]>1) {
			[(UIView *)[_notificationBar.subviews objectAtIndex:0] removeFromSuperview];
		}
	}
}

- (void)orientationChanged:(NSNotification *)notification
{
    // We must add a delay here, otherwise we'll swap in the new view
	// too quickly and we'll get an animation glitch
    [self performSelector:@selector(updateOrientationChange) withObject:nil afterDelay:0];
}

- (void)updateOrientationChange
{
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
	NSLog(@"Orientation %D", statusBarOrientation);
	if (_interfaceOrientation==statusBarOrientation) return;
	
	self.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	[UIView beginAnimations:@"barOrientation" context:nil];
	if (_interfaceOrientation==1&&statusBarOrientation==2||
		_interfaceOrientation==2&&statusBarOrientation==1||
		_interfaceOrientation==3&&statusBarOrientation==4||
		_interfaceOrientation==4&&statusBarOrientation==3) {
		[UIView setAnimationDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration*2];
	} else {
		[UIView setAnimationDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration];
	}
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(reframeView)];
	if (statusBarOrientation==UIInterfaceOrientationPortrait) {
		CGAffineTransform transform = CGAffineTransformMakeRotation(0);
		self.view.transform = transform;
		self.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		_backgroundView.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 20.0f);
		_notificationBar.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 20.0f);
	} else if (statusBarOrientation==UIInterfaceOrientationPortraitUpsideDown) {
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159);
		self.view.transform = transform;
		self.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		_backgroundView.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 20.0f);
		_notificationBar.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 20.0f);
		 
	} else if (statusBarOrientation==UIInterfaceOrientationLandscapeLeft) {
		CGAffineTransform transform = CGAffineTransformMakeRotation(-3.14159/2);
		self.view.transform = transform;
		self.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		_backgroundView.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 20.0f);
		_notificationBar.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 20.0f);
	} else if (statusBarOrientation==UIInterfaceOrientationLandscapeRight) {
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
		self.view.transform = transform;
		self.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		_backgroundView.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 20.0f);
		_notificationBar.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 20.0f);
	}
	[UIView commitAnimations];
	
	_interfaceOrientation = statusBarOrientation;
}

-(void)reframeView {
	if (_interfaceOrientation==UIInterfaceOrientationPortrait) {
		self.view.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 20.0f);
	} else if (_interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
		self.view.frame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height-20.0f, [UIScreen mainScreen].bounds.size.width, 20.0f);
	} else if (_interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
		self.view.frame = CGRectMake(0.0f, 0.0f, 20.0f, [UIScreen mainScreen].bounds.size.height);
	} else if (_interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
		self.view.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-20.0f, 0.0f, 20.0f, [UIScreen mainScreen].bounds.size.height);
	}
}


#pragma mark -
#pragma mark private methods


-(void)presentNotificationView:(NSSNotificationView *)notificationView {
	//NSLog(@"presentNotificationView:");
	[self presentNotificationView:notificationView forDuration:_defaultDuration];
}

-(void)presentNotificationView:(NSSNotificationView *)notificationView forDuration:(NSTimeInterval)duration {
	notificationView.hidden = YES;
	notificationView.frame = _notificationBar.frame;
	[_notificationBar addSubview:notificationView];
	[CATransaction begin];
	notificationView.hidden = NO;
	[[self.view layer] addAnimation:_fadeTransition forKey:[notificationView description]];
	[CATransaction commit];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	_currentAnimationState = kAnimationStatePresenting;
	[self spawnDurationTimerWithTimerInterval:duration];
}

-(void)presentNextNotificationView {
	//NSLog(@"presentNextNotificationView");
	if ([_keys count]==0) {
		_currentAnimationState = kAnimationStateFinished;
		return;
	}
	_currentIndex = (_currentIndex==[_keys count]-1) ? 0 : ++_currentIndex;
	[self presentNotificationView:[_notifications objectForKey:[_keys objectAtIndex:_currentIndex]]];
}

-(void)dismissCurrentNotificationView {
	//NSLog(@"dismissCurrentNotificationView");
	UIView *currentNotificationView = (UIView *)[_notificationBar.subviews lastObject];
	if(currentNotificationView==nil) return;
	[CATransaction begin];
	currentNotificationView.hidden = YES;
	[[self.view layer] addAnimation:_fadeTransition forKey:[currentNotificationView description]];
	[CATransaction commit];
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	_currentAnimationState = kAnimationStateDismissing;
	[self spawnPauseTimer];
}

-(void)spawnDurationTimerWithTimerInterval:(NSTimeInterval)duration {
	[_durationTimer invalidate];
	[_durationTimer release];
	_durationTimer = nil;
	_durationTimer = [[NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(durationTimerFired:) userInfo:nil repeats:NO] retain];
}

-(void)spawnPauseTimer {
	[_pauseTimer invalidate];
	[_pauseTimer release];
	_pauseTimer = nil;
	_pauseTimer = [[NSTimer scheduledTimerWithTimeInterval:_pauseDuration target:self selector:@selector(pauseTimerFired:) userInfo:nil repeats:NO] retain];
}

-(void)durationTimerFired:(NSTimer *)timer {
	[self dismissCurrentNotificationView];
}

-(void)pauseTimerFired:(NSTimer *)timer {
	[self presentNextNotificationView];
}

#pragma mark -
#pragma mark accessor methods;

-(void)resetNotifications { 
	//NSLog(@"resetNotifications");
	[_notifications removeAllObjects];
}

-(void)addNotificationView:(NSSNotificationView *)noticationView withKey:(id)key {
	//NSLog(@"addNotificationView::");
	if (key==nil) return;
	[_notifications setObject:noticationView forKey:key];
	[_keys addObject:key];
	if (_currentAnimationState==kAnimationStateFinished) {
		[self presentNextNotificationView];
	}
}

-(void)removeNotificationViewForKey:(id)key {
	//NSLog(@"removeNotificationViewForKey:");
	if (key==nil) return;
	[_notifications removeObjectForKey:key];
	[_keys removeObjectIdenticalTo:key];
}

-(void)showNotificationView:(NSSNotificationView *)notificationView{
	//NSLog(@"showNotificationView:");
	//invalidate the timers so that we can squeeze this new notification in
	[_durationTimer invalidate];
	[_pauseTimer invalidate];
	[self presentNotificationView:notificationView];
}

-(void)showNotificationView:(NSSNotificationView *)notificationView withDuration:(NSTimeInterval)duration{
	//NSLog(@"showNotificationView::");
	//invalidate the timers so that we can squeeze this new notification in
	[_durationTimer invalidate];
	[_pauseTimer invalidate];
	[self presentNotificationView:notificationView forDuration:duration];
}

#pragma mark -
#pragma mark touch methods


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UIView *currentView = [_notificationBar.subviews lastObject];
	if (![currentView isKindOfClass:[NSSNotificationView class]]) return;
	NSSNotificationView *currentNotification = (NSSNotificationView *)currentView;
	[_durationTimer invalidate];
	[_pauseTimer invalidate];
	if (currentNotification.target!=nil) {
		if ([currentNotification.target respondsToSelector:currentNotification.action]) {
			[currentNotification.target performSelector:currentNotification.action];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([_durationTimer isValid]==NO) {
		[self spawnDurationTimerWithTimerInterval:_defaultDuration];
	}
}
		


@end
