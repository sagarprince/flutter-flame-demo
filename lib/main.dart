import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/manager.dart';
import 'package:flutter_flame_demo/shared_instances.dart';
import 'package:flutter_flame_demo/theme.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/utils/keys.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppManager.setup();
  GameManager.setup();
  runApp(MyGame());
}

class MyGame extends StatelessWidget {
  MyGame({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_context) {
        CRBloc _bloc = CRBloc();
        SharedInstances.context = _context;
        return _bloc;
      },
      child: MaterialApp(
        title: 'Chain Reaction',
        debugShowCheckedModeBanner: false,
        navigatorKey: Keys.navigatorKey,
        theme: themeData,
        initialRoute: AppRoutes.base,
        onGenerateRoute: (RouteSettings settings) {
          return Routes.builder(settings);
        },
      ),
    );
  }
}
