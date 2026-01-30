import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to control the main shell tab navigation.
/// This allows switching tabs from anywhere in the app.
final tabControllerProvider = NotifierProvider<TabControllerNotifier, int>(
  TabControllerNotifier.new,
);

class TabControllerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    if (index >= 0 && index <= 3) {
      state = index;
    }
  }

  void goToHome() => setTab(0);
  void goToProjects() => setTab(1);
  void goToChats() => setTab(2);
  void goToProfile() => setTab(3);
}
