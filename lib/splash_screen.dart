import 'package:finite_automata/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateInto();
  }

  navigateInto() async {
    await Future.delayed(
      const Duration(milliseconds: 3850),
      () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const MyHomePage(title: 'Finite Automata')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/book.json'),
      ),
    );
  }
}
