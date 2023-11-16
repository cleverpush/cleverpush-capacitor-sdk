import type { PluginListenerHandle } from '@capacitor/core';


export interface CleverPushCapacitorPlugin {
  init(options: { channelId: string, autoRegister: boolean }): void;
  subscribe(): Promise<{ subscriptionId: string }>;
  unsubscribe(): Promise<{ unSubscribe: boolean }>;
  isSubscribed(): Promise<{ isSubscribed: boolean }>;
  getSubscriptionId(): Promise<{ subscriptionId: string }>;
  showTopicsDialog(): void;
  enableDevelopmentMode(): void;
  trackPageView(options: { url: string }): Promise<void>;
  trackEvent(options: { eventName: string, properties?: Record<string, unknown> }): Promise<void>;
  addSubscriptionTag(options: { tagId: string }): Promise<void>;
  removeSubscriptionTag(options: { tagId: string }): Promise<void>;
  hasSubscriptionTag(options: { tagId: string}): Promise<{ hasTag: boolean }>;
  getSubscriptionTags(): Promise<{ tagIds: string[] }>;
  getSubscriptionTopics(): Promise<{ topicIds: string[] }>;
  setSubscriptionTopics(options: { topics: string[] }): Promise<void>;
  getAvailableTopics(): Promise<{ topics: { _id: string; name: string; }[] }>;
  setAuthorizerToken(options: { token: string }): Promise<void>;
  getNotifications(): Promise<{ notifications: any[] }>;
  setSubscriptionAttribute(options: { attributeId: string; value: string }): Promise<void>;
  getSubscriptionAttribute(options: { attributeId: string}): Promise<{ value: string }>;
  getSubscriptionAttributes(): Promise<{ attributes: { attributeId: string; value: string; }[] }>;
  getAvailableAttributes(): Promise<{ attributes: { attributeId: string; value: string; }[] }>;
  setShowNotificationsInForeground(options: { showNotifications: boolean }): Promise<void>;

  addListener(
    eventName: 'notificationReceived',
    listenerFunc: (data: { notification?: any }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'notificationOpened',
    listenerFunc: (data: { notification?: any }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'appBannerOpened',
    listenerFunc: (data: any) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'subscribed',
    listenerFunc: (data: { subscriptionId: string }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
}

