import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routers/my_router.dart';
import 'features/auth/data/datasources/auth_datasource.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/profile/data/datasources/data_source.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController(authRemoteDataSource: AuthRemoteDataSourceImpl()));
  Get.put(ProfileController(
    profileRemoteDataSource: ProfileRemoteDataSourceImpl(),
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MyRouter myRouter = MyRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1D23),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1D23),
          elevation: 0,
        ),
      ),
      title: 'FeryouApp',
      routerDelegate: myRouter.router.routerDelegate,
      routeInformationParser: myRouter.router.routeInformationParser,
      routeInformationProvider: myRouter.router.routeInformationProvider,
    );
  }
}
