import '../data/models/user.dart';

/// Where the user stands with respect to authentication.
///
/// Deliberately a sealed hierarchy: the router switches on it exhaustively, so
/// adding a state is a compile error everywhere it must be handled rather than
/// a silent fall-through.
sealed class AuthState {
  const AuthState();
}

/// Startup — tokens are being read and validated. Show the splash.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// No valid session. Route to phone entry.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authenticated, but the profile is incomplete — CLAUDE.md 7, screen 3.
/// The user must supply a name and choose a role before entering the app.
class AuthNeedsProfile extends AuthState {
  const AuthNeedsProfile(this.user);

  final User user;
}

/// Fully signed in.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;

  UserRole get role => user.role;
}

extension AuthStateX on AuthState {
  User? get userOrNull => switch (this) {
        AuthNeedsProfile(:final user) => user,
        AuthAuthenticated(:final user) => user,
        _ => null,
      };

  bool get isResolved => this is! AuthUnknown;

  bool get isSignedIn => this is AuthAuthenticated || this is AuthNeedsProfile;
}
