abstract class AdminAuthState {}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthSuccess extends AdminAuthState {}

class AdminAuthError extends AdminAuthState {
  final String message;
  AdminAuthError(this.message);
}
