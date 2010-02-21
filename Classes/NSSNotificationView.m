//
//  NSSNotificationView.m
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

#import "NSSNotificationView.h"


@implementation NSSNotificationView

@synthesize label = _notificationLabel, target = _target, action = _action;

- (id)initWithString:(NSString *)notification {
    if ((self = [super initWithFrame:[UIApplication sharedApplication].statusBarFrame])) {
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		_notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f,3.0f,self.frame.size.width-10.0f,self.frame.size.height)];
		_notificationLabel.font = [UIFont boldSystemFontOfSize:13];
		_notificationLabel.backgroundColor = [UIColor clearColor];
		_notificationLabel.textColor = [UIColor lightGrayColor];
		_notificationLabel.text = notification;
		_notificationLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:_notificationLabel];
	}
	return self;
}

- (id)initWithString:(NSString *)notification toTarget:(id)target andSelector:(SEL)action {
    if ((self = [self initWithString:notification])) {
		self.target = target;
		self.action = action;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [self initWithString:nil])) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
	_notificationLabel.frame = CGRectMake(5.0f,0.0f,self.frame.size.width-10.0f,self.frame.size.height-3.0f);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[_notificationLabel release];
	self.target = nil;
    [super dealloc];
}

@end
