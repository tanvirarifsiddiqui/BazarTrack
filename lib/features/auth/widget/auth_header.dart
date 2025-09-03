import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  const AuthHeader(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/image/logo.png', height: 120),
        SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 32),
      ],
    );
  }
}