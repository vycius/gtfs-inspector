import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gtfs_inspector/input/input.dart';

class InputPage extends StatelessWidget {
  const InputPage({
    super.key,
    required this.initialGtfsUrl,
  });

  final String? initialGtfsUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InputBloc(
        initialGtfsUrl: initialGtfsUrl,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GTFS inspector'),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Builder(
              builder: (context) {
                final formBloc = BlocProvider.of<InputBloc>(context);
                return FormBlocListener<InputBloc, InputState, String>(
                  formBloc: formBloc,
                  onSuccess: (context, state) {
                    state.successResponse?.whenOrNull(
                      url: (url) => _inspectFeedByUrl(context, url),
                      file: (bytes) => _inspectFeedFromBytes(context, bytes),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.gtfsUrl,
                        decoration: const InputDecoration(
                          labelText: 'GTFS URL',
                          hintText: 'https://example.com/gtfs.zip',
                          helperText: 'Required',
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: formBloc.submit,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Inspect'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            for (final feed in InputState.exampleFeeds.entries)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 4,
                                ),
                                child: ActionChip(
                                  label: Text(feed.key),
                                  onPressed: () {
                                    formBloc.updateValues(feed.value);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 64),
                        child: ElevatedButton(
                          onPressed: formBloc.selectGtfsFile,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('From file'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _inspectFeedByUrl(
    BuildContext context,
    String gtfsUrl,
  ) {
    context.push(
      context.namedLocation(
        'inspect',
        queryParams: {
          'gtfs_url': gtfsUrl,
        },
      ),
    );
  }

  void _inspectFeedFromBytes(
    BuildContext context,
    Uint8List bytes,
  ) {
    context.push(
      context.namedLocation('inspect'),
      extra: bytes,
    );
  }
}
