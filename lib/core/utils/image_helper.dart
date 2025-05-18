import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File?> compressImage(File file) async {
  final targetPath = file.path + '_compressed.jpg';
  final compressedXFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70,
  );
  if (compressedXFile == null) return null;
  return File(compressedXFile.path);
}
