//
//  ViewController.m
//  GameApiTestMac
//
//  Created by apple on 2018/2/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"
#import "PlayerView.h"

@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource,NSStreamDelegate>
{
	NSInputStream *in_put_stream;
	NSOutputStream *out_put_stream;
	NSRunLoop *loadDataRunloop;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet PlayerView *pv1;
@property (weak) IBOutlet PlayerView *pv2;
@property (weak) IBOutlet PlayerView *pv3;
@property (weak) IBOutlet PlayerView *pv4;
@property (weak) IBOutlet PlayerView *pv5;
@property (weak) IBOutlet PlayerView *pv6;
@property (weak) IBOutlet PlayerView *pv7;
@property (weak) IBOutlet PlayerView *pv8;

@property (strong) NSMutableArray *dataArr;

@property (strong) NSThread *socketThread;

@property (copy) NSString *userid;
@property (copy) NSString *roomid;

@property (strong) NSDictionary *mainData;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.dataArr = [[NSMutableArray alloc] init];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self startSocket];
}

- (IBAction)sendBtnAcion:(id)sender {
	if (self.textField.stringValue.length > 0 && out_put_stream != nil) {
		NSData *data = [self.textField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
		[out_put_stream write:data.bytes maxLength:data.length];
	}
}

- (IBAction)resetStreamBtnAction:(id)sender {
	[self stopSocket];
	[self.dataArr removeAllObjects];
	[self.tableView reloadData];
	[self startSocket];
}

- (IBAction)createGameBtnAction:(id)sender {
	NSString *playerId = @"cimimorio";
	NSString *api = [NSString stringWithFormat:@"%@%@",kCreateGameApi,playerId];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
	[request setHTTPMethod:@"GET"];
	NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *result = nil;
			NSDictionary *resultDic = nil;
			if (error) {
				NSLog(@"%@",error);
				result = [error description];
			}else{
				NSError *err;
				resultDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
			}
			if (resultDic == nil) {
				return;
			}
			if (![resultDic[@"code"] isEqual:@0]) {
				NSLog(@".......code:%@",resultDic[@"code"]);
				return;
			}
			NSLog(@"%@",resultDic[@"data"]);
			self.mainData = resultDic[@"data"];
			[self.dataArr addObject:[NSString stringWithFormat:@"%@",resultDic]];
			[self.tableView beginUpdates];
			NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.dataArr.count-1];
			[self.tableView insertRowsAtIndexes:set withAnimation:NSTableViewAnimationSlideDown];
			[self.tableView scrollRowToVisible:self.dataArr.count-1];
			[self.tableView endUpdates];
		});
		
	}];
	[task resume];
}

- (IBAction)addGameAction:(id)sender {
	
}

- (void)reloadData{
	if (!self.userid || !self.roomid) {
		NSLog(@"-----room:%@-----user:%@",self.roomid,self.userid);
		return;
	}
	NSString *api = [NSString stringWithFormat:@"%@%@/%@",kDataApi,self.userid,self.superclass];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
	[request setHTTPMethod:@"GET"];
	NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				NSLog(@"0-------%@",error);
				return;
			}
			NSError *err;
			NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
			if (err) {
				NSLog(@"1------%@",err);
				return;
			}
			if (![res[@"code"] isEqual:@0]) {
				NSLog(@"2------%@",res);
				return;
			}
			NSLog(@"3----%@",res[@"data"]);
		});
	}];
	[task resume];
}

- (void)startSocket{
	self.socketThread = [[NSThread alloc] initWithTarget:self selector:@selector(initSockect) object:nil];
	[self.socketThread start];
}

- (void)stopSocket{
	[out_put_stream close];
	[out_put_stream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[out_put_stream setDelegate:nil];
	[in_put_stream close];
	[in_put_stream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[in_put_stream setDelegate:nil];
	if (loadDataRunloop) {
		CFRunLoopStop([loadDataRunloop getCFRunLoop]);
		loadDataRunloop = nil;
	}
}

- (void)initSockect{
	NSString *host = @"127.0.0.1";
	int port = 8080;
	
	CFReadStreamRef read_s;
	CFWriteStreamRef write_s;
	CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &read_s, &write_s);
	//代理来通知连接建立是否成功，把C语言的输入输出流转化成OC对象，使用桥接转换。
	in_put_stream = (__bridge NSInputStream *)(read_s);
	out_put_stream = (__bridge NSOutputStream *)(write_s);
	in_put_stream.delegate = out_put_stream.delegate = self;
	// 把输入输出流添加到主运行循环,否则代理可能不工作
	[in_put_stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[out_put_stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	// 打开输入输出流
	[in_put_stream open];
	[out_put_stream open];
	loadDataRunloop = [NSRunLoop currentRunLoop];
	[loadDataRunloop run];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
	switch (eventCode) {
		case NSStreamEventNone:{
			NSLog(@"%s--stream event none",__FUNCTION__);
		}
			break;
		case NSStreamEventErrorOccurred:{
			NSLog(@"%s--stream event error occured--%@",__FUNCTION__,aStream.streamError);
		}
			break;
		case NSStreamEventOpenCompleted:{
			NSLog(@"%s--stream open complete",__FUNCTION__);
		}
			break;
		case NSStreamEventEndEncountered:{
			NSLog(@"%s--stream end encountered",__FUNCTION__);
			NSLog(@"Error:%ld:%@",[[aStream streamError] code], [[aStream streamError] localizedDescription]);
			
		}
			break;
		case NSStreamEventHasBytesAvailable:{
			NSLog(@"%s--stream even has bytes avilable",__FUNCTION__);
			if (aStream == in_put_stream) {
				dispatch_async(dispatch_get_main_queue(), ^{
					NSMutableData *input = [[NSMutableData alloc] init];
					uint8_t buffer[1024];
					long len;
					while([in_put_stream hasBytesAvailable])
					{
						len = [in_put_stream read:buffer maxLength:sizeof(buffer)];
						if (len > 0)
						{
							[input appendBytes:buffer length:len];
						}
					}
					NSString *resultstring = [[NSString alloc] initWithData:input encoding:NSUTF8StringEncoding];
					if ([resultstring containsString:@"ping"]) {
						return;
					}
					NSLog(@"接收:%@",resultstring);
					if ([resultstring containsString:@"reloaddata"]) {
						[self reloadData];
					}
					
					[self.dataArr addObject:resultstring];
					[self.tableView beginUpdates];
					NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.dataArr.count-1];
					[self.tableView insertRowsAtIndexes:set withAnimation:NSTableViewAnimationSlideDown];
					[self.tableView scrollRowToVisible:self.dataArr.count-1];
					[self.tableView endUpdates];
					//
				});
			}
		}
			break;
		case NSStreamEventHasSpaceAvailable:{
			NSLog(@"%s--stream even has space available",__FUNCTION__);
			//			if (aStream == _output_s) {
			//				//输出
			//				UInt8 buff[] = "Hello Server!";
			//				[_output_s write:buff maxLength: strlen((const char*)buff)+1];
			//				//必须关闭输出流否则，服务器端一直读取不会停止，
			//				[_output_s close];
			//			}
		}
			break;
		default:
			break;
	}
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
	return self.dataArr.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
	NSTableCellView *cell = [tableView makeViewWithIdentifier:@"Cell" owner:nil];
	NSString *msg = [self.dataArr objectAtIndex:row];
	[cell.textField setStringValue:msg];
	return cell;
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}


@end
