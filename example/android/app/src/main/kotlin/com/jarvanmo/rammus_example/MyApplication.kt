package com.jarvanmo.rammus_example
import android.content.pm.PackageManager
import android.util.Log
import com.alibaba.sdk.android.push.CommonCallback
import com.alibaba.sdk.android.push.huawei.HuaWeiRegister
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory
import com.alibaba.sdk.android.push.register.*
import com.jarvanmo.rammus.RammusPlugin
import com.jarvanmo.rammus.RammusPushIntentService
import io.flutter.app.FlutterApplication
/***
 * Created by mo on 2019-06-25
 * 冷风如刀，以大地为砧板，视众生为鱼肉。
 * 万里飞雪，将穹苍作烘炉，熔万物为白银。
 **/
class MyApplication:FlutterApplication() {
    val TAG = "MyApplication"
    override fun onCreate() {
        super.onCreate()
        val callback = object : CommonCallback {
            override fun onSuccess(response: String?) {
                Log.e("TAG","success $response")
            }

            override fun onFailed(errorCode: String?, errorMessage: String?) {
            Log.e("TAG","error $errorMessage")
            }
        }
        RammusPlugin.initPushService(this, callback)
        /*PushServiceFactory.init(applicationContext)
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.register(applicationContext, callback)
        pushService.setPushIntentService(RammusPushIntentService::class.java)
        val appInfo = packageManager
                .getApplicationInfo(packageName, PackageManager.GET_META_DATA)
        val xiaomiAppId = appInfo.metaData.getString("com.xiaomi.push.client.app_id")
        val xiaomiAppKey = appInfo.metaData.getString("com.xiaomi.push.client.app_key")
        if ((xiaomiAppId != null && xiaomiAppId.isNotBlank())
                && (xiaomiAppKey != null && xiaomiAppKey.isNotBlank())){
            Log.d(TAG, "正在注册小米推送服务...")
            MiPushRegister.register(applicationContext, xiaomiAppId, xiaomiAppKey)
        }
        val huaweiAppId = appInfo.metaData.getString("com.huawei.hms.client.appid")
        if (huaweiAppId != null && huaweiAppId.toString().isNotBlank()){
            Log.d(TAG, "正在注册华为推送服务...")
            HuaWeiRegister.register(this)
        }
        val oppoAppKey = appInfo.metaData.getString("com.oppo.push.client.app_key")
        val oppoAppSecret = appInfo.metaData.getString("com.oppo.push.client.app_secret")
        if ((oppoAppKey != null && oppoAppKey.isNotBlank())
                && (oppoAppSecret != null && oppoAppSecret.isNotBlank())){
            Log.d(TAG, "正在注册Oppo推送服务...")
            OppoRegister.register(applicationContext, oppoAppKey, oppoAppSecret)
        }
        val meizuAppId = appInfo.metaData.getString("com.meizu.push.client.app_id")
        val meizuAppKey = appInfo.metaData.getString("com.meizu.push.client.app_key")
        if ((meizuAppId != null && meizuAppId.isNotBlank())
                && (meizuAppKey != null && meizuAppKey.isNotBlank())){
            Log.d(TAG, "正在注册魅族推送服务...")
            MeizuRegister.register(applicationContext, meizuAppId, meizuAppKey)
        }
        val vivoAppId = appInfo.metaData.getString("com.vivo.push.app_id")
        val vivoApiKey = appInfo.metaData.getString("com.vivo.push.api_key")
        if ((vivoAppId != null && vivoAppId.isNotBlank())
                && (vivoApiKey != null && vivoApiKey.isNotBlank())){
            Log.d(TAG, "正在注册Vivo推送服务...")
            VivoRegister.register(applicationContext)
        }
        val gcmSendId = appInfo.metaData.getString("com.gcm.push.send_id")
        val gcmApplicationId = appInfo.metaData.getString("com.gcm.push.app_id")
        if ((gcmSendId != null && gcmSendId.isNotBlank())
                && (gcmApplicationId != null && gcmApplicationId.isNotBlank())){
            Log.d(TAG, "正在注册Gcm推送服务...")
            GcmRegister.register(applicationContext, gcmSendId, gcmApplicationId)
        }*/
    }
}