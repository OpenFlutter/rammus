package com.jarvanmo.rammus

import android.os.Bundle
import android.os.Handler
import android.os.PersistableBundle
import android.util.Log
import com.alibaba.sdk.android.push.AndroidPopupActivity
import org.json.JSONObject


class PopupPushActivity: AndroidPopupActivity() {
    private val handler = Handler()
    override fun onSysNoticeOpened(title: String, summary: String, extras: MutableMap<String, String>) {
        Log.d("PopupPushActivity", "onSysNoticeOpened, title: $title, content: $summary, extMap: $extras")
        startActivity(packageManager.getLaunchIntentForPackage(packageName))
        var jsonExtras = JSONObject()
        for (key in extras.keys){
            jsonExtras.putOpt(key, extras[key])
        }
        Log.d("PopupPushActivity", "onSysNoticeOpened extras: ${jsonExtras.toString()}")
        handler.postDelayed({RammusPushHandler.methodChannel?.invokeMethod("onNotificationOpened", mapOf(
                "title" to title,
                "summary" to summary,
                "extras" to jsonExtras.toString()
            ))
            finish()
        }, 1500)

    }


    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }


}