import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:images_to_pdf/images_to_pdf.dart';
import 'package:path_provider/path_provider.dart';

abstract class PDFGeneration {
  static String _internalStorage;
  static String _externalStorage;

  static Future<void> createPDF(List<Uint8List> images, Size size) async {
    if (_internalStorage == null)
      _internalStorage = (await getApplicationDocumentsDirectory()).path;
    if (_externalStorage == null)
      _externalStorage = (await getExternalStorageDirectory()).path;

    try {
      List<io.File> _files = [];

      int _tempImages = -1;
      for (var imageBytes in images) {
        _tempImages++;
        final input = io.File(_internalStorage + '/$_tempImages.png');
        await input.writeAsBytes(imageBytes);
        _files.add(input);
      }

      final output = io.File(_externalStorage + '/example.pdf');

      await ImagesToPdf.createPdf(
        pages: _files
            .map(
              (file) => PdfPage(
                imageFile: file,
                size: size,
                compressionQuality: 10,
              ),
            )
            .toList(),
        output: output,
      );

      final stat = await output.stat();

      print('Output size: ${stat.size}');

      for (var i = 0; i < _tempImages; i++)
        await io.File(_internalStorage + '/$_tempImages.png').delete();
    } catch (e) {
      print('Failed to generate pdf: $e".');
    }
  }
}
