package com.jarvanmo.rammus_example

import com.jarvanmo.rammus.RammusPlugin
import io.flutter.app.FlutterApplication
/***
 * Created by mo on 2019-06-25
 * 冷风如刀，以大地为砧板，视众生为鱼肉。
 * 万里飞雪，将穹苍作烘炉，熔万物为白银。
 **/
class MyApplication:FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        RammusPlugin.initPushService(this)
    }
}