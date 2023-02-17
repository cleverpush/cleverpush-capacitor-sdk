package com.cleverpush.plugins.capacitor;

import com.cleverpush.CleverPush;
import com.cleverpush.listener.NotificationOpenedListener;
import com.cleverpush.listener.NotificationReceivedListener;
import com.cleverpush.listener.SubscribedListener;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.google.firebase.FirebaseApp;

@CapacitorPlugin(name = "CleverPushPlugin")
public class CleverPushCapacitorPlugin extends Plugin {

    @PluginMethod
    public void initCleverPush(PluginCall call) {
        FirebaseApp.initializeApp(this.getActivity());
        CleverPush.getInstance(this.getActivity()).enableDevelopmentMode();
        CleverPush.getInstance(this.getActivity()).init("RHe2nXvQk9SZgdC4x",
                (NotificationReceivedListener) result -> {
                    JSObject obj = new JSObject();
                    if (result != null && !result.equals("null")) {
                        obj.put("success", true);
                        obj.put("data", result.getNotification().getRawPayload());
                    } else {
                        obj.put("success", false);
                        obj.put("error", "something went wrong");
                    }
                    notifyListeners("notificationReceivedListener", obj);
                },
                (NotificationOpenedListener) (result) -> {
                    JSObject obj = new JSObject();
                    if (result != null && !result.equals("null")) {
                        obj.put("success", true);
                        obj.put("data", result.getNotification().getRawPayload());
                    } else {
                        obj.put("success", false);
                        obj.put("error", "something went wrong");
                    }
                    notifyListeners("notificationOpenedListener", obj);
                },
                (SubscribedListener) result -> {
                    JSObject obj = new JSObject();
                    if (result != null && !result.equals("null")) {
                        obj.put("success", true);
                        obj.put("data", result);
                    } else {
                        obj.put("success", false);
                        obj.put("error", "something went wrong");
                    }
                    notifyListeners("subscribedListener", obj);
                }
        );

        CleverPush.getInstance(this.getActivity()).setAppBannerOpenedListener(action -> {
            JSObject obj = new JSObject();
            JSObject actionObj = new JSObject();
            if (action.getName() != null && !action.getName().isEmpty() && !action.getName().equals("null")) {

                if (action.getUrl() != null) {
                    actionObj.put("url", action.getUrl());
                }
                if (action.getUrlType() != null) {
                    actionObj.put("urlType", action.getUrlType());
                }
                if (action.getName() != null) {
                    actionObj.put("name", action.getName());
                }
                if (action.getType() != null) {
                    actionObj.put("type", action.getType());
                }
                if (action.getScreen() != null) {
                    actionObj.put("screen", action.getScreen());
                }
                if (action.getTags() != null) {
                    actionObj.put("tags", action.getTags());
                }
                if (action.getTags() != null) {
                    actionObj.put("topics", action.getTags());
                }
                if (action.getAttributeId() != null) {
                    actionObj.put("attributeId", action.getAttributeId());
                }
                if (action.getAttributeId() != null) {
                    actionObj.put("attributeValue", action.getAttributeId());
                }

                actionObj.put("dismiss", action.getDismiss());
                actionObj.put("openInWebview", action.isOpenInWebView());
                actionObj.put("openBySystem", action.isOpenBySystem());
                obj.put("success", true);
                obj.put("data", actionObj);
            } else {
                obj.put("success", false);
                obj.put("error", "something went wrong");
            }
            notifyListeners("appBannerOpenedListener", obj);
        });
    }

    @PluginMethod
    public void getSubscriptionId(PluginCall call) {
        JSObject obj = new JSObject();
        obj.put("value", CleverPush.getInstance(this.getActivity()).getSubscriptionId(this.getActivity()));
        call.resolve(obj);
    }

    @PluginMethod
    public void isSubscribed(PluginCall call) {
        boolean value = CleverPush.getInstance(this.getActivity()).isSubscribed();
        JSObject obj = new JSObject();
        obj.put("value", value);
        call.resolve(obj);
    }

    @PluginMethod
    public void unsubscribe() {
        CleverPush.getInstance(this.getActivity()).unsubscribe();
    }

    @PluginMethod
    public void subscribe(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).subscribe();
        String subscriptionId = CleverPush.getInstance(this.getActivity()).getSubscriptionId(this.getActivity());
        JSObject obj = new JSObject();
        if (subscriptionId != null && !subscriptionId.isEmpty() && !subscriptionId.equals("null")) {
            obj.put("success", true);
            obj.put("data", CleverPush.getInstance(this.getActivity()).getSubscriptionId(this.getActivity()));
        } else {
            obj.put("success", false);
            obj.put("error", "subscriptionId not found");
        }
        notifyListeners("subscribedListener", obj);
    }

    @PluginMethod
    public void showTopicsDialog(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).showTopicsDialog();
    }

    @PluginMethod
    public void enableDevelopmentMode(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).enableDevelopmentMode();
    }


}
