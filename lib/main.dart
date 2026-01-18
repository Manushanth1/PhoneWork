import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'
    hide AuthProvider;
import 'package:amplify_flutter/amplify_flutter.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_one/screens/home/home_screen.dart';
import 'package:next_one/auth_screen.dart';
import 'package:next_one/providers/user_provider.dart';
import 'package:next_one/providers/job_provider.dart';
import 'package:next_one/providers/posted_job_provider.dart';
import 'package:next_one/providers/auth_provider.dart';
import 'package:next_one/amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => PostedJobProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    if (!Amplify.isConfigured) {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      debugPrint('✅ Amplify configured successfully');
    }
  } catch (e) {
    debugPrint('❌ Amplify error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for the next frame to ensure provider is accessible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Provider.of<PostedJobProvider>(context, listen: false).loadJobs();
      if (!mounted) return;
      await Provider.of<JobProvider>(context, listen: false).loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next One',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : const AuthScreen();
        },
      ),
    );
  }
}
