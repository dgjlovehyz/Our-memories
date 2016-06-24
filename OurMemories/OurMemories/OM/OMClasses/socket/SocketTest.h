//
//  SocketTest.h
//  OurMemories
//
//  Created by LanHai on 16/6/7.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocketTest : UIViewController <NSStreamDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
}
@property (nonatomic, strong)NSLayoutConstraint *inputViewConstraint;

@property (nonatomic, strong)UITableView *tabView;
@property (nonatomic, strong)NSMutableArray *chatMsgs;

@end
