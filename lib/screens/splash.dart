import 'package:billing_software/Files/data.dart';
import 'package:billing_software/providers/bills.dart';
import 'package:billing_software/providers/customers.dart';
import 'package:billing_software/providers/products.dart';
import 'package:billing_software/screens/home_page.dart';
import 'package:billing_software/screens/login.dart';
import 'package:billing_software/utils/files.dart';
import 'package:billing_software/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    checkToken();
    super.initState();
  }

  Future<void> checkToken() async {
    String? token = await data().retrieveAccessToken(Files.user);

    Provider.of<Customers>(context, listen: false)
        .fetchDataFromFile(Files.customer, Keys.customer);

    Provider.of<Products>(context, listen: false).fetchDataFromFile(Files.product, Keys.product);

    Provider.of<Bills>(context, listen: false).fetchDataFromFile(Files.bill, Keys.bill);

    if (token != null && token.length > 5) {
      Navigator.of(context).pushReplacementNamed(HomePage.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(SignIn.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
