import 'package:chat_app/cubit/login/login_cubit.dart';
import 'package:chat_app/cubit/register/register_cubit.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/remote/firebase_repository.dart';
import 'package:chat_app/ui/screens/signIn_screen.dart';
import 'package:chat_app/ui/screens/signup_screen.dart';
import 'package:chat_app/ui/screens/splash_screen.dart';
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
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      routes: AppRoutes.pageRoute,
    );
  }
}
