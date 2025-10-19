import 'package:chat_app/cubit/login/login_cubit.dart';
import 'package:chat_app/cubit/register/register_cubit.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/screens/splash_screen.dart';
import 'package:chat_app/utils/my_route_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseRepository>(
          create: (context) => FirebaseRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => RegisterCubit(
                  firebaseRepository: RepositoryProvider.of<FirebaseRepository>(
                    context,
                  ),
                ),
          ),
          BlocProvider(
            create:
                (context) => LoginCubit(
                  firebaseRepository: RepositoryProvider.of<FirebaseRepository>(
                    context,
                  ),
                ),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final MyRouteObserver _myRouteObserver = MyRouteObserver();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      navigatorObservers: [_myRouteObserver],
      routes: AppRoutes.pageRoute,
    );
  }
}
