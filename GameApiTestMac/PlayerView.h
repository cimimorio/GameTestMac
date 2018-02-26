//
//  PlayerView.h
//  GameApiTestMac
//
//  Created by apple on 2018/2/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PlayerView : NSControl

@property (assign,nonatomic) BOOL isBad;
@property (assign,nonatomic) BOOL isAgree;
@property (assign,nonatomic) BOOL isSuccess;
@property (copy,nonatomic) NSString *name;

@property (assign) int state;//0 等待  1 选择玩家

@end
