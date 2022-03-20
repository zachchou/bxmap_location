package com.bxlocation.bxmap_location;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.tencent.map.geolocation.TencentLocationManager;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** BxmapLocationPlugin */
public class BxmapLocationPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private static final String CHANNEL_METHOD_LOCATION = "bxmap_location";
  private static final String CHANNEL_STREAM_LOCATION = "bxmap_location_stream";

  private Context mContext = null;

  public static EventChannel.EventSink mEventSink = null;

  private Map<String, BxMapLocationClientImpl> locationClientMap = new ConcurrentHashMap<String, BxMapLocationClientImpl>(8);

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String callMethod = call.method;
    switch (call.method) {
      case "setApiKey":
        setApiKey((Map) call.arguments);
        break;
      case "setLocationOption":
        setLocationOption((Map) call.arguments);
        break;
      case "startLocation":
        startLocation((Map) call.arguments);
        break;
      case "stopLocation":
        stopLocation((Map) call.arguments);
        break;
      case "destroy":
        destroy((Map) call.arguments);
        break;
      default:
        result.notImplemented();
        break;

    }
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    mEventSink = eventSink;
  }

  @Override
  public void onCancel(Object o) {
    for (Map.Entry<String, BxMapLocationClientImpl> entry : locationClientMap.entrySet()) {
      entry.getValue().stopLocation();
    }
  }

  /**
   * 开始定位
   */
  private void startLocation(Map argsMap) {
    BxMapLocationClientImpl locationClientImp = getLocationClientImp(argsMap);
    if (null != locationClientImp) {
      locationClientImp.startLocation();
    }
  }


  /**
   * 停止定位
   */
  private void stopLocation(Map argsMap) {
    BxMapLocationClientImpl locationClientImp = getLocationClientImp(argsMap);
    if (null != locationClientImp) {
      locationClientImp.stopLocation();
    }
  }

  /**
   * 销毁
   *
   * @param argsMap
   */
  private void destroy(Map argsMap) {
    BxMapLocationClientImpl locationClientImp = getLocationClientImp(argsMap);
    if (null != locationClientImp) {
      locationClientImp.destroy();

      locationClientMap.remove(getPluginKeyFromArgs(argsMap));
    }
  }

  /**
   * 设置apikey
   *
   * @param apiKeyMap
   */
  private void setApiKey(Map apiKeyMap) {
    if (null != apiKeyMap) {
      if (apiKeyMap.containsKey("android")
              && !TextUtils.isEmpty((String) apiKeyMap.get("android"))) {

      }
    }
  }

  /**
   * 设置定位参数
   *
   * @param argsMap
   */
  private void setLocationOption(Map argsMap) {
    BxMapLocationClientImpl locationClientImp = getLocationClientImp(argsMap);
    if (null != locationClientImp) {
//      locationClientImp.setLocationOption(argsMap);
    }
  }


  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    if (null == mContext) {
      mContext = binding.getApplicationContext();

      /**
       * 方法调用通道
       */
      final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_METHOD_LOCATION);
      channel.setMethodCallHandler(this);

      /**
       * 回调监听通道
       */
      final EventChannel eventChannel = new EventChannel(binding.getBinaryMessenger(), CHANNEL_STREAM_LOCATION);
      eventChannel.setStreamHandler(this);
    }

  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    for (Map.Entry<String, BxMapLocationClientImpl> entry : locationClientMap.entrySet()) {
      entry.getValue().destroy();
    }
  }

  private BxMapLocationClientImpl getLocationClientImp(Map argsMap) {
    if (null == locationClientMap) {
      locationClientMap = new ConcurrentHashMap<String, BxMapLocationClientImpl>(8);
    }

    String pluginKey = getPluginKeyFromArgs(argsMap);
    if (TextUtils.isEmpty(pluginKey)) {
      return null;
    }

    if (!locationClientMap.containsKey(pluginKey)) {
      BxMapLocationClientImpl locationClientImp = new BxMapLocationClientImpl(mContext, pluginKey, mEventSink);
      locationClientMap.put(pluginKey, locationClientImp);
    }
    return locationClientMap.get(pluginKey);
  }

  private String getPluginKeyFromArgs(Map argsMap) {
    String pluginKey = null;
    try {
      if (null != argsMap) {
        pluginKey = (String) argsMap.get("pluginKey");
      }
    } catch (Throwable e) {
      e.printStackTrace();
    }
    return pluginKey;
  }
}
