import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/localization/generated/app_localizations.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key, required this.child, required this.user});

  final Widget child;
  final AuthUserEntity user;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
      BottomNavigationBarItem(icon: const Icon(Icons.store), label: l10n.store),
    ];

    if (widget.user.role == "AGENT") {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: l10n.dashboard,
        ),
      );
    }

    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: l10n.profile,
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: _buildNavItems(context),
        currentIndex: _getCurrentIndex(context),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => context.go(_convertIndexToRouteName(index)),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();

    if (route.startsWith(RouteName.home)) return 0;
    if (route.startsWith(RouteName.product)) return 1;

    if (widget.user.role == "AGENT") {
      if (route.startsWith(RouteName.dashboard)) return 2;
      if (route.startsWith(RouteName.viewProfile) ||
          route.startsWith(RouteName.profile))
        return 3;
    } else {
      if (route.startsWith(RouteName.viewProfile) ||
          route.startsWith(RouteName.profile))
        return 2;
    }
    return 0;
  }

  String _convertIndexToRouteName(int index) {
    if (widget.user.role == "AGENT") {
      switch (index) {
        case 0:
          return RouteName.home;
        case 1:
          return RouteName.product;
        case 2:
          return RouteName.dashboard;
        case 3:
          return RouteName.viewProfile;
        default:
          return RouteName.home;
      }
    } else {
      switch (index) {
        case 0:
          return RouteName.home;
        case 1:
          return RouteName.product;
        case 2:
          return RouteName.viewProfile;
        default:
          return RouteName.home;
      }
    }
  }
}
