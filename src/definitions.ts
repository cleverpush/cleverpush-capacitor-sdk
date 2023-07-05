import type { PluginListenerHandle } from '@capacitor/core';


export interface CleverPushCapacitorPlugin {
  init(options: { channelId: string, autoRegister: boolean }): void;
  subscribe(): void;
  unsubscribe(): void;
  isSubscribed(): Promise<{ isSubscribed: boolean }>;
  getSubscriptionId(): Promise<{ subscriptionId: string }>;
  trackPageView(url: string): void;
  addSubscriptionTag(tagId: string): void;
  removeSubscriptionTag(tagId: string): void;
  hasSubscriptionTag(tagId: string): Promise<{ hasTag: boolean }>;
  setSubscriptionTopics(topics: string[]): void;
  getSubscriptionTags(): Promise<{ tagIds: string[] }>;
  getSubscriptionTopics(): Promise<{ topicIds: string[] }>;
  getAvailableTopics(): Promise<{ topics: Array<{ _id: string; name: string; }> }>;
  showTopicsDialog(): void;
  enableDevelopmentMode(): void;
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
