import type { PluginListenerHandle } from '@capacitor/core';


export interface CleverPushCapacitorPlugin {
  init(options: { channelId: string, autoRegister: boolean }): void;
  subscribe(): Promise<{ subscriptionId: string }>;
  unsubscribe(): Promise<{ success: boolean }>;
  isSubscribed(): Promise<{ isSubscribed: boolean }>;
  getSubscriptionId(): Promise<{ subscriptionId: string }>;
  showTopicsDialog(): void;
  enableDevelopmentMode(): void;
  trackPageView(options: { url: string }): Promise<{ success: boolean }>;
  trackEvent(options: { eventName: string, properties?: Record<string, unknown> }): Promise<{ success: boolean }>;
  addSubscriptionTag(options: { tagId: string }): Promise<{ success: boolean }>;
  removeSubscriptionTag(options: { tagId: string }): Promise<{ success: boolean }>;
  hasSubscriptionTag(options: { tagId: string }): Promise<{ hasTag: boolean }>;
  getSubscriptionTags(): Promise<{ tagIds: string[] }>;
  getSubscriptionTopics(): Promise<{ topicIds: string[] }>;
  setSubscriptionTopics(options: { topics: string[] }): Promise<{ success: boolean }>;
  getAvailableTopics(): Promise<{ topics: { _id: string; name: string; }[] }>;
  setAuthorizerToken(options: { token: string }): Promise<{ success: boolean }>;
  getNotifications(): Promise<{ notifications: any[] }>;
  setSubscriptionAttribute(options: { attributeId: string; value: string }): Promise<{ success: boolean }>;
  getSubscriptionAttribute(options: { attributeId: string }): Promise<{ value: string }>;
  getSubscriptionAttributes(): Promise<{ attributes: { attributeId: string; value: string; }[] }>;
  getAvailableAttributes(): Promise<{ attributes: { attributeId: string; value: string; }[] }>;
  setShowNotificationsInForeground(options: { showNotifications: boolean }): Promise<{ success: boolean }>;

  addListener(
    eventName: 'notificationReceived',
    listenerFunc: (data: { notification?: any }) => void,
  ): Promise<PluginListenerHandle>;
  addListener(
    eventName: 'notificationOpened',
    listenerFunc: (data: { notification?: any }) => void,
  ): Promise<PluginListenerHandle>;
  addListener(
    eventName: 'appBannerOpened',
    listenerFunc: (data: any) => void,
  ): Promise<PluginListenerHandle>;
  addListener(
    eventName: 'subscribed',
    listenerFunc: (data: { subscriptionId: string }) => void,
  ): Promise<PluginListenerHandle>;
}

