// wifi-signal.m — tiny CoreWLAN helper for sketchybar wifi.sh
// Source: hand-maintained in dotfiles/sketchybar/helpers/wifi-signal.m
// Build: clang -framework CoreWLAN -framework Foundation wifi-signal.m -o wifi-signal
//   (built automatically by plugins/wifi.sh into $XDG_CACHE_HOME/sketchybar/wifi-signal)
// Output: single line — "off", "disconnected", "no-iface", or RSSI integer like "-54"
//   RSSI is dBm (negative). Returns 0 only when not associated — treated as disconnected.
//
// Why CoreWLAN? The old `airport -I` CLI was removed in macOS Sonoma/Sequoia
// (no longer at /System/Library/PrivateFrameworks/.../airport nor /usr/sbin/airport).
// `wdutil info` requires sudo, `system_profiler` is slow and redacts SSID/BSSID,
// and `ipconfig getsummary` gives no signal. CoreWLAN CWWiFiClient is the only
// non-privileged API that still returns RSSI even when SSID is "<redacted>".

#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>

int main(void) {
  @autoreleasepool {
    CWWiFiClient *client = [CWWiFiClient sharedWiFiClient];
    CWInterface *iface = [client interface];
    if (!iface) {
      for (NSString *name in @[@"en0", @"en1", @"en2"]) {
        iface = [client interfaceWithName:name];
        if (iface) break;
      }
    }
    if (!iface) {
      printf("no-iface\n");
      return 0;
    }
    if (![iface powerOn]) {
      printf("off\n");
      return 0;
    }
    NSInteger rssi = [iface rssiValue];
    // rssiValue is 0 when not associated / no valid measurement
    if (rssi == 0) {
      printf("disconnected\n");
      return 0;
    }
    printf("%ld\n", (long)rssi);
    return 0;
  }
}
