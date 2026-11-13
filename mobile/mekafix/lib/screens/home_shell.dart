import 'package:flutter/material.dart';
import 'package:mekafix/screens/jobs_screen.dart';
import 'package:mekafix/screens/mechanic_inbox_screen.dart';
import 'package:mekafix/screens/profile_screen.dart';
import 'package:mekafix/screens/search_screen.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';
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
    final pages = user.isMechanic
        ? const [MechanicInboxScreen(), SearchScreen(), ProfileScreen()]
        : const [SearchScreen(), JobsScreen(), ProfileScreen()];
    final destinations = user.isMechanic
        ? const [
            NavigationDestination(icon: Icon(Icons.handyman_outlined), label: 'Jobs'),
            NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Find help'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Requests'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
          ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: destinations,
        onDestinationSelected: (value) => setState(() => index = value),
      ),
    );
  }
}
