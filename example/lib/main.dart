import 'dart:io';

import 'package:bxmap_location/bxmap_location_option.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bxmap_location/bxmap_location.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, Object>? _locationResult;

  StreamSubscription<Map<String, Object>>? _locationListener;

  BxmapLocation _locationPlugin = BxmapLocation();

  @override
  void initState() {
    super.initState();
    requestPermission();

    _locationPlugin.setApiKey("EEABZ-OXQLJ-S3ZFV-FFLSZ-UMT5Q-26FI2", "EEABZ-OXQLJ-S3ZFV-FFLSZ-UMT5Q-26FI2");
    if (Platform.isIOS) {

    }

    _locationListener = _locationPlugin.onLocationChanged().listen((Map<String, Object> result) {
      setState(() {
        _locationResult = result;
      });
    });
  }

  void _setLocationOption() {
    BxmapLocationOption option = BxmapLocationOption();
    option.onceLocation = true;
    _locationPlugin.setLocationOption(option);
  }

  ///开始定位
  void _startLocation() {
    ///开始定位之前设置定位参数
    _setLocationOption();
    _locationPlugin.startLocation();
  }

  ///停止定位
  void _stopLocation() {
    _locationPlugin.stopLocation();
  }

  Container _createButtonContainer() {
    return new Container(
        alignment: Alignment.center,
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new ElevatedButton(
              onPressed: _startLocation,
              child: new Text('开始定位'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
            new Container(width: 20.0),
            new ElevatedButton(
              onPressed: _stopLocation,
              child: new Text('停止定位'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
            )
          ],
        ));
  }

  Widget _resultWidget(key, value) {
    return new Container(
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            alignment: Alignment.centerRight,
            width: 100.0,
            child: new Text('$key :'),
          ),
          new Container(width: 5.0),
          new Flexible(child: new Text('$value', softWrap: true)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    widgets.add(_createButtonContainer());

    if (_locationResult != null) {
      _locationResult?.forEach((key, value) {
        widgets.add(_resultWidget(key, value));
      });
    }

    return new MaterialApp(
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text('AMap Location plugin example app'),
          ),
          body: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widgets,
          ),
        ));
  }


  /// 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      print("定位权限申请通过");
    } else {
      print("定位权限申请不通过");
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }
}
