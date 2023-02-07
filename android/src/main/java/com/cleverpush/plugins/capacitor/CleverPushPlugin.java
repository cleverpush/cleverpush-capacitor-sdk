package com.cleverpush.plugins.capacitor;

import android.util.Log;

public class CleverPushPlugin {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
