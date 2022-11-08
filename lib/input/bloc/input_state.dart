part of 'input_bloc.dart';

@freezed
class InputState with _$InputState {
  const factory InputState.initial() = _Initial;

  const factory InputState.url(String gtfsUrl) = _Url;

  const factory InputState.file(Uint8List bytes) = _File;

  static const exampleFeeds = {
    'Vilnius, Lithuania': 'https://stops.lt/vilnius/vilnius/gtfs.zip',
    'Kaunas, Lithuania': 'https://stops.lt/kaunas/kaunas/gtfs.zip',
    'Klaipėda, Lithuania': 'https://www.stops.lt/klaipeda/klaipeda/gtfs.zip',
    'Panevėžys, Lithuania': 'https://www.stops.lt/panevezys/panevezys/gtfs.zip',
    'Norway':
        'https://storage.googleapis.com/marduk-production/outbound/gtfs/rb_norway-aggregated-gtfs-basic.zip',
  };
}
