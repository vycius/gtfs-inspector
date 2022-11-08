import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GTFSService {
  Future<Uint8List> _getBytesThroughCorsProxy(String url) {
    final uri = Uri.parse('https://cors-proxy.vycius.lt/?$url');

    return http.readBytes(uri);
  }

  Future<GTFSArchive> fetchArchiveFromUrl(String gtfsUrl) async {
    final bytes = await _getBytesThroughCorsProxy(gtfsUrl);

    return fetchGTFSFromBytes(bytes);
  }

  Future<GTFSArchive> fetchGTFSFromBytes(Uint8List bytes) async {
    final archive = await compute(
      ZipDecoder().decodeBytes,
      bytes,
    );

    return GTFSArchive(archive);
  }
}

class GTFSArchive {
  GTFSArchive(this.archive);

  @protected
  final Archive archive;

  List<String> get fileNames => archive.files.map((f) => f.name).toList();

  Future<List<List<String>>> getParsedFile(String fileName) {
    return compute(_getParsedFileSync, fileName);
  }

  List<List<String>> _getParsedFileSync(String fileName) {
    final archiveFile = archive.findFile(fileName);

    if (archiveFile == null) {
      throw Exception('''$fileName doesn't exist in GTFS''');
    }

    final bytes = archiveFile.content as List<int>;
    final data = utf8.decode(bytes);

    return const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(data)
        .map(List<String>.from)
        .toList(growable: false);
  }
}
