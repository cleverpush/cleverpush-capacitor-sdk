package com.cleverpush.plugins.capacitor;

public class CleverPushPlugin {

    public String getSubscriptionId(String value) {
        System.out.println(value);
        return value;
    }

    public boolean isSubscribed(boolean value) {
        System.out.println(value);
        return value;
    }
    public void unsubscribe () {}
    public void subscribe () {}
    public void enableDevelopmentMode() {}

    public void initCleverPush() {

    }
    public void showTopicsDialog() {}

}
