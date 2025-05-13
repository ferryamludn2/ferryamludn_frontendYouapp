import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/create_profile_page.dart';
import '../../features/profile/presentation/widgets/about_edit.dart';
import '../../features/page/landing_page.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/presentation/pages/get_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/profile/presentation/widgets/interested_select.dart';

class MyRouter {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && state.matchedLocation == '/') {
        return '/get-profile';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: "/",
        name: "landing",
        pageBuilder: (context, state) => NoTransitionPage(child: LandingPage()),
      ),
      GoRoute(
        path: "/login",
        name: "login",
        pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: "/register",
        name: "register",
        pageBuilder: (context, state) =>
            NoTransitionPage(child: RegisterPage()),
      ),
      GoRoute(
        path: "/create-profile",
        name: "create-profile",
        pageBuilder: (context, state) =>
            NoTransitionPage(child: CreateProfilePage()),
      ),
      GoRoute(
        path: "/about-edit",
        name: "about-edit",
        pageBuilder: (context, state) => NoTransitionPage(child: AboutEdit()),
      ),
      GoRoute(
        path: "/get-profile",
        name: "get-profile",
        pageBuilder: (context, state) =>
            NoTransitionPage(child: GetProfilePage()),
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token == null) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: "/interest-select",
        name: "interest-select",
        pageBuilder: (context, state) =>
            NoTransitionPage(child: InterestSelect()),
      ),
    ],
  );
}
