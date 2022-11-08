part of 'inspect_cubit.dart';

@freezed
class InspectState with _$InspectState {
  const factory InspectState.initial() = _Initial;

  const factory InspectState.loading() = _Loading;

  const factory InspectState.loadingContent(
    List<String> fileNames,
    String selectedFileName,
  ) = _LoadingContent;

  const factory InspectState.error(
    Object exception,
    StackTrace? stackTrace,
  ) = _Error;

  const factory InspectState.errorContent(
    Object exception,
    StackTrace stackTrace,
    List<String> fileNames,
    String selectedFileName,
  ) = _ErrorContent;

  const factory InspectState.content(
    List<String> fileNames,
    String selectedFileName,
    List<List<String>> csv,
  ) = _Content;
}
