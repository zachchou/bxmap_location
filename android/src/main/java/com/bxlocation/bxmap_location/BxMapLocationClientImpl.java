package com.bxlocation.bxmap_location;

import android.content.Context;
import android.os.Looper;

import com.tencent.map.geolocation.TencentLocation;
import com.tencent.map.geolocation.TencentLocationListener;
import com.tencent.map.geolocation.TencentLocationManager;
import com.tencent.map.geolocation.TencentLocationManagerOptions;
import com.tencent.map.geolocation.TencentLocationRequest;

import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class BxMapLocationClientImpl implements TencentLocationListener{
    private Context mContext;

    private TencentLocationManagerOptions locationManagerOptions = new TencentLocationManagerOptions();
    private TencentLocationManager locationManager = null;
    private EventChannel.EventSink mEventSink;

    private String mPluginKey;

    public BxMapLocationClientImpl(Context context, String pluginKey, EventChannel.EventSink eventSink) {
        mContext = context;
        mPluginKey = pluginKey;
        mEventSink = eventSink;
        if (locationManager == null) {
            locationManager =  TencentLocationManager.getInstance(context);
        }
    }

    /**
     * 开始定位
     */
    public void startLocation() {
        if (locationManager == null) {
            locationManager = TencentLocationManager.getInstance(mContext);
        }

        if (locationManagerOptions != null) {

        }
//        TencentLocationRequest request = TencentLocationRequest.create();
//        int i = locationManager.requestLocationUpdates(request, this, Looper.getMainLooper());
         int i = locationManager.requestSingleFreshLocation(null, this, Looper.getMainLooper());
        System.out.println(i);
    }

    /**
     * 停止定位
     */
    public void  stopLocation() {
        if (locationManager != null) {
            locationManager.removeUpdates(this);
        }
    }

    public void destroy() {
        if(null != locationManager) {
            locationManager.removeUpdates(this);
            locationManager = null;
        }
    }

    @Override
    public void onLocationChanged(TencentLocation tencentLocation, int i, String s) {
        System.out.print(s);
        System.out.print(i);
        System.out.print(tencentLocation);
        if (mEventSink == null) {
            return;
        }

        Map<String, Object> result = Utils.buildLocationResultMap(tencentLocation, i, s);
        result.put("pluginKey", mPluginKey);
        mEventSink.success(result);
    }

    @Override
    public void onStatusUpdate(String s, int i, String s1) {
        System.out.print(s);
        System.out.print(i);
        System.out.print(s1);
    }
}
