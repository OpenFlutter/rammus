import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cloud_push_message.dart';
import 'cloud_push_service_enums.dart';
import 'common_callback_result.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/rammus')
  ..setMethodCallHandler(_handler);

StreamController<CommonCallbackResult> _initCloudChannelResultController =
    StreamController.broadcast();

///注意可能被多次调用。
///Android SDK文档原话如下：
///如果设备成功注册，将回调callback.onSuccess()方法。
///但如果注册服务器连接失败，则调用callback.onFailed方法，并且自动进行重新注册，直到onSuccess为止。（重试规则会由网络切换等时间自动触发。）
///请在网络通畅的情况下进行相关的初始化调试，如果网络不通，或者App信息配置错误，在onFailed方法中，会有相应的错误码返回，可参考错误处理
Stream<CommonCallbackResult> get initCloudChannelResult =>
    _initCloudChannelResultController.stream;

///用于接收服务端推送的消息。
///消息不会弹窗，而是回调该方法。
StreamController<CloudPushMessage> _onMessageArrivedController =
    StreamController.broadcast();

Stream<CloudPushMessage> get onMessageArrived =>
    _onMessageArrivedController.stream;

///客户端接收到通知后，回调该方法。
///可获取到并处理通知相关的参数。
StreamController<OnNotification> _onNotificationController =
    StreamController.broadcast();

Stream<OnNotification> get onNotification => _onNotificationController.stream;

///打开通知时会回调该方法，通知打开上报由SDK自动完成。
StreamController<OnNotificationOpened> _onNotificationOpenedController =
    StreamController.broadcast();

Stream<OnNotificationOpened> get onNotificationOpened =>
    _onNotificationOpenedController.stream;

///删除通知时回调该方法，通知删除上报由SDK自动完成。
StreamController<String> _onNotificationRemovedController =
    StreamController.broadcast();

Stream<String> get onNotificationRemoved =>
    _onNotificationRemovedController.stream;

///打开无跳转逻辑(open=4)通知时回调该方法(v2.3.2及以上版本支持)，通知打开上报由SDK自动完成。
StreamController<OnNotificationClickedWithNoAction>
    _onNotificationClickedWithNoActionController = StreamController.broadcast();

Stream<OnNotificationClickedWithNoAction>
    get onNotificationClickedWithNoAction =>
        _onNotificationClickedWithNoActionController.stream;

///当用户创建自定义通知样式，并且设置推送应用内到达不创建通知弹窗时调用该回调，且此时不调用onNotification回调(v2.3.3及以上版本支持)
StreamController<OnNotificationReceivedInApp>
    _onNotificationReceivedInAppController = StreamController.broadcast();

Stream<OnNotificationReceivedInApp> get onNotificationReceivedInApp =>
    _onNotificationReceivedInAppController.stream;

///确保注册成功以后调用获取[deviceId]
Future<String?> get deviceId async {
  return _channel.invokeMethod("deviceId");
}

Future<CommonCallbackResult> get pushChannelStatus async {
  var result = await _channel.invokeMethod("checkPushChannelStatus");

  return CommonCallbackResult(
    isSuccessful: result["isSuccessful"],
    response: result["response"],
    errorCode: result["errorCode"],
    errorMessage: result["errorMessage"],
  );
}

/// 注册设备
/// 仅在 Android 设备生效，且在 Android 端若希望插件正常工作，必须执行一次本方法
/// 分离插件初始化与注册的过程，例如实现在用户同意了隐私政策后再进行远端注册，防止影响应用上架。
void register() {
  if (Platform.isAndroid) _channel.invokeMethod("register");
}

//  static Future<String> get platformVersion async {
//    final String version = await _channel.invokeMethod('getPlatformVersion');
//    return version;
//  }

///这个返回结果永远都是[true]，并不是SDK初始化结果
///初始化结果请监听[initCloudChannelResult]
///只能初始化ios
//Future<bool> initCloudChannel({String appKey, String appSecret}) async {
//  return await _channel.invokeMethod(
//      "initCloudChannel", {"appKey": appKey, "appSecret": appSecret});
//}

Future<CommonCallbackResult> turnOnPushChannel() async {
  var result = await _channel.invokeMethod("turnOnPushChannel");

  return CommonCallbackResult(
    isSuccessful: result["isSuccessful"],
    response: result["response"],
    errorCode: result["errorCode"],
    errorMessage: result["errorMessage"],
  );
}

