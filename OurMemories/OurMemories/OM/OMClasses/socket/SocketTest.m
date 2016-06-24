//
//  SocketTest.m
//  OurMemories
//
//  Created by LanHai on 16/6/7.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import "SocketTest.h"

@implementation SocketTest


- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (NSMutableArray *)chatMsgs{
    if (!_chatMsgs) {
        _chatMsgs = [NSMutableArray array];
    }
    
    return _chatMsgs;
}

//实现输入输出溜的监听
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    NSLog(@"%@",[NSThread currentThread]);
    
//    NSStreamEventOpenCompleted = 1UL << 0,//输入输出流打开完成
//    NSStreamEventHasBytesAvailable = 1UL << 1,//有字节可读
//    NSStreamEventHasSpaceAvailable = 1UL << 2,//可以发放字节
//    NSStreamEventErrorOccurred = 1UL << 3,// 连接出现错误
//    NSStreamEventEndEncountered = 1UL << 4// 连接结束
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"输入输出流打开完成");
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog(@"有字节可读");
            [self readData];
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"可以发送字节");
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"连接出现错误");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"连接结束");
            //关闭输入输出流
            [_inputStream close];
            [_outputStream close];
            
            //从主运行循环移除
            [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
            break;
        default:
            break;
    }
    
}


- (void)connectToHost{
    NSString *host = @"127.0.0.1";
    int port = 1234;
    
    
    //定义C语言输入输出流
    CFReadStreamRef readSteam;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge  CFStringRef)host, port, &readSteam, &writeStream);
    
    //把C语言的输入输出流转化成oc对象
    _inputStream = (__bridge NSInputStream *)readSteam;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    
    //设置代理
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    //把输入输出添加到住运行循环
    //不添加主运行循环 代理有可能不工作
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    [_inputStream open];
    [_outputStream open];
    
    
}


- (void)loginBtnClick{
    
    //登录
    //发送用户名和密码

    //如果要登录，发送的数据格式为"iam:zhangsan"
    //如果发送聊天消息，数据格式为"msg:did you have dinner"
    
    //登录的指令
    NSString *loginStr = @"iam:zhangsan";
    
    NSData *data = [loginStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [_outputStream write:data.bytes maxLength:data.length];
    
    
    
    
    
}


//读取服务器返回的数据

- (void)readData{
    
    //建立一个缓冲区
    uint8_t buf[1024];
    
    
    //返回实际装的字节数
    
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    
    //把字节数组转化成字符串
    NSData *data = [NSData dataWithBytes:buf length:len];
    NSString *recStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [self reloadDataWithText:recStr];
    
    
}


//发送数据

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *text = textField.text;
    
    //聊天信息
    NSString *msgStr = [NSString stringWithFormat:@"msg:%@",text];
    
    //把str转化成NSData
    NSData *data = [msgStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //刷新表格
    
    [self reloadDataWithText:msgStr];
    
    //发送数据
    [_outputStream write:data.bytes maxLength:data.length];
    
    textField.text = nil;
    
    return YES;
    
    
    
}

- (void)reloadDataWithText:(NSString *)text{
    
    [self.chatMsgs addObject:text];
    
    [self.tabView reloadData];
    
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.chatMsgs.count - 1 inSection:0];
    
    [self.tabView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatMsgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    cell.textLabel.text = self.chatMsgs[indexPath.row];
    
    return cell;
  
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}


//监听键盘


- (void)kbFrmWillChange:(NSNotification *)noti{
    
    //获取窗口高度
    
    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
    
    //键盘结束的frm
    CGRect kbEndfrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //获取键盘结束的y值
    CGFloat kbEndY = kbEndfrm.origin.y;
    
    self.inputViewConstraint.constant = windowH - kbEndY;
    
    
    
    
}













@end
