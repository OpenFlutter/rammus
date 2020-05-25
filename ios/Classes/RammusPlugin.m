#import "RammusPlugin.h"

NSString *_isSuccessful = @"isSuccessful";

@implementation RammusPlugin {
    // iOS 10通知中心
    UNUserNotificationCenter *_notificationCenter;
}


+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"com.jarvanmo/rammus"
                  binaryMessenger:[registrar messenger]];
    RammusPlugin *instance = [[RammusPlugin alloc] initWithRegistrar:registrar methodChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}


//__weak NSDictionary *_launchOptions;

FlutterMethodChannel *_methodChannel;
UNNotificationPresentationOptions _notificationPresentationOption = UNNotificationPresentationOptionNone;

- (instancetype)initWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar methodChannel:(FlutterMethodChannel *)flutterMethodChannel {
    self = [super init];
    if (self) {
        _methodChannel = flutterMethodChannel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"initCloudChannel" isEqualToString:call.method]) {

    } else if ([@"deviceId" isEqualToString:call.method]) {
        result([CloudPushSDK getDeviceId]);
    } else if ([@"bindAccount" isEqualToString:call.method]) {
        [self bindAccount:call result:result];
    } else if ([@"unbindAccount" isEqualToString:call.method]) {
        [self unbindAccount:call result:result];
    }  else if ([@"bindPhoneNumber" isEqualToString:call.method]) {
           [self bindPhoneNumber:call result:result];
       } else if ([@"unbindPhoneNumber" isEqualToString:call.method]) {
           [self unbindPhoneNumber:call result:result];
       } else if ([@"bindTag" isEqualToString:call.method]) {
        [self bindTag:call result:result];
    } else if ([@"unbindTag" isEqualToString:call.method]) {
        [self unbindTag:call result:result];
    } else if ([@"listTags" isEqualToString:call.method]) {
        [self listTags:call result:result];
    } else if ([@"addAlias" isEqualToString:call.method]) {
        [self addAlias:call result:result];
    } else if ([@"removeAlias" isEqualToString:call.method]) {
        [self removeAlias:call result:result];
    } else if ([@"listAliases" isEqualToString:call.method]) {
        [self listAliases:call result:result];
    }else if([@"configureNotificationPresentationOption" isEqualToString:call.method]){
        [self configureNotificationPresentationOption:call result:result];
    }else if([@"setupNotificationManager" isEqualToString:call.method]){
        result(@YES);
    }else {
        result(FlutterMethodNotImplemented);
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    _launchOptions = launchOptions;
    [self registerAPNS:application];
    [self initCloudPush];
    [self listenerOnChannelOpened];
    [self registerMessageReceive];
    [CloudPushSDK sendNotificationAck:launchOptions];

    return NO;
}


#pragma mark APNs Register

/**
 *	向APNs注册，获取deviceToken用于推送
 *
 *	@param 	application
 */

- (void)registerAPNS:(UIApplication *)application {
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 创建category，并注册到通知中心
//        [self createCustomNotificationCategory];
        _notificationCenter.delegate = self;
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    } else if (systemVersionNum >= 8.0) {
        // iOS 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:
                [UIUserNotificationSettings settingsForTypes:
                                (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                  categories:nil]];
        [application registerForRemoteNotifications];
#pragma clang diagnostic pop
    } else {
        // iOS < 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma clang diagnostic pop
    }
}

/**
 *  主动获取设备通知是否授权(iOS 10+)
 */
- (void)getNotificationSettingStatus {
    [_notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"User authed.");
        } else {
            NSLog(@"User denied.");
        }
    }];
}

/*
 *  APNs注册成功回调，将返回的deviceToken上传到CloudPush服务器
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Upload deviceToken to CloudPush server.");
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success, deviceToken: %@", [CloudPushSDK getApnsDeviceToken]);
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
}

/*
 *  APNs注册失败回调
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}


#pragma mark SDK Init

- (void)initCloudPush {
    // 正式上线建议关闭
    [CloudPushSDK turnOnDebug];

    // SDK初始化，无需输入配置信息
    // 请从控制台下载AliyunEmasServices-Info.plist配置文件，并正确拖入工程
    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
}

#pragma mark Channel Opened

/**
 *	注册推送通道打开监听
 */