Future<CommonCallbackResult> turnOffPushChannel() async {
  var result = await _channel.invokeMethod("turnOffPushChannel");
  return CommonCallbackResult(
    isSuccessful: result["isSuccessful"],
    response: result["response"],
    errorCode: result["errorCode"],
    errorMessage: result["errorMessage"],
  );
}

/// Android 文档
///将应用内账号和推送通道相关联，可以实现按账号的定点消息推送；
///设备只能绑定一个账号，同一账号可以绑定到多个设备；
///同一设备更换绑定账号时无需进行解绑，重新调用绑定账号接口即可生效；
///若业务场景需要先解绑后绑定，在解绑账号成功回调中进行绑定绑定操作，以此保证执行的顺序性；
///账户名设置支持64字节。
Future<CommonCallbackResult> bindAccount(String account) async {
  assert(account != null);

  var result = await _channel.invokeMethod("bindAccount", account);
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

Future<CommonCallbackResult> unbindAccount() async {
  var result = await _channel.invokeMethod("unbindAccount");
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android only
Future<CommonCallbackResult> bindPhoneNumber(String phoneNumber) async {
  var result = await _channel.invokeMethod("bindPhoneNumber", phoneNumber);
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android only

Future<CommonCallbackResult> unbindPhoneNumber() async {
  var result = await _channel.invokeMethod("unbindPhoneNumber");
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

//void bindTag(int target, String[] tags, String alias, CommonCallback callback);
///Android 文档
///绑定标签到指定目标；
///支持向设备、账号和别名绑定标签，绑定类型由参数target指定；
///绑定标签在10分钟内生效；
///App最多支持绑定1万个标签，单个标签最大支持128字符。
///target 目标类型，1：本设备； 2：本设备绑定账号； 3：别名
///target(V2.3.5及以上版本) 目标类型，CloudPushService.DEVICE_TARGET：本设备； CloudPushService.ACCOUNT_TARGET：本账号； CloudPushService.ALIAS_TARGET：别名
///tags 标签（数组输入）
///alias 别名（仅当target = 3时生效）
///callback 回调
Future<CommonCallbackResult> bindTag(
    {@required CloudPushServiceTarget? target,
    List<String>? tags,
    String? alias}) async {
  var result = await _channel.invokeMethod("bindTag", {
    "target": target!.index + 1,
    "tags": tags ?? <String>[],
    "alias": alias
  });

  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android 文档
///解绑指定目标标签；
///支持解绑设备、账号和别名标签，解绑类型由参数target指定；
///解绑标签在10分钟内生效；
///解绑标签只是解除设备和标签的绑定关系，不等同于删除标签，即该APP下标签仍然存在，系统目前不支持标签的删除。
///target 目标类型，1：本设备； 2：本设备绑定账号； 3：别名
///target(V2.3.5及以上版本) 目标类型，CloudPushService.DEVICE_TARGET：本设备； CloudPushService.ACCOUNT_TARGET：本账号； CloudPushService.ALIAS_TARGET：别名
///tags 标签（数组输入）
///alias 别名（仅当target = 3时生效）
///callback 回调
Future<CommonCallbackResult> unbindTag(
    {@required CloudPushServiceTarget? target,
    List<String>? tags,
    String? alias}) async {
  var result = await _channel.invokeMethod("unbindTag", {
    "target": target!.index + 1,
    "tags": tags ?? <String>[],
    "alias": alias
  });

  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android 文档
///查询目标绑定标签，当前仅支持查询设备标签；
///查询结果可从回调onSuccess(response)的response获取；
///标签绑定成功且生效（10分钟内）后即可查询。
Future<CommonCallbackResult> listTags(CloudPushServiceTarget target) async {
  var result = await _channel.invokeMethod("listTags", target.index + 1);
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android 文档
///添加别名
///设备添加别名；
///单个设备最多添加128个别名，且同一别名最多添加到128个设备；
///别名支持128字节。
Future<CommonCallbackResult> addAlias(String alias) async {
  var result = await _channel.invokeMethod("addAlias", alias);
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android 文档
///删除别名
///删除设备别名；
///支持删除指定别名和删除全部别名（alias = null || alias.length = 0）。
Future<CommonCallbackResult> removeAlias(String alias) async {
  var result = await _channel.invokeMethod("removeAlias", alias);
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

///Android 文档
///查询设备别名；
///查询结果可从回调onSuccess(response)的response中获取；
///从V3.0.9及以上版本开始，接口内部有5s短缓存，5s内多次调用只会请求服务端一次。
Future<CommonCallbackResult> listAliases() async {
  var result = await _channel.invokeMethod("listAliases");
  return CommonCallbackResult(
      isSuccessful: result["isSuccessful"],
      response: result["response"],
      errorCode: result["errorCode"],
      errorMessage: result["errorMessage"],
      iosError: result["iosError"]);
}

class NotificationChannel {
  const NotificationChannel(this.id, this.name, this.description,
      {this.importance = AndroidNotificationImportance.DEFAULT});
  final String id;
  final String name;
  final String description;
  final AndroidNotificationImportance importance;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "importance": importance.index + 1
    };
  }
}

///这个方法只对android有效
///最好调用这个方法以保证在Android 8以上推送通知好用。
///如果不调用这个方法，请确认你自己创建了NotificationChannel。
///为了更好的用户体验，一些参数请不要用传[null]。
///[id]一定要和后台推送时候设置的通知通道一样，否则Android8.0以上无法完成通知推送。
Future setupNotificationManager(List<NotificationChannel> channels) async {
  return _channel.invokeMethod(
      "setupNotificationManager", channels.map((e) => e.toJson()).toList());
}

///这个方法仅针对iOS
///设置推送通知显示方式
///    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
Future configureNotificationPresentationOption(
    {bool none: false,
    bool sound: true,
    bool alert: true,
    bool badge: true}) async {
  return _channel.invokeMethod("configureNotificationPresentationOption",
      {"none": none, "sound": sound, "alert": alert, "badge": badge});
}

Future badgeClean({int num: 0}) async {
  return _channel.invokeMethod("badgeClean", {"num": num});
}

///这个方法近针对ios
///清理图标上的角标
Future applicationBadgeNumberClean({int num: 0}) async {
   if (Platform.isIOS){
     return  _channel.invokeMethod("applicationBadgeNumberClean", {"num": num});
   }
}

Future<dynamic> _handler(MethodCall methodCall) {
  if ("initCloudChannelResult" == methodCall.method) {
    _initCloudChannelResultController.add(CommonCallbackResult(
      isSuccessful: methodCall.arguments["isSuccessful"],
      response: methodCall.arguments["response"],
      errorCode: methodCall.arguments["errorCode"],
      errorMessage: methodCall.arguments["errorMessage"],
    ));
  } else if ("onMessageArrived" == methodCall.method) {
    _onMessageArrivedController.add(CloudPushMessage(
      messageId: methodCall.arguments["messageId"],
      appId: methodCall.arguments["appId"],
      title: methodCall.arguments["title"],
      content: methodCall.arguments["content"],
      traceInfo: methodCall.arguments["traceInfo"],
    ));
  } else if ("onNotification" == methodCall.method) {
    _onNotificationController.add(OnNotification(methodCall.arguments["title"],
        methodCall.arguments["summary"], methodCall.arguments["extras"]));
  } else if ("onNotificationOpened" == methodCall.method) {
    _onNotificationOpenedController.add(OnNotificationOpened(
        methodCall.arguments["title"],
        methodCall.arguments["summary"],
        methodCall.arguments["extras"],
        methodCall.arguments["subtitle"],
        methodCall.arguments["badge"]));
  } else if ("onNotificationRemoved" == methodCall.method) {
    _onNotificationRemovedController.add(methodCall.arguments);
  } else if ("onNotificationClickedWithNoAction" == methodCall.method) {
    _onNotificationClickedWithNoActionController.add(
        OnNotificationClickedWithNoAction(methodCall.arguments["title"],
            methodCall.arguments["summary"], methodCall.arguments["extras"]));
  } else if ("onNotificationReceivedInApp" == methodCall.method) {
    _onNotificationReceivedInAppController.add(OnNotificationReceivedInApp(
        methodCall.arguments["title"],
        methodCall.arguments["summary"],
        methodCall.arguments["extras"],
        methodCall.arguments["openType"],
        methodCall.arguments["openActivity"],
        methodCall.arguments["openUrl"]));
  }

  return Future.value(true);
}

dispose() {
  _initCloudChannelResultController.close();
  _onMessageArrivedController.close();
  _onNotificationController.close();
  _onNotificationRemovedController.close();
  _onNotificationClickedWithNoActionController.close();
  _onNotificationReceivedInAppController.close();
}
