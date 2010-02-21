//
//  NotificationViewController.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NSSNotificationView.h"

enum kAnimationState {
	kAnimationStateFinished,
	kAnimationStateDismissing,
	kAnimationStatePresenting	
};

@interface NSSNotificationViewController : UIViewController {
	UIView *_backgroundView;
	UIView *_notificationBar;
	NSMutableDictionary *_notifications;
	NSMutableArray *_keys;
	NSTimeInterval _defaultDuration;
	NSTimeInterval _pauseDuration;
	CATransition *_fadeTransition;
	NSTimer *_durationTimer;
	NSTimer *_pauseTimer;
	int _currentIndex;
	int _currentAnimationState;
	UIInterfaceOrientation _interfaceOrientation;
}

@property (nonatomic,readonly) UIView *backgroundView;
@property (nonatomic,assign) NSTimeInterval defaultDuration;
@property (nonatomic,assign) NSTimeInterval pauseDuration;

+(NSSNotificationViewController *)sharedController;
-(void)resetNotifications;

//notification queue methods; keys must not be nil
-(void)addNotificationView:(NSSNotificationView *)noticationView withKey:(id)key;
-(void)removeNotificationViewForKey:(id)key;

//single notification methods
-(void)showNotificationView:(NSSNotificationView *)notificationView;
-(void)showNotificationView:(NSSNotificationView *)notificationView withDuration:(NSTimeInterval)duration;

@end
