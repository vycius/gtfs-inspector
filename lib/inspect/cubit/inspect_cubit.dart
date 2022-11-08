import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gtfs_inspector/inspect/inspect.dart';

part 'inspect_state.dart';

part 'inspect_cubit.freezed.dart';

class InspectCubit extends Cubit<InspectState> {
  InspectCubit() : super(const InspectState.initial());

  late GTFSArchive _gtfsArchive;
  late String _selectedFileName;

  List<String> _fileNames = [];

  Future<void> initialLoadFromBytes(Uint8List bytes) async {
    return _initialLoad(GTFSService().fetchGTFSFromBytes(bytes));
  }

  Future<void> initialLoadFromUrl(String url) {
    return _initialLoad(GTFSService().fetchArchiveFromUrl(url));
  }

  Future<void> _initialLoad(Future<GTFSArchive> archiveFuture) {
    return archiveFuture.then((gtfsArchive) {
      _gtfsArchive = gtfsArchive;
      _fileNames = gtfsArchive.fileNames;
      if (_fileNames.isEmpty) {
        emit(InspectState.error(Exception('GTFS has no files'), null));
      } else {
        _selectedFileName = _fileNames.first;

        return showFile(_selectedFileName);
      }
    }).catchError(
      (Object ex, StackTrace st) {
        emit(InspectState.error(ex, st));
      },
    );
  }

  Future<void> showFile(String fileName) async {
    _selectedFileName = fileName;
    emit(InspectState.loadingContent(_fileNames, fileName));

    return _gtfsArchive
        .getParsedFile(fileName)
        .then(
          (csv) =>
              emit(InspectState.content(_fileNames, _selectedFileName, csv)),
        )
        .catchError(
          (Object ex, StackTrace st) => emit(
            InspectState.errorContent(
              ex,
              st,
              _fileNames,
              _selectedFileName,
            ),
          ),
        );
  }
}
