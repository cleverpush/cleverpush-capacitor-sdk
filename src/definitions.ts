export interface CleverPushCapacitorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
