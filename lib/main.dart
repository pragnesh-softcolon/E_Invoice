import 'dart:io';

import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/screens/bill.dart';
import 'package:billing_software/screens/home_page.dart';
import 'package:billing_software/screens/login.dart';
import 'package:billing_software/screens/product.dart';
import 'package:billing_software/screens/sign_up.dart';
import 'package:billing_software/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('My App');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(Size.infinite);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Customers(),
        ),
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (context) => Bills(),
        ),
      ],
      child: MaterialApp(
          title: 'Billing Software',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blueGrey,
            ),
            useMaterial3: false,
          ),
          home: const Splash(),
          routes: {
            SignUp.routeName: (ctx) => const SignUp(),
            SignIn.routeName: (ctx) => const SignIn(),
            Product.routeName: (ctx) => const Product(),
            Bill.routeName: (ctx) => const Bill(),
            HomePage.routeName: (ctx) => const HomePage(),
          }),
    );
  }
}
