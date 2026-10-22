import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routes/app_router.dart';
import 'features/github/data/models/saved_repo_model.dart';
import 'features/github/presentation/providers/saved_repos_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // تهيئة Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SavedRepoModelAdapter());


  final savedBox = await Hive.openBox<SavedRepoModel>('saved_repos');

  runApp(
    ProviderScope(
      overrides: [
        savedBoxProvider.overrideWithValue(savedBox),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          title: 'GitHub Repo App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}