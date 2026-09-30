import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/data/models/user.dart';
import '../../features/auth/presentation/complete_profile_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/owner/presentation/owner_more_screen.dart';
import '../../features/owner/presentation/owner_portfolio_screen.dart';
import '../../features/owner/presentation/owner_rent_screen.dart';
import '../../features/owner/presentation/owner_shell.dart';
import '../../features/owner/presentation/owner_tenants_screen.dart';
import '../../features/owner/presentation/owner_visit_requests_screen.dart';
import '../../features/owner/presentation/property_manage_screen.dart';
import '../../features/owner/presentation/property_overview_screen.dart';
import '../../features/owner/presentation/property_settings_screen.dart';
import '../../features/owner/presentation/property_wizard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/properties/presentation/property_detail_screen.dart';
import '../../features/search/presentation/search_map_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/visits/presentation/my_visits_screen.dart';
import '../../features/visits/presentation/visit_request_form_screen.dart';
import 'app_routes.dart';

/// The navigator the owner shell sits in. Routes that name it as their
/// `parentNavigatorKey` cover the bottom nav instead of appearing inside a tab.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // go_router needs a Listenable to know when to re-evaluate `redirect`.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        builder: (_, _) => const PhoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (_, _) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const ProfileScreen(),
      ),

      // --- student ---
      GoRoute(
        path: AppRoutes.search,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.searchMap,
        builder: (_, _) => const SearchMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.propertyDetail,
        builder: (_, state) => PropertyDetailScreen(
          propertyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.visitRequestForm,
        builder: (_, state) => VisitRequestFormScreen(
          propertyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.myVisits,
        builder: (_, _) => const MyVisitsScreen(),
      ),

      // --- owner: the tab shell ---
      //
      // Branch order must match OwnerShell's destinations and
      // AppRoutes.ownerTabs. Each branch owns a navigator, so a tab keeps its
      // scroll position and any half-finished form when you leave and return.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            OwnerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ownerHome,
                builder: (_, _) => const OwnerPortfolioScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ownerTenants,
                builder: (_, _) => const OwnerTenantsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ownerRent,
                builder: (_, _) => const OwnerRentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ownerMore,
                builder: (_, _) => const OwnerMoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- owner: full-screen flows, pushed over the shell ---
      //
      // parentNavigatorKey sends these to the root navigator so the bottom nav
      // is not left hanging under a multi-step wizard.
      //
      // `/owner/property/new` must stay ahead of `/owner/property/:id`, which
      // would otherwise swallow it and try to load a property called "new".
      GoRoute(
        path: AppRoutes.ownerPropertyNew,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const PropertyWizardScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerPropertyEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PropertyWizardScreen(
          propertyId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerPropertySettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PropertySettingsScreen(
          propertyId: state.pathParameters['id']!,
        ),
      ),
      // Bare `/owner/property/:id` last, so the more specific paths above win.
      GoRoute(
        path: AppRoutes.ownerPropertyOverview,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PropertyOverviewScreen(
          propertyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerPropertyManage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PropertyManageScreen(
          propertyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerVisitRequests,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const OwnerVisitRequestsScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('No route for ${state.uri}')),
    ),
  );
});

/// Role-based redirect (CLAUDE.md 2, navigation).
///
/// Role is enforced on the backend regardless — this only keeps the user out
/// of screens that would fail anyway, it is not a security boundary.
String? _redirect(Ref ref, GoRouterState state) {
  final authAsync = ref.read(authControllerProvider);
  final path = state.matchedLocation;

  // Still resolving the session, or an error we surface on the splash screen.
  if (authAsync.isLoading || authAsync.hasError) {
    return path == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final auth = authAsync.value ?? const AuthUnknown();

  return switch (auth) {
    AuthUnknown() => path == AppRoutes.splash ? null : AppRoutes.splash,

    // Signed out: only the phone/OTP screens are reachable.
    AuthUnauthenticated() =>
      (path == AppRoutes.phone || path == AppRoutes.otp)
          ? null
          : AppRoutes.phone,

    // Signed in but no name/role yet — pin them to the profile screen.
    AuthNeedsProfile() =>
      path == AppRoutes.completeProfile ? null : AppRoutes.completeProfile,

    AuthAuthenticated(:final role) => _redirectForRole(role, path),
  };
}

String? _redirectForRole(UserRole role, String path) {
  // Bounce a signed-in user away from the pre-auth screens.
  if (AppRoutes.publicPaths.contains(path) ||
      path == AppRoutes.completeProfile) {
    return _homeFor(role);
  }

  // Deny-lists, not an allow-list. This used to send owners home from any path
  // that was not under /owner and not in a hand-maintained shared set, so every
  // new cross-role screen silently bounced owners to their dashboard until
  // somebody remembered to register it. Now each role is only turned away from
  // the other's area, and anything shared works by default.
  if (role.isStudent && AppRoutes.isOwnerArea(path)) {
    return AppRoutes.search;
  }

  if (role.isOwner && AppRoutes.isStudentArea(path)) {
    return AppRoutes.ownerHome;
  }

  return null;
}

String _homeFor(UserRole role) =>
    role.isOwner ? AppRoutes.ownerHome : AppRoutes.search;
