package com.cleverpush.capacitor.plugins.myplugin;

import android.util.Log;

public class CleverPushCapacitor {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
