import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/network/connectivity_service.dart';

/// Banner shown at the top of the screen when the device is offline.
/// Wraps any scaffold body and slides in/out based on connectivity.
class OfflineAwareBody extends StatefulWidget {
  final Widget child;

  const OfflineAwareBody({super.key, required this.child});

  @override
  State<OfflineAwareBody> createState() => _OfflineAwareBodyState();
}

class _OfflineAwareBodyState extends State<OfflineAwareBody> {
  final _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _connectivity.addListener(_onChanged);
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _connectivity.isOffline
              ? const _OfflineBanner()
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No internet connection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: -1, duration: 300.ms);
  }
}
