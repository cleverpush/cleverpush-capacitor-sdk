import type { PluginListenerHandle } from '@capacitor/core';


export interface CleverPushCapacitorPlugin {
  init(options: { channelId: string, autoRegister: boolean }): void;
  subscribe(): void;
  unsubscribe(): void;
  isSubscribed(): Promise<{ isSubscribed: boolean }>;
  getSubscriptionId(): Promise<{ subscriptionId: string }>;
  trackPageView(options: { trackPage: string }): void;
  addSubscriptionTag(options: { subscriptionTag: string }): void;
  removeSubscriptionTag(options: { subscriptionTag: string }): void;
  hasSubscriptionTag(options: { subscriptionTag: string }): Promise<{ success: boolean }>;
  setSubscriptionTopics(options: { topics: string[] }): void;
  getSubscriptionTags(): Promise<{ subscriptionTags: string[] }>;
  getSubscriptionTopics(): Promise<{ subscriptionTopics: string[] }>;
  getAvailableTopics(): Promise<{ availableTopics: Array<{ _id: string; name: string; }> }>;
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
