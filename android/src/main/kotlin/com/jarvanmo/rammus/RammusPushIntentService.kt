package com.jarvanmo.rammus

import android.content.Context
import android.os.Handler
import com.alibaba.sdk.android.push.AliyunMessageIntentService
import com.alibaba.sdk.android.push.notification.CPushMessage

/***
 * Created by mo on 2019-06-25
 * 冷风如刀，以大地为砧板，视众生为鱼肉。
 * 万里飞雪，将穹苍作烘炉，熔万物为白银。
 **/
class RammusPushIntentService : AliyunMessageIntentService() {
    val handler = Handler()

    override fun onNotificationRemoved(context: Context, messageId: String?) {
        handler.post {
            RammusPushHandler.methodChannel?.invokeMethod("onNotificationRemoved", messageId)
        }
    }

    override fun onNotification(context: Context, title: String?, summary: String?, extras: MutableMap<String, String>?) {
//        Context context, String title, String summary, Map<String, String> extraMap)

        handler.post {

            RammusPushHandler.methodChannel?.invokeMethod("onNotification", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras
            ))
        }
    }

    override fun onMessage(context: Context, message: CPushMessage) {
        handler.post {
            RammusPushHandler.methodChannel?.invokeMethod("onMessageArrived", mapOf(
                    "appId" to message.appId,
                    "content" to message.content,
                    "messageId" to message.messageId,
                    "title" to message.title,
                    "traceInfo" to message.traceInfo
            ))
        }
    }

    override fun onNotificationOpened(p0: Context?, title: String?, summary: String?, extras: String?) {
        handler.post {

            RammusPushHandler.methodChannel?.invokeMethod("onNotificationOpened", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras
            ))
        }
    }

    override fun onNotificationReceivedInApp(p0: Context?, title: String?, summary: String?, extras: MutableMap<String, String>?, openType: Int, openActivity: String?, openUrl: String?) {
        handler.post {
            RammusPushHandler.methodChannel?.invokeMethod("onNotificationReceivedInApp", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras,
                    "openType" to openType,
                    "openActivity" to openActivity,
                    "openUrl" to openUrl
            ))
        }
    }

    override fun onNotificationClickedWithNoAction(context: Context, title: String?, summary: String?, extras: String?) {
        handler.post {

            RammusPushHandler.methodChannel?.invokeMethod("onNotificationClickedWithNoAction", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras
            ))
        }
    }
}