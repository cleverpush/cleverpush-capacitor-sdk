import type { PluginListenerHandle } from '@capacitor/core';

export interface CleverPushCapacitorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  getSubscriptionId(): void;
  subscribe(): void;
  initcleverPush(options: { channelId: string, autoRegister: boolean }): void;
  unsubscribe(): void;
  enableDevelopmentMode(): void;
  showTopicsDialog(): void;
  isSubscribed(): boolean;
  setAppBannerOpenedHandler(): void;
  setNotificationReceivedHandler(): void;
  setNotificationOpenedHandler(): void;
  setSubscribedHandler(): void;
  addListener(
    eventName: 'notificationReceivedListener',
    listenerFunc: (data: { success: boolean, data?: any, error?: any }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'notificationOpenedListener',
    listenerFunc: (data: { success: boolean, data?: any, error?: any }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'appBannerOpenedListener',
    listenerFunc: (data: { success: boolean, data?: any, error?: any }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(
    eventName: 'subscribedListener',
    listenerFunc: (data: { success: boolean, data?: any, error?: any }) => void,
  ): Promise<PluginListenerHandle> & PluginListenerHandle;
}