- (void)listenerOnChannelOpened {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChannelOpened:)
                                                 name:@"CCPDidChannelConnectedSuccess"
                                               object:nil];

}


/**
*	推送通道打开回调
*
*	@param 	notification
*/
- (void)onChannelOpened:(NSNotification *)notification {
}


#pragma mark Receive Message

/**
 *	@brief	注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

/**
 *	处理到来推送消息
 *
 *	@param 	notification
 */
- (void)onMessageReceived:(NSNotification *)notification {

    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
//    NSLog(@"Receive message title: %@, content: %@.", title, body);


    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            if (tempVO.messageContent != nil) {
//                [self insertPushMessage:tempVO];
//            }

            [_methodChannel invokeMethod:@"onMessageArrived" arguments:@{
                    @"title": title,
                    @"content": body
            }];

        });
    } else {
        [_methodChannel invokeMethod:@"onMessageArrived" arguments:@{
                @"title": title,
                @"content": body
        }];
//        if (tempVO.messageContent != nil) {
//            [self insertPushMessage:tempVO];
//        }
    }
}


/**
 *  处理iOS 10通知(iOS 10+)
 */
- (void)handleiOS10Notification:(UNNotification *)notification fromFront:(BOOL)fromFront {

    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *extras = content.userInfo;
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    // NSString *extras = [userInfo valueForKey:@"Extras"];
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 同步角标数到服务端
    // [self syncBadgeNum:0];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:extras];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
    if (title != nil) {
        result[@"title"] = title;
    }
    if (body != nil) {
        result[@"summary"] = body;
    }
    if (extras != nil) {
        result[@"extras"] = [self convertToJsonData:extras];
    }
    if (subtitle != nil) {
        result[@"subtitle"] = subtitle;
    }
    if (badge != nil) {
        result[@"badge"] = @(badge);
    }
    if (request.identifier != nil) {
        result[@"messageId"] = request.identifier;
    }
    if (fromFront) {
        [_methodChannel invokeMethod:@"onNotification" arguments:result];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_methodChannel invokeMethod:@"onNotificationOpened" arguments:result];
        });
    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;

}

/**
 *  App处于前台时收到通知(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"Receive a notification in foregound.");
    // 处理iOS 10通知，并上报通知打开回执
    [self handleiOS10Notification:notification fromFront:YES];
    completionHandler(_notificationPresentationOption);
    // 通知不弹出
//    completionHandler(UNNotificationPresentationOptionNone);

    // 通知弹出，且带有声音、内容和角标
//    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}


/**
 *  触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
 */

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSString *userAction = response.actionIdentifier;
    // 点击通知打开
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
//        NSLog(@"User opened the notification.");
        // 处理iOS 10通知，并上报通知打开回执
        [self handleiOS10Notification:response.notification fromFront:NO];
    }
    // 通知dismiss，category创建时传入UNNotificationCategoryOptionCustomDismissAction才可以触发
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {

        [_methodChannel invokeMethod:@"onNotificationRemoved" arguments:response.notification.request.identifier];
//        NSLog(@"User dismissed the notification.");
    }
    NSString *customAction1 = @"action1";
    NSString *customAction2 = @"action2";
    // 点击用户自定义Action1
    if ([userAction isEqualToString:customAction1]) {
        NSLog(@"User custom action1.");
    }

    // 点击用户自定义Action2
    if ([userAction isEqualToString:customAction2]) {
        NSLog(@"User custom action2.");
    }
    completionHandler();
}


- (void)bindAccount:(FlutterMethodCall *)call result:(FlutterResult)result {
    [CloudPushSDK bindAccount:(NSString *) call.arguments withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}

- (void)unbindAccount:(FlutterMethodCall *)call result:(FlutterResult)result {
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];

}


