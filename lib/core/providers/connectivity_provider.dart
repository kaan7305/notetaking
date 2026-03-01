import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams connectivity results whenever the network state changes.
///
/// Emits a [List<ConnectivityResult>] — connectivity_plus 6.x changed the
/// event type from a single value to a list so that platforms that can be
/// connected over multiple interfaces at once are represented correctly.
final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Derived boolean: `true` when every connectivity result is [ConnectivityResult.none].
///
/// Starts as `false` (optimistic) while the first stream event is pending, so
/// we don't flash an "offline" banner at launch before the OS responds.
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.maybeWhen(
    data: (results) =>
        results.isNotEmpty &&
        results.every((r) => r == ConnectivityResult.none),
    orElse: () => false,
  );
});
