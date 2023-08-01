import type { PluginListenerHandle } from '@capacitor/core';


export interface CleverPushCapacitorPlugin {
  init(options: { channelId: string, autoRegister: boolean }): void;
  subscribe(): void;
  unsubscribe(): void;
  isSubscribed(): Promise<{ isSubscribed: boolean }>;
  getSubscriptionId(): Promise<{ subscriptionId: string }>;
  showTopicsDialog(): void;
  enableDevelopmentMode(): void;
  trackPageView(options: { url: string }): void;
  trackEvent(options: { eventName: string, properties?: Record<string, unknown> }): void;
  addSubscriptionTag(options: { tagId: string }): void;
  removeSubscriptionTag(options: { tagId: string }): void;
  hasSubscriptionTag(options: { tagId: string}): Promise<{ hasTag: boolean }>;
  getSubscriptionTags(): Promise<{ tagIds: string[] }>;
  getSubscriptionTopics(): Promise<{ topicIds: string[] }>;
  setSubscriptionTopics(options: { topics: string[] }): void;
  getAvailableTopics(): Promise<{ topics: { _id: string; name: string; }[] }>;
  setAuthorizerToken(options: { token: string }): void;
  getNotifications(): Promise<{ notifications: any[] }>;
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

