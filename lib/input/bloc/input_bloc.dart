import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'input_bloc.freezed.dart';

part 'input_state.dart';

class InputBloc extends FormBloc<InputState, String> {
  InputBloc({
    required this.initialGtfsUrl,
  }) : super() {
    addFieldBlocs(
      fieldBlocs: [gtfsUrl],
    );
  }

  final String? initialGtfsUrl;

  late final gtfsUrl = TextFieldBloc(
    initialValue: initialGtfsUrl ?? '',
    validators: [FieldBlocValidators.required, _urlValidator],
  );

  void updateValues(String? gtfsUrlValue) {
    gtfsUrl.updateValue(gtfsUrlValue ?? '');
  }

  @override
  FutureOr<void> onSubmitting() {
    final url = gtfsUrl.value;

    emitSuccess(successResponse: InputState.url(url));
  }

  Future<void> selectGtfsFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select GTFS file',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    final bytes = result?.files.first.bytes;

    if (bytes != null) {
      emitSuccess(successResponse: InputState.file(bytes));
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);

    return uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
  }

  String? _urlValidator(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    } else if (_isValidUrl(url)) {
      return null;
    } else {
      return 'Please enter valid URL';
    }
  }
}
