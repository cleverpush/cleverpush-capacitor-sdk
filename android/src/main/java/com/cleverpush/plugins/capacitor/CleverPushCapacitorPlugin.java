package com.cleverpush.plugins.capacitor;

import android.os.Build;
import android.util.Log;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import com.cleverpush.ChannelTopic;
import com.cleverpush.CleverPush;
import com.cleverpush.CustomAttribute;
import com.cleverpush.Notification;
import com.cleverpush.NotificationOpenedResult;
import com.cleverpush.listener.NotificationOpenedListener;
import com.cleverpush.listener.NotificationReceivedCallbackListener;
import com.cleverpush.listener.SubscribedCallbackListener;
import com.cleverpush.listener.SubscribedListener;
import com.getcapacitor.Bridge;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginHandle;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.google.gson.Gson;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

@CapacitorPlugin(name = "CleverPush")
public class CleverPushCapacitorPlugin extends Plugin implements LifecycleObserver {
    private JSObject coldStartOpenObject = null;
    private boolean showNotificationsInForeground = true;
    private boolean isAppInForeground = false;

    public boolean isAppOpen() {
        return isAppInForeground;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    public void onStart() {
        isAppInForeground = true;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    public void onStop() {
        isAppInForeground = false;
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy() {
        isAppInForeground = false;
    }

    @Override
    public void load() {
        this.getActivity().getLifecycle().addObserver(this);
    }

    private JSObject getNotificationJSObject(JSObject notification) {
        String createdAtString = notification.getString("createdAt");
        if (createdAtString != null) {
            Date createdAtDate = null;
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    createdAtDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX", Locale.US).parse(createdAtString);
                } else {
                    createdAtDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).parse(createdAtString);
                }
            } catch (Exception ex) {
                System.out.println(ex.getLocalizedMessage());
            }
            try {
                if (createdAtDate != null) {
                    SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US);
                    outputFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
                    String newCreatedAtString = outputFormat.format(createdAtDate);
                    notification.put("createdAt", newCreatedAtString);
                }
            } catch (Exception ex) {
                System.out.println(ex.getLocalizedMessage());
            }
        }
        return notification;
    }

    @PluginMethod
    public void init(PluginCall call) {

        try {
            Bridge bridge = this.bridge;
            if (bridge != null) {
                PluginHandle pluginHandle = bridge.getPlugin("CleverPush");
                if (pluginHandle == null) {
                    bridge.registerPlugin(CleverPushCapacitorPlugin.class);
                }
            }
        } catch (Exception e) {
            System.out.println(e.getLocalizedMessage());
        }

        NotificationReceivedCallbackListener receivedListener = new NotificationReceivedCallbackListener() {
            @Override
            public boolean notificationReceivedCallback(NotificationOpenedResult result) {
                boolean appIsOpen = isAppOpen();
               
                if (appIsOpen) {
                    try {
                        Gson gson = new Gson();
                        JSObject obj = new JSObject();
                        try {
                            obj.put("notification", getNotificationJSObject(new JSObject(gson.toJson(result.getNotification()))));
                            obj.put("subscription", new JSObject(gson.toJson(result.getSubscription())));
                            notifyListeners("notificationReceived", obj);
                        } catch (Exception ex) {
                            System.out.println(ex.getMessage());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Log.e("CleverPush", "Encountered an error attempting to convert CPNotification object to map: " + e.getMessage());
                    }
                }

                if (showNotificationsInForeground) {
                    return true;
                }

                return !appIsOpen;
            }
        };

        CleverPush.getInstance(this.getActivity()).init(call.getString("channelId"),
                receivedListener ,
                (NotificationOpenedListener) result -> {
                    Gson gson = new Gson();
                    JSObject obj = new JSObject();
                    try {
                        obj.put("notification", this.getNotificationJSObject(new JSObject(gson.toJson(result.getNotification()))));
                        obj.put("subscription", new JSObject(gson.toJson(result.getSubscription())));
                        if (hasListeners("notificationOpened")) {
                            notifyListeners("notificationOpened", obj);
                        } else {
                            coldStartOpenObject = obj;
                        }
                    } catch (Exception ex) {
                        System.out.println(ex.getMessage());
                    }
                },
                (SubscribedListener) subscriptionId -> {
                    JSObject obj = new JSObject();
                    obj.put("subscriptionId", subscriptionId);
                    notifyListeners("subscribed", obj);
                },
                Boolean.TRUE.equals(call.getBoolean("autoRegister", true))
        );

        CleverPush.getInstance(this.getActivity()).setAppBannerOpenedListener(action -> {
            JSObject obj = new JSObject();
            JSObject actionObj = new JSObject();
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
            if (action.getAttributeId() != null) {
                actionObj.put("attributeId", action.getAttributeId());
            }
            if (action.getAttributeId() != null) {
                actionObj.put("attributeValue", action.getAttributeId());
            }

            actionObj.put("dismiss", action.getDismiss());
            actionObj.put("openInWebview", action.isOpenInWebView());
            actionObj.put("openBySystem", action.isOpenBySystem());
            notifyListeners("appBannerOpened", actionObj);
        });
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void addListener(PluginCall call) {
        super.addListener(call);
        String eventName = call.getString("eventName");
        if (coldStartOpenObject != null && eventName != null && eventName.equals("notificationOpened")) {
            notifyListeners("notificationOpened", coldStartOpenObject);
            coldStartOpenObject = null;
        }
    }

    @PluginMethod
    public void getSubscriptionId(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).getSubscriptionId(subscriptionId -> {
            JSObject obj = new JSObject();
            obj.put("subscriptionId", subscriptionId);
            call.resolve(obj);
        });
    }

    @PluginMethod
    public void trackPageView(PluginCall call) {
        String value = call.getString("url");
        if (value != null && !value.isEmpty()) {
            CleverPush.getInstance(this.getActivity()).trackPageView(value);
            call.resolve(new JSObject().put("success", true));
        } else {
            call.reject("Invalid URL parameter");
        }
    }   

    @PluginMethod
    public void trackEvent(PluginCall call) {
        String eventName = call.getString("eventName");
        JSObject propertiesObject = call.getObject("properties");
         if (eventName != null) {
            if (propertiesObject != null) {
                Iterator<String> keysIter = propertiesObject.keys();
                List<String> keys = new ArrayList<>();
                Map<String, Object> properties = new HashMap<>();
                while (keysIter.hasNext()) {
                    String key = keysIter.next();
                    String value = propertiesObject.getString(key);
                    if (value != null) {
                        properties.put(key, value);
                    }
                }
                CleverPush.getInstance(this.getActivity()).trackEvent(eventName, properties);
            } else {
                CleverPush.getInstance(this.getActivity()).trackEvent(eventName);
            }
            call.resolve(new JSObject().put("success", true));
         } else {
            call.reject("Invalid eventName parameter");
         }
    }

    @PluginMethod
    public void addSubscriptionTag(PluginCall call) {
        String value = call.getString("tagId");
        if (value != null && !value.isEmpty()) {
            CleverPush.getInstance(this.getActivity()).addSubscriptionTag(value);
            call.resolve(new JSObject().put("success", true));
        } else {
            call.reject("Invalid tagId parameter");
        }
    }

    @PluginMethod
    public void removeSubscriptionTag(PluginCall call) {
        String value = call.getString("tagId");
        if (value != null && !value.isEmpty()) {
            CleverPush.getInstance(this.getActivity()).removeSubscriptionTag(value);
            call.resolve(new JSObject().put("success", true));
        } else {
            call.reject("Invalid tagId parameter");
        }
    }

    @PluginMethod
    public void hasSubscriptionTag(PluginCall call) {
        String tag = call.getString("tagId");
        boolean value = CleverPush.getInstance(this.getActivity()).hasSubscriptionTag(tag);
        JSObject obj = new JSObject();
        obj.put("hasTag", value);
        call.resolve(obj);
    }

    @PluginMethod
    public void setSubscriptionTopics(PluginCall call) throws JSONException {
        JSArray topicsArray = call.getArray("topics");

        if (topicsArray != null) {
            String[] value = new String[topicsArray.length()];
            for (int i = 0; i < topicsArray.length(); i++) {
                value[i] = topicsArray.getString(i);
            }
            CleverPush.getInstance(this.getActivity()).setSubscriptionTopics(value);
            call.resolve(new JSObject().put("success", true));
        } else {
            call.reject("Invalid topics parameter");
        }
    } 
    
    @PluginMethod
    public void getSubscriptionTags(PluginCall call) {
        Set<String> subscriptionTags = CleverPush.getInstance(this.getActivity()).getSubscriptionTags();
        JSObject result = new JSObject();
        result.put("tagIds", subscriptionTags);
        call.resolve(result);
    }

    @PluginMethod
    public void getSubscriptionTopics(PluginCall call) {
        Set<String> subscriptionTopics = CleverPush.getInstance(this.getActivity()).getSubscriptionTopics();
        JSONArray jsonArray = new JSONArray(subscriptionTopics);
        JSObject obj = new JSObject();
        obj.put("topicIds", jsonArray);
        call.resolve(obj);
    }

    @PluginMethod
    public void getAvailableTopics(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).getAvailableTopics(topics -> {
            JSONArray topicsArray = new JSONArray();

            for (ChannelTopic topic : topics) {
                JSONObject topicObject = new JSONObject();
                try {
                    topicObject.put("id", topic.getId());
                    topicObject.put("name", topic.getName());
                    topicsArray.put(topicObject);
                } catch (JSONException e) {
                    call.reject("Failed to create topic JSON", e);
                    return;
                }
            }

            JSObject obj = new JSObject();
            obj.put("topics", topicsArray);
            call.resolve(obj);
        });
    }

    @PluginMethod
    public void isSubscribed(PluginCall call) {
        boolean value = CleverPush.getInstance(this.getActivity()).isSubscribed();
        JSObject obj = new JSObject();
        obj.put("isSubscribed", value);
        call.resolve(obj);
    }

    @PluginMethod
    public void unsubscribe(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).unsubscribe();
        JSObject obj = new JSObject();
        call.resolve(obj);
    }

    @PluginMethod
    public void subscribe(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).subscribe(new SubscribedCallbackListener() {
            @Override
            public void onSuccess(String newSubscriptionId) {
                JSObject obj = new JSObject();
                obj.put("subscriptionId", newSubscriptionId);
                call.resolve(obj);
            }
            
            @Override
            public void onFailure(Throwable exception) {
                call.reject(exception.getMessage());
            }
        });
    }

    @PluginMethod
    public void showTopicsDialog(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).showTopicsDialog();
        call.resolve(new JSObject().put("success", true));
    }

    @PluginMethod
    public void enableDevelopmentMode(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).enableDevelopmentMode();
        call.resolve(new JSObject().put("success", true));
    }

    @PluginMethod
    public void setAuthorizerToken(PluginCall call) {
        String token = call.getString("token");
        if (token != null && !token.isEmpty()) {
            CleverPush.getInstance(this.getActivity()).setAuthorizerToken(token);
            call.resolve(new JSObject().put("success", true));
        } else {
            call.reject("Invalid token parameter");
        }
    }

    @PluginMethod
    public void getNotifications(PluginCall call) {
        Gson gson = new Gson();
        Set<Notification> notifications = CleverPush.getInstance(this.getActivity()).getNotifications();
        JSArray notificationsArray = new JSArray();
        for (Notification notification : notifications) {
            try {
                JSObject notificationObj = this.getNotificationJSObject(new JSObject(gson.toJson(notification)));
                notificationsArray.put(notificationObj);
            } catch (Exception ex) {
                System.out.println("Exception while getting notifications: " + ex.getMessage());
            }
        }
        JSObject result = new JSObject();
        result.put("notifications", notificationsArray);
        call.resolve(result);
    }

    @PluginMethod
    public void getAvailableAttributes(PluginCall call) {
        CleverPush.getInstance(this.getActivity()).getAvailableAttributes(attributes -> {
            Set<CustomAttribute> customAttributes = attributes;
            JSObject obj = new JSObject();
            obj.put("attributes", customAttributes);
            call.resolve(obj);
        });
    }

    @PluginMethod
    public void setSubscriptionAttribute(PluginCall call) {
        String attributeId = call.getString("attributeId");
        String value = call.getString("value");
        if (attributeId != null && value != null) {
            CleverPush.getInstance(this.getActivity()).setSubscriptionAttribute(attributeId, value);
            call.resolve(new JSObject().put("success", true));
        } else {
            call.reject("Invalid attributeId or value parameter");
        }
    }

    @PluginMethod
    public void getSubscriptionAttribute(PluginCall call) {
        String attributeId = call.getString("attributeId");
        Object value = CleverPush.getInstance(this.getActivity()).getSubscriptionAttribute(attributeId);
        JSObject obj = new JSObject();
        obj.put("value", value);
        call.resolve(obj);
    }

    @PluginMethod
    public void getSubscriptionAttributes(PluginCall call) {
        Map<String, Object> attributes = CleverPush.getInstance(this.getActivity()).getSubscriptionAttributes();
        JSObject obj = new JSObject();
        obj.put("attributes", attributes);
        call.resolve(obj);
    }

    @PluginMethod
    public void setShowNotificationsInForeground(PluginCall call) {
        boolean value = call.getBoolean("showNotifications");
        showNotificationsInForeground = value;
        call.resolve(new JSObject().put("success", true));
    }
}
