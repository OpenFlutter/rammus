package com.jarvanmo.rammus

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.util.Log
import com.alibaba.sdk.android.push.CommonCallback
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class RammusPlugin(private val registrar: Registrar, private val methodChannel: MethodChannel) : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.jarvanmo/rammus")
            RammusPushHandler.methodChannel = channel
            channel.setMethodCallHandler(RammusPlugin(registrar, channel))
        }
    }

    private val handler = Handler()

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "initCloudChannel" -> initCloudChannel(call, result)
            call.method == "deviceId" -> result.success(PushServiceFactory.getCloudPushService().deviceId)
            call.method == "turnOnPushChannel" -> turnOnPushChannel(result)
            call.method == "turnOffPushChannel" -> turnOffPushChannel(result)
            call.method == "checkPushChannelStatus" -> checkPushChannelStatus(result)
            call.method == "bindAccount" -> bindAccount(call, result)
            call.method == "unbindAccount" -> unbindAccount(result)
            call.method == "bindTag" -> bindTag(call, result)
            call.method == "unbindTag" -> unbindTag(call, result)
            call.method == "listTags" -> listTags(call, result)
            call.method == "addAlias" -> addAlias(call, result)
            call.method == "removeAlias" -> removeAlias(call, result)
            call.method == "listAliases" -> listAliases(result)
            call.method == "setupNotificationManager" -> setupNotificationManager(call, result)
            else -> result.notImplemented()
        }

    }


    private fun initCloudChannel(call: MethodCall, result: Result) {
        result.success(true)
//        val pushService = PushServiceFactory.getCloudPushService()
//        val appKey = call.argument<String?>("appKey")
//        val appSecret = call.argument<String?>("appSecret")
//
//        val initCloudChannelResult = "initCloudChannelResult"
//
//
//        pushService.setPushIntentService(RammusPushIntentService::class.java)
//
//        val callback = object : CommonCallback {
//            override fun onSuccess(response: String?) {
//                handler.post {
//                    methodChannel.invokeMethod(initCloudChannelResult, mapOf(
//                            "isSuccessful" to true,
//                            "response" to response
//                    ))
//                    RammusPushHandler.methodChannel = methodChannel
//                }
//
//                Log.e("TAG", "成功")
//
//            }
//
//            override fun onFailed(errorCode: String?, errorMessage: String?) {
//                handler.post {
//                    methodChannel.invokeMethod(initCloudChannelResult, mapOf(
//                            "isSuccessful" to false,
//                            "errorCode" to errorCode,
//                            "errorMessage" to errorMessage
//                    ))
//                }
//
//                Log.e("TAG", "失败")
//
//            }
//
//        }
//        if (appKey.isNullOrBlank() || appSecret.isNullOrBlank()) {
//
//            pushService.register(registrar.context().applicationContext, callback)
//
//        } else {
//
//            pushService.register(registrar.context().applicationContext, appKey, appSecret, callback)
//
//        }
//
//        result.success(true)
    }


    private fun turnOnPushChannel(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.turnOnPushChannel(object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }

    private fun turnOffPushChannel(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.turnOffPushChannel(object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }


    private fun checkPushChannelStatus(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.checkPushChannelStatus(object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }


    private fun bindAccount(call: MethodCall, result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.bindAccount(call.arguments as String?, object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }


    private fun unbindAccount(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.unbindAccount(object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }

    private fun bindTag(call: MethodCall, result: Result) {
//        target: Int, tags: Array<String>, alias: String, callback: CommonCallback
        val target = call.argument("target") ?: 1
        val tagsInArrayList = call.argument("tags") ?: arrayListOf<String>()
        val alias = call.argument<String?>("alias")

        val tags: Array<String> = tagsInArrayList.toArray() as Array<String>

        val pushService = PushServiceFactory.getCloudPushService()

        pushService.bindTag(target, tags, alias, object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }


    private fun unbindTag(call: MethodCall, result: Result) {
//        target: Int, tags: Array<String>, alias: String, callback: CommonCallback
        val target = call.argument("target") ?: 1
        val tagsInArrayList = call.argument("tags") ?: arrayListOf<String>()
        val alias = call.argument<String?>("alias")


        val tags: Array<String> = tagsInArrayList.toArray() as Array<String>

        val pushService = PushServiceFactory.getCloudPushService()

        pushService.unbindTag(target, tags, alias, object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }

    private fun listTags(call: MethodCall, result: Result) {
        val target = call.arguments as Int? ?: 1
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.listTags(target, object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }


    private fun addAlias(call: MethodCall, result: Result) {
        val alias = call.arguments as String?
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.addAlias(alias, object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }

    private fun removeAlias(call: MethodCall, result: Result) {
        val alias = call.arguments as String?
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.removeAlias(alias, object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }

    private fun listAliases(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.listAliases(object : CommonCallback {
            override fun onSuccess(response: String?) {
                result.success(mapOf(
                        "isSuccessful" to true,
                        "response" to response
                ))

            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
                result.success(mapOf(
                        "isSuccessful" to false,
                        "errorCode" to errorCode,
                        "errorMessage" to errorMessage
                ))
            }
        })
    }


    private fun setupNotificationManager(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mNotificationManager = registrar.context().getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            // 通知渠道的id
            val id = call.argument("id") ?: registrar.context().packageName
            // 用户可以看到的通知渠道的名字.
            val name = call.argument("name") ?: registrar.context().packageName
            // 用户可以看到的通知渠道的描述
            val description = call.argument("description") ?: registrar.context().packageName
            val importance = call.argument("importance") ?: NotificationManager.IMPORTANCE_DEFAULT
            val mChannel = NotificationChannel(id, name, importance)
            // 配置通知渠道的属性
            mChannel.description = description
            // 设置通知出现时的闪灯（如果 android 设备支持的话）
//            mChannel.enableLights(true)
//            mChannel.lightColor = Color.RED
            // 设置通知出现时的震动（如果 android 设备支持的话）
//            mChannel.enableVibration(true)
//            mChannel.vibrationPattern = longArrayOf(100, 200, 300, 400, 500, 400, 300, 200, 400)
            //最后在notificationmanager中创建该通知渠道
            mNotificationManager.createNotificationChannel(mChannel)

            result.success(true)
        }

    }
}
