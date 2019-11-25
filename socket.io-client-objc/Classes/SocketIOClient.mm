//
//  SocketIOClient.m
//  SocketTesterARC
//
//  Created by zhangjinquan on 2019/4/16.
//  Copyright © 2019 beta_interactive. All rights reserved.
//

#import "SocketIOClient.h"
#include "sio_client.h"
//#import "SocketIOPacket.h"

using namespace std;
using namespace sio;

static message::ptr messageFromObject(id obj) {
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)obj;
        if (strcmp([num objCType], @encode(BOOL)) == 0) {
            return bool_message::create((bool)[num boolValue]);
        }
        else if (strcmp([num objCType], @encode(float)) == 0
                 || strcmp([num objCType], @encode(double)) == 0) {
            return double_message::create((bool)[num doubleValue]);
        }
        else {
            return int_message::create([num longLongValue]);
        }
        
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return string_message::create([(NSString *)obj UTF8String]);
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        message::ptr map = object_message::create();
        object_message *ptr = static_cast<object_message *>(map.get());
        [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull o, BOOL * _Nonnull stop) {
            ptr->insert([key UTF8String], messageFromObject(o));
        }];
        return map;
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        message::ptr arr = array_message::create();
        array_message *ptr = static_cast<array_message *>(arr.get());
        for (id o in (NSArray *)obj) {
            ptr->push(messageFromObject(o));
        }
        return arr;
    }
    else if ([obj isKindOfClass:[NSData class]]) {
        NSData *data = (NSData *)obj;
        return binary_message::create(std::shared_ptr<const std::string>::make_shared((char *)data.bytes, data.length));
    }
    else {
        return null_message::create();
    }
}

static id objectFromMessage(message::ptr const& msg) {
    switch (msg->get_flag()) {
        case message::flag_integer:
            return @(msg->get_int());
            
        case message::flag_double:
            return @(msg->get_double());
            
        case message::flag_string:
            return [NSString stringWithUTF8String:msg->get_string().c_str()];
            
        case message::flag_binary: {
            std::shared_ptr<const std::string> const bin = msg->get_binary();
            return [NSData dataWithBytes:bin->data() length:bin->size()];
        }
            
        case message::flag_array: {
            vector<message::ptr> vect = msg->get_vector();
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:vect.size()];
            for_each(vect.begin(), vect.end(), [&arr](message::ptr m){
                id obj = objectFromMessage(m);
                if (obj) {
                    [arr addObject:obj];
                }
            });
            return arr;
        }
            
        case message::flag_object: {
            map<std::string,message::ptr> map = msg->get_map();
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:map.size()];
            for_each(map.begin(), map.end(), [&dict](pair<std::string, message::ptr> pair){
                id obj = objectFromMessage(pair.second);
                if (obj) {
                    [dict setObject:obj forKey:[NSString stringWithUTF8String:pair.first.c_str()]];
                }
            });
            return dict;
        }
            
        case message::flag_boolean:
            return @(msg->get_bool());
            
        case message::flag_null:
            return [NSNull null];
            
        default:
            break;
    }
    return nil;
}

typedef enum {
    SocketIOClientStatus_NotConnected,
    SocketIOClientStatus_Disconnected,
    SocketIOClientStatus_Connecting,
    SocketIOClientStatus_Connected
} SocketIOClientStatus;

@interface SocketIOClient ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSDictionary *config;
@property (nonatomic, assign) SocketIOClientStatus status;
@property (nonatomic, copy) NSString *nsp;

@end

@implementation SocketIOClient
{
    sio::client *_io;
    NSMutableDictionary<NSString *, NSMutableArray *> *_handlersMap;
}

- (instancetype)initWithSocketURL:(NSURL *)url config:(NSDictionary *)config {
    self = [super init];
    if (self) {
        self.url = url;
        self.config = config;
        
        self.nsp = config[@"nsp"] ?: @"/";
        
        _io = new sio::client();
        _handlersMap = [NSMutableDictionary dictionary];
        [self setup];
    }
    return self;
}

- (void)setup {
    __weak typeof(self) weakSelf = self;
    _io->set_open_listener([weakSelf](){
        if (weakSelf) {
            weakSelf.status = SocketIOClientStatus_Connected;
            [weakSelf handleEvent:@"connect" data:@[] ack:nil];
        }
    });
    _io->set_close_listener([weakSelf](client::close_reason const& reason){
        if (weakSelf) {
            weakSelf.status = SocketIOClientStatus_Disconnected;
            [weakSelf handleEvent:@"disconnect"
                             data:@[reason == client::close_reason_drop ? @"Got Disconnect":@"Disconnect"]
                              ack:nil];
        }
    });
    _io->set_fail_listener([weakSelf](){
        if (weakSelf) {
            weakSelf.status = SocketIOClientStatus_Disconnected;
            [weakSelf handleEvent:@"error"
                             data:@[@"Connecting error"]
                              ack:nil];
        }
    });
    _io->socket()->on_error([weakSelf](message::ptr const& message){
        if (weakSelf) {
            id obj = objectFromMessage(message);
            if (obj) {
                [weakSelf handleEvent:@"error"
                                 data:@[obj]
                                  ack:nil];
            }
        }
    });
}

- (void)connect {
    self.status = SocketIOClientStatus_Connecting;
    _io->connect([[self.url absoluteString] UTF8String]);
}

- (void)disconnect {
    _io->close();
}

static void handle_event(CFTypeRef ctrl, string const& name, sio::message::ptr const& data, bool needACK,sio::message::list ackResp) {
    id obj = objectFromMessage(data);
    [(__bridge SocketIOClient *)ctrl handleEvent:[NSString stringWithUTF8String:name.c_str()]
                                            data:[NSArray arrayWithObjects:obj, nil]
                                             ack:nil];
}

- (void)handleEvent:(NSString *)event data:(NSArray *)data ack:(SocketAckEmitter *)ack {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            for (void (^handler)(NSArray *data, SocketAckEmitter *ack) in strongSelf->_handlersMap[event]) {
                handler(data, ack);
            }
        }
    });
}

- (void)on:(NSString *)event callback:(void (^)(NSArray *data, SocketAckEmitter *ack))callback {
    NSMutableArray *arr = _handlersMap[event];
    if (!arr) {
        arr = [NSMutableArray array];
        _handlersMap[event] = arr;
        
        using std::placeholders::_1;
        using std::placeholders::_2;
        using std::placeholders::_3;
        using std::placeholders::_4;
        
        socket::ptr socket = _io->socket();
        socket->on([event UTF8String], std::bind(&handle_event, (__bridge CFTypeRef)self, _1,_2,_3,_4));
    }
    [arr addObject:[callback copy]];
}

- (void)off:(NSString *)event {
    socket::ptr socket = _io->socket();
    socket->off([event UTF8String]);
    [_handlersMap removeObjectForKey:event];
}

- (void)emit:(NSString *)event with:(NSArray *)items {
    if (self.status != SocketIOClientStatus_Connected) {
        return;
    }
    message::list mlist;
    for (id obj in items) {
        mlist.push(messageFromObject(obj));
    }
    _io->socket()->emit([event UTF8String], mlist);
}

- (void)leaveNamespace {
    // 与swift版实现有差异，但可以暂时不支持
}

@end
