import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:CMSC190_WildlifeMarkerJCGCabanlong/LoginReg.dart';
import 'package:CMSC190_WildlifeMarkerJCGCabanlong/Mapping.dart';
//import 'LoginReg.dart';
//import 'HomePage.dart';
import 'Mapping.dart';
import 'Authenticate.dart';

//

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);

  };

  runApp(new WildLifeApp());
}


class WildLifeApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return new MaterialApp
      (
          title: "Wildlife App",

          theme: new ThemeData
            (
              primarySwatch: Colors.green,
            ),

            home: MappingPage(auth: Auth( ),),

      );
  }
}