package com.jarvanmo.rammus

import android.content.Context
import android.os.Handler
import android.util.Log
import com.alibaba.sdk.android.push.AliyunMessageIntentService
import com.alibaba.sdk.android.push.notification.CPushMessage

/***
 * Created by mo on 2019-06-25
 * 冷风如刀，以大地为砧板，视众生为鱼肉。
 * 万里飞雪，将穹苍作烘炉，熔万物为白银。
 **/

class RammusPushIntentService : AliyunMessageIntentService() {
    private val handler = Handler()

    override fun onNotificationRemoved(context: Context, messageId: String?) {
        Log.d("RammusPushIntentService","onNotificationRemoved messageId is $messageId")

        handler.postDelayed( {
            RammusPushHandler.methodChannel?.invokeMethod("onNotificationRemoved", messageId)
        },1500)
    }

    override fun onNotification(context: Context, title: String?, summary: String?, extras: MutableMap<String, String>?) {
        Log.d("RammusPushIntentService","onNotification title is $title, summary is $summary, extras: $extras")
        handler.postDelayed({

            RammusPushHandler.methodChannel?.invokeMethod("onNotification", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras
            ))
        },1500)
    }

    override fun onMessage(context: Context, message: CPushMessage) {
        Log.d("RammusPushIntentService","onMessage title is ${message.title}, messageId is ${message.messageId}, content is ${message.content}")
        handler.postDelayed( {
            RammusPushHandler.methodChannel?.invokeMethod("onMessageArrived", mapOf(
                    "appId" to message.appId,
                    "content" to message.content,
                    "messageId" to message.messageId,
                    "title" to message.title,
                    "traceInfo" to message.traceInfo
            ))
        },1500)
    }

    override fun onNotificationOpened(p0: Context?, title: String?, summary: String?, extras: String?) {

        Log.d("RammusPushIntentService","onNotificationOpened title is $title, summary is $summary, extras: $extras")
        handler.postDelayed({
            RammusPushHandler.methodChannel?.invokeMethod("onNotificationOpened", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras
            ))
        },1500)
    }

    override fun onNotificationReceivedInApp(p0: Context?, title: String?, summary: String?, extras: MutableMap<String, String>?, openType: Int, openActivity: String?, openUrl: String?) {
        Log.d("RammusPushIntentService","onNotificationReceivedInApp title is $title, summary is $summary, extras: $extras")
        handler.postDelayed( {
            RammusPushHandler.methodChannel?.invokeMethod("onNotificationReceivedInApp", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras,
                    "openType" to openType,
                    "openActivity" to openActivity,
                    "openUrl" to openUrl
            ))
        },1500)
    }

    override fun onNotificationClickedWithNoAction(context: Context, title: String?, summary: String?, extras: String?) {
        Log.d("RammusPushIntentService","onNotificationClickedWithNoAction title is $title, summary is $summary, extras: $extras")
        handler.postDelayed(  {
            RammusPushHandler.methodChannel?.invokeMethod("onNotificationClickedWithNoAction", mapOf(
                    "title" to title,
                    "summary" to summary,
                    "extras" to extras
            ))
        }, 1500)
    }
}