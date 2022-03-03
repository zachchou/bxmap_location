//定位参数
class BxmapLocationOption {
  //是否需要地址信息， 默认true
  bool needAdress = true;

  //是否单次定位，默认false
  bool onceLocation = false;

  BxmapLocationOption({
    this.needAdress = true,
    this.onceLocation = false,
  });

  ///获取设置的定位参数对应的Map
  Map getOptionsMap() {
    return {
      "onceLocation": onceLocation,
    };
  }
}



///iOS 14中期望的定位精度,只有在iOS 14的设备上才能生效
enum BXMapLocationAccuracyAuthorizationMode {
  ///精确和模糊定位
  FullAndReduceAccuracy,

  ///精确定位
  FullAccuracy,

  ///模糊定位
  ReduceAccuracy
}

///iOS 14中系统的定位类型信息
enum BXMapAccuracyAuthorization {
  ///系统的精确定位类型
  BXMapAccuracyAuthorizationFullAccuracy,

  ///系统的模糊定位类型
  BXMapAccuracyAuthorizationReducedAccuracy,

  ///未知类型
  BXMapAccuracyAuthorizationInvalid
}
