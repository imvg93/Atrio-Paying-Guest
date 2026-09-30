/// Every route path in one place. Screens navigate with these constants, never
/// with string literals.
class AppRoutes {
  const AppRoutes._();

  // --- common ---
  static const String splash = '/';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';
  static const String profile = '/profile';

  // --- student ---
  static const String search = '/search';
  static const String searchMap = '/search/map';
  static const String propertyDetail = '/property/:id';
  static const String visitRequestForm = '/property/:id/request-visit';
  static const String myVisits = '/my-visits';

  // --- owner: the four shell tabs ---
  static const String ownerHome = '/owner/home';
  static const String ownerTenants = '/owner/tenants';
  static const String ownerRent = '/owner/rent';
  static const String ownerMore = '/owner/more';

  /// Where an owner lands after sign-in.
  static const String ownerDashboard = ownerHome;

  // --- owner: full-screen routes, pushed over the shell ---
  static const String ownerPropertyNew = '/owner/property/new';
  static const String ownerPropertyOverview = '/owner/property/:id';
  static const String ownerPropertyEdit = '/owner/property/:id/edit';
  static const String ownerPropertySettings = '/owner/property/:id/settings';
  static const String ownerPropertyManage = '/owner/property/:id/manage';
  static const String ownerVisitRequests = '/owner/visit-requests';

  /// Tab roots, in bottom-nav order. The shell's branch order must match.
  static const List<String> ownerTabs = [
    ownerHome,
    ownerTenants,
    ownerRent,
    ownerMore,
  ];

  static String propertyDetailFor(String id) => '/property/$id';

  static String visitRequestFormFor(String id) => '/property/$id/request-visit';

  static String ownerPropertyOverviewFor(String id) => '/owner/property/$id';

  static String ownerPropertyEditFor(String id) => '/owner/property/$id/edit';

  static String ownerPropertySettingsFor(String id) =>
      '/owner/property/$id/settings';

  static String ownerPropertyManageFor(String id) =>
      '/owner/property/$id/manage';

  /// Routes reachable without a session.
  static const Set<String> publicPaths = {splash, phone, otp};

  /// Prefixes belonging to the student experience. Owners are redirected away
  /// from these; anything not listed here is reachable by either role, so a new
  /// shared screen works by default instead of silently bouncing owners home.
  static const List<String> studentOnlyPrefixes = [
    search,
    myVisits,
    '/property/',
  ];

  static bool isOwnerArea(String path) => path.startsWith('/owner');

  static bool isStudentArea(String path) =>
      studentOnlyPrefixes.any((prefix) => path == prefix || path.startsWith(prefix));
}
