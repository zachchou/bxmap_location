
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:bxmap_location/bxmap_location_option.dart';

class BxmapLocation {
  static const String _CHANNEL_METHOD_LOCATION = 'bxmap_location';
  static const String _CHANNEL_STREAM_LOCATION = 'bxmap_location_stream';

  static const MethodChannel _methodChannel = const MethodChannel(_CHANNEL_METHOD_LOCATION);
  static const EventChannel _eventChannel = const EventChannel(_CHANNEL_STREAM_LOCATION);

  static Stream<Map<String, Object>> _onLocationChanged = _eventChannel
      .receiveBroadcastStream()
      .asBroadcastStream()
      .map<Map<String, Object>>((element) => element.cast<String, Object>());

  StreamController<Map<String, Object>>? _receiveStream;
  StreamSubscription<Map<String, Object>>? _subscription;
  String? _pluginKey;

  //适配iOS14定位新特性 ，只有iOS平台有效
  Future<BXMapAccuracyAuthorization> getSystemAccuracyAuthorization()  async {
    int result = -1;
    if (Platform.isIOS) {
      result = await _methodChannel.invokeMethod("getSystemAccuracyAuthorization", {'pluginKey': _pluginKey});
      if (result == 0) {
        return BXMapAccuracyAuthorization.BXMapAccuracyAuthorizationFullAccuracy;
      } else if (result == 1) {
        return BXMapAccuracyAuthorization.BXMapAccuracyAuthorizationReducedAccuracy;
      }
    }
    return BXMapAccuracyAuthorization.BXMapAccuracyAuthorizationInvalid;
  }

  //初始化
  BxmapLocation() {
    _pluginKey = DateTime.now().millisecondsSinceEpoch.toString();
  }

  //设置ApiKey
  void setApiKey(String androidKey, String iosKey) {
    print("key: $androidKey---$iosKey");
    _methodChannel
        .invokeMethod('setApiKey', {'android': androidKey, 'ios': iosKey, 'pluginKey': _pluginKey});
  }

  //设置定位参数
  void setLocationOption(BxmapLocationOption locationOption) {
    Map option = locationOption.getOptionsMap();
    option['pluginKey'] = _pluginKey;
    _methodChannel.invokeMethod('setLocationOption', option);
  }

  //开始定位
  void startLocation() {
    _methodChannel.invokeMethod('startLocation', {'pluginKey': _pluginKey});
    return;
  }

  //停止定位
  void stopLocation() {
    _methodChannel.invokeMethod('stopLocation', {'pluginKey': _pluginKey});
    return;
  }

  //销毁定位
  void destroy() {
    _methodChannel.invokeListMethod('destroy', {'pluginKey': _pluginKey});
    if (_subscription != null) {
      _receiveStream?.close();
      _subscription?.cancel();
      _receiveStream = null;
      _subscription = null;
    }
  }

  //定位结果回调
  Stream<Map<String, Object>> onLocationChanged() {
    if (_receiveStream == null) {
      _receiveStream = StreamController();
      _subscription = _onLocationChanged.listen((Map<String, Object> event) {
        if (event['pluginKey'] == _pluginKey) {
          Map<String, Object> newEvent = Map<String, Object>.of(event);
          newEvent.remove('pluginKey');
          _receiveStream?.add(newEvent);
        }
      });
    }
    return _receiveStream!.stream;
  }
}
