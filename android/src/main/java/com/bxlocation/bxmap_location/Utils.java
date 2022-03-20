package com.bxlocation.bxmap_location;

import android.text.TextUtils;

import com.tencent.map.geolocation.TencentLocation;

import java.text.SimpleDateFormat;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public class Utils {
    public static Map<String, Object> buildLocationResultMap(TencentLocation location, int errorCode, String errorInfo) {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("callBackTime", formatUTC(System.currentTimeMillis(), null));
        if (location != null) {
            if (errorCode == 0) {
                result.put("locationTime", formatUTC(location.getTime(), null));
                result.put("latitude", location.getLatitude());
                result.put("longitude", location.getLongitude());
                result.put("accuracy", location.getAccuracy());
                result.put("altitude", location.getAltitude());
                result.put("bearing", location.getBearing());
                result.put("speed", location.getSpeed());
                result.put("country", location.getNation());
                result.put("province", location.getProvince());
                result.put("city", location.getCity());
                result.put("district", location.getDistrict());
                result.put("street", location.getStreet());
                result.put("streetNumber", location.getStreetNo());
                result.put("cityCode", location.getCityCode());
                result.put("adCode", location.getadCode());
                result.put("address", location.getAddress());
//                result.put("description", location.getDescription());
            } else {
                result.put("errorCode", errorCode);
                result.put("errorInfo", errorInfo);
            }
        } else {
            result.put("errorCode", -1);
            result.put("errorInfo", "location is null");
        }
        return  result;
    }

    /**
     * 格式化时间
     *
     * @param time
     * @param strPattern
     * @return
     */
    public static String formatUTC(long time, String strPattern) {
        if (TextUtils.isEmpty(strPattern)) {
            strPattern = "yyyy-MM-dd HH:mm:ss";
        }
        SimpleDateFormat sdf = null;
        try {
            sdf = new SimpleDateFormat(strPattern, Locale.CHINA);
            sdf.applyPattern(strPattern);
        } catch (Throwable e) {
        }
        return sdf == null ? "NULL" : sdf.format(time);
    }
}
