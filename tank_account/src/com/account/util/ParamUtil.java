package com.account.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class ParamUtil {

    public static String getAzStr(Map<String, String> param) {

        List<String> list = new ArrayList<>(param.keySet());
        Collections.sort(list);

        StringBuffer sb = new StringBuffer();

        for (String str : list) {
            sb.append(str);
            sb.append("=");
            sb.append(param.get(str));
            sb.append("&");
        }
        return sb.substring(0, sb.length() - 1);
    }


}
