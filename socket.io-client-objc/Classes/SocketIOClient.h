//
//  SocketIOClient.h
//  SocketTesterARC
//
//  Created by zhangjinquan on 2019/4/16.
//  Copyright © 2019 beta_interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SocketAckEmitter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SocketIOClient : NSObject

- (instancetype)initWithSocketURL:(NSURL *)url config:(NSDictionary *)config;

- (void)connect;
- (void)disconnect;

- (void)on:(NSString *)event callback:(void (^)(NSArray *data, SocketAckEmitter *ack))callback;
- (void)off:(NSString *)event;

- (void)emit:(NSString *)event with:(NSArray *)items;

- (void)leaveNamespace;

@end

NS_ASSUME_NONNULL_END
