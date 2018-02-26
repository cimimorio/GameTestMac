//
//  PlayerView.m
//  GameApiTestMac
//
//  Created by apple on 2018/2/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
	NSAttributedString *nameTitle = [[NSAttributedString alloc] initWithString:@"name:"];
	[nameTitle drawInRect:NSMakeRect(0, 0, [nameTitle size].width, [nameTitle size].height)];
	
	if (self.name) {
		NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:self.name];
		[nameStr drawInRect:NSMakeRect([nameTitle size].width + 2, 0, [nameStr size].width, [nameStr size].height)];
	}
	
	NSAttributedString *isAgreeTitle = [[NSAttributedString alloc] initWithString:@"isAgree:"];
	[isAgreeTitle drawInRect:NSMakeRect(0, [nameTitle size].height + 5, [isAgreeTitle size].width, [isAgreeTitle size].height)];
	
	NSAttributedString *isAgreeString = [[NSAttributedString alloc] initWithString:@"同意"];
	if (!self.isAgree) {
		isAgreeString = [[NSAttributedString alloc] initWithString:@"不同意"];
	}
	[isAgreeString drawInRect:NSMakeRect([isAgreeTitle size].width + 5, [nameTitle size].height + 5, [isAgreeString size].width, [isAgreeString size].height)];
	
	NSAttributedString *isSuccessTitle = [[NSAttributedString alloc] initWithString:@"isSuccess:"];
	[isSuccessTitle drawInRect:NSMakeRect(0, [nameTitle size].height + 5 + [isAgreeTitle size].height + 5, [isSuccessTitle size].width, [isSuccessTitle size].height)];
	NSAttributedString *isSuccessStr = [[NSAttributedString alloc] initWithString:@"成功"];
	if (!self.isSuccess) {
		isSuccessStr = [[NSAttributedString alloc] initWithString:@"失败"];
	}
	[isSuccessStr drawInRect:NSMakeRect([isSuccessTitle size].width + 2, [nameTitle size].height + 5 + [isAgreeTitle size].height + 5, [isSuccessStr size].width, [isSuccessStr size].height)];
}

- (void)setName:(NSString *)name{
	_name = name;
	[self needsDisplay];
}

- (void)setIsAgree:(BOOL)isAgree{
	if (_isAgree != isAgree) {
		_isAgree = isAgree;
		[self needsDisplay];
	}
}

- (void)setIsSuccess:(BOOL)isSuccess{
	if (_isSuccess != isSuccess) {
		_isSuccess = isSuccess;
		[self needsDisplay];
	}
}

- (void)mouseUp:(NSEvent *)event{
	[super mouseUp:event];
	if (self.state == 1 && self.target != nil && [self.target respondsToSelector:self.action]) {
		[self.target performSelector:self.action withObject:self afterDelay:0];
	}
}

@end
