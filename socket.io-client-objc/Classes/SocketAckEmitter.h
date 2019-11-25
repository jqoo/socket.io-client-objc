//
//  SocketAckEmitter.h
//  SocketTesterARC
//
//  Created by zhangjinquan on 2019/4/16.
//  Copyright © 2019 beta_interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SocketIOClient;

@interface SocketAckEmitter : NSObject

@property (nonatomic, readonly) SocketIOClient *socket;
@property (nonatomic, readonly) int ackNum;

- (instancetype)initWithSocket:(SocketIOClient *)socket ackNum:(int)ackNum;

- (BOOL)expected;

@end

NS_ASSUME_NONNULL_END
