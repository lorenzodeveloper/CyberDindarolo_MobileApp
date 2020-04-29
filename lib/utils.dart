import 'dart:math';

import 'package:flutter/material.dart';

/*
* This file contains useful classes/methods
*
* */

//Future<File> getImageFileFromAssets(String path) async {
//  final byteData = await rootBundle.load('$path');
//
//  final file = File('${(await getTemporaryDirectory()).path}/$path');
//
//  await file.writeAsBytes(byteData.buffer
//      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//
//  return file;
//}
//
//getRandomColOfImageWithPack(
//    {String assetImagePath: 'assets/images/pink_pig.png'}) async {
//  //var im = AssetImage('assets/images/pink_pig.png');
//  // Read a jpeg image from file.
//  print('quui1');
//  File file = await getImageFileFromAssets(assetImagePath);
//  print('quui2');
//  var image = pckImage.decodePng(
//      file.readAsBytesSync()); //File(assetImagePath).readAsBytesSync()
//
//  print('quui3');
//  final mod = pckImage.adjustColor(image, hue: 30);
//  return mod;
//}

/*
  * GRADIENT
  *  decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                const Color(0xFF3366FF),
                const Color(0xFF00CCFF),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp))
  * */

class UniqueColorGenerator {
  static Random random = new Random();

  static Color getColor() {
    return Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }

  static Color getRandomPrimaryColor() {
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }
}

getRandomColOfImage(
    {String assetImagePath: 'assets/images/pink_pig.png', double alpha: 1.0}) {
  return ColorFiltered(
      child: Image(image: AssetImage('assets/images/pink_pig.png')),
      colorFilter: ColorFilter.mode(
          UniqueColorGenerator.getRandomPrimaryColor().withOpacity(alpha),
          BlendMode.modulate));
}
