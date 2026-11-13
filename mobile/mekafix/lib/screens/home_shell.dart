import 'package:flutter/material.dart';
import 'package:mekafix/screens/jobs_screen.dart';
import 'package:mekafix/screens/mechanic_inbox_screen.dart';
import 'package:mekafix/screens/profile_screen.dart';
import 'package:mekafix/screens/search_screen.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:mekafix/theme.dart';
import 'package:provider/provider.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MechanicState>().search();
      context.read<JobsState>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionState>().user!;
    final isMechanic = user.isMechanic;
    final pages = isMechanic
        ? const [MechanicInboxScreen(), SearchScreen(), ProfileScreen()]
        : const [SearchScreen(), JobsScreen(), ProfileScreen()];
    final destinations = isMechanic
        ? const [
            NavigationDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon: Icon(Icons.inbox_rounded),
                label: 'Work'),
            NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Explore'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Account'),
          ]
        : const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'My requests'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Account'),
          ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: destinations,
        onDestinationSelected: (value) => setState(() => index = value),
      ),
    );
  }
}