- (void)bindPhoneNumber:(FlutterMethodCall *)call result:(FlutterResult)result {
    result(@{_isSuccessful: @YES});

//    [CloudPushSDK bindAccount:(NSString *) call.arguments withCallback:^(CloudPushCallbackResult *res) {
//        if (res.success) {
//            if (res.data == nil) {
//                result(@{_isSuccessful: @YES});
//            } else {
//                result(@{_isSuccessful: @YES, @"response": res.data});
//
//            };
//        } else {
//            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
//        }
//    }];
}

- (void)unbindPhoneNumber:(FlutterMethodCall *)call result:(FlutterResult)result {
       result(@{_isSuccessful: @YES});
//    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
//        if (res.success) {
//            if (res.data == nil) {
//                result(@{_isSuccessful: @YES});
//            } else {
//                result(@{_isSuccessful: @YES, @"response": res.data});
//
//            };
//        } else {
//            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
//        }
//    }];

}


- (void)bindTag:(FlutterMethodCall *)call result:(FlutterResult)result {

//    (title == (id) [NSNull null]) ? nil : title
    NSNumber *target = (call.arguments[@"target"] == (id) [NSNull null]) ? @1 : call.arguments[@"target"];
    NSString *alias = (call.arguments[@"alias"] == (id) [NSNull null]) ? nil : call.arguments[@"alias"];
    [CloudPushSDK bindTag:target.intValue withTags:call.arguments[@"tags"] withAlias:alias withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}

- (void)unbindTag:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *target = (call.arguments[@"target"] == (id) [NSNull null]) ? @1 : call.arguments[@"target"];
    NSString *alias = (call.arguments[@"alias"] == (id) [NSNull null]) ? nil : call.arguments[@"alias"];
    [CloudPushSDK unbindTag:target.intValue withTags:call.arguments[@"tags"] withAlias:alias withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}


- (void)listTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *target = (call.arguments == (id) [NSNull null]) ? @1 : call.arguments;
    [CloudPushSDK listTags:target.intValue withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}


- (void)addAlias:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *alias = (call.arguments == (id) [NSNull null]) ? nil : call.arguments;
    [CloudPushSDK addAlias:alias withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}


- (void)removeAlias:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *alias = (call.arguments == (id) [NSNull null]) ? nil : call.arguments;
    [CloudPushSDK removeAlias:alias withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}


- (void)listAliases:(FlutterMethodCall *)call result:(FlutterResult)result {

    [CloudPushSDK listAliases:^(CloudPushCallbackResult *res) {
        if (res.success) {
            if (res.data == nil) {
                result(@{_isSuccessful: @YES});
            } else {
                result(@{_isSuccessful: @YES, @"response": res.data});

            };
        } else {
            result(@{_isSuccessful: @NO, @"errorCode": @(res.error.code), @"errorMessage": res.error.domain, @"iosError": [NSString stringWithFormat:@"%@", res.error]});
        }
    }];
}


- (void)configureNotificationPresentationOption:(FlutterMethodCall *)call result:(FlutterResult)result {
//    {"none": none, "sound": sound, "alert": alert, "badge": badge});

    BOOL none = [call.arguments[@"none"] boolValue];
    if(none){
        _notificationPresentationOption = _notificationPresentationOption|UNNotificationPresentationOptionNone;
    }

    BOOL sound = [call.arguments[@"sound"] boolValue];
    if(sound){
        _notificationPresentationOption = _notificationPresentationOption |UNNotificationPresentationOptionSound;
    }

    BOOL alert = [call.arguments[@"alert"] boolValue];
    if(alert){
        _notificationPresentationOption = _notificationPresentationOption | UNNotificationPresentationOptionAlert;
    }

    BOOL badge = [call.arguments[@"badge"] boolValue];
    if(badge){
        _notificationPresentationOption = _notificationPresentationOption | UNNotificationPresentationOptionBadge;
    }

    result(@YES);

}

@end
