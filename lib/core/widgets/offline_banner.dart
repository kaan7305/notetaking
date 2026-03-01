import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';

/// App-level offline indicator.
///
/// Wraps the router's [child] in a [Column] and slides in a slim amber banner
/// at the very top of the screen whenever [isOfflineProvider] is `true`.
///
/// Usage — place inside `MaterialApp.router`'s `builder`:
/// ```dart
/// builder: (context, child) => OfflineBanner(child: child ?? const SizedBox()),
/// ```
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineProvider);

    // Drive the animation whenever the offline state changes.
    if (isOffline) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return Column(
      children: [
        // Animated banner — clips to zero height when online.
        SizeTransition(
          sizeFactor: _heightFactor,
          axisAlignment: -1,
          child: _OfflineBannerContent(isOffline: isOffline),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// The visual content of the banner (always present in tree, size-clipped).
class _OfflineBannerContent extends StatelessWidget {
  const _OfflineBannerContent({required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      color: const Color(0xFFB45309), // warm amber-700
      padding: EdgeInsets.only(
        top: topPadding + 6,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'No internet connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
