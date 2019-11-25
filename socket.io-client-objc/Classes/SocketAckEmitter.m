//
//  SocketAckEmitter.m
//  SocketTesterARC
//
//  Created by zhangjinquan on 2019/4/16.
//  Copyright © 2019 beta_interactive. All rights reserved.
//

#import "SocketAckEmitter.h"

@implementation SocketAckEmitter

- (instancetype)initWithSocket:(SocketIOClient *)socket ackNum:(int)ackNum {
    self = [super init];
    if (self) {
        _socket = socket;
        _ackNum = ackNum;
    }
    return self;
}

- (BOOL)expected {
    return _ackNum != -1;
}

@end
