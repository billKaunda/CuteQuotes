part of 'profile_menu_bloc.dart';

abstract class ProfileMenuState extends Equatable {
  const ProfileMenuState();

  @override
  List<Object?> get props => [];
}

class ProfileMenuInProgress extends ProfileMenuState {
  const ProfileMenuInProgress();
}

class ProfileMenuLoaded extends ProfileMenuState {
  const ProfileMenuLoaded({
    this.darkModePreference = DarkModePreference.useSystemSettings,
    this.isSignOutInProgress = false,
    this.isUserAuthenticated = false,
    this.username,
  });

  final DarkModePreference darkModePreference;
  final bool isSignOutInProgress;
  final bool isUserAuthenticated;
  final String? username;

  @override
  List<Object?> get props => [
        darkModePreference,
        isSignOutInProgress,
        isUserAuthenticated,
        username,
      ];

  ProfileMenuLoaded copyWith({
    DarkModePreference? darkModePreference,
    bool? isSignOutInProgress,
    bool? isUserAuthenticated,
    String? username,
  }) {
    return ProfileMenuLoaded(
      darkModePreference: darkModePreference ?? this.darkModePreference,
      isSignOutInProgress: isSignOutInProgress ?? this.isSignOutInProgress,
      isUserAuthenticated: isUserAuthenticated ?? this.isUserAuthenticated,
      username: username ?? this.username,
    );
  }
}
