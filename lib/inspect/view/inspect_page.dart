import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtfs_inspector/inspect/inspect.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InspectPage extends StatelessWidget {
  const InspectPage({super.key, required this.bytes, required this.gtfsUrl});

  final Uint8List? bytes;
  final String? gtfsUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final inspectCubit = InspectCubit();
        if (bytes != null) {
          return inspectCubit..initialLoadFromBytes(bytes!);
        } else if (gtfsUrl != null) {
          return inspectCubit..initialLoadFromUrl(gtfsUrl!);
        } else {
          throw Exception('Bytes or GTFS Url should be passed to InspectPage');
        }
      },
      child: const InspectView(),
    );
  }
}

class InspectView extends StatelessWidget {
  const InspectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InspectCubit, InspectState>(
        builder: (context, state) {
          return state.map<Widget>(
            initial: (v) => const Loading(
              message: 'Fetching transit feeds. It might take a long time...',
            ),
            loading: (v) => const Loading(
              message: 'Fetching transit feeds. It might take a long time...',
            ),
            error: (s) => Error(
              exception: s.exception,
              stackTrace: s.stackTrace,
            ),
            loadingContent: (s) => InspectBody(
              drawer: InspectBodyDrawer(
                fileNames: s.fileNames,
                selectedFileName: s.selectedFileName,
              ),
              content: Loading(
                message: 'Loading ${s.selectedFileName}',
              ),
            ),
            errorContent: (s) => InspectBody(
              drawer: InspectBodyDrawer(
                fileNames: s.fileNames,
                selectedFileName: s.selectedFileName,
              ),
              content: Error(
                exception: s.exception,
                stackTrace: s.stackTrace,
              ),
            ),
            content: (s) => InspectBody(
              drawer: InspectBodyDrawer(
                fileNames: s.fileNames,
                selectedFileName: s.selectedFileName,
              ),
              content: InspectBodyContent(csv: s.csv),
            ),
          );
        },
      ),
    );
  }
}

class InspectBodyDrawer extends StatelessWidget {
  const InspectBodyDrawer({
    super.key,
    required this.fileNames,
    required this.selectedFileName,
  });

  final List<String> fileNames;
  final String selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          for (final fileName in fileNames)
            ListTile(
              title: Text(fileName),
              onTap: () => context.read<InspectCubit>().showFile(fileName),
              selected: fileName == selectedFileName,
            ),
        ],
      ),
    );
  }
}

class InspectBodyContent extends StatelessWidget {
  const InspectBodyContent({super.key, required this.csv});

  final List<List<String>> csv;

  @override
  Widget build(BuildContext context) {
    if (csv.isEmpty) {
      return const Center(child: Text('GTFS is empty'));
    } else {
      final header = csv.first;
      return SfDataGrid(
        source: CSVDataSource(header: header, rows: csv.skip(1).toList()),
        columnWidthMode: ColumnWidthMode.fill,
        allowSorting: true,
        allowFiltering: true,
        columns: <GridColumn>[
          for (final cell in header)
            GridColumn(
              columnName: cell,
              label: Container(
                padding: const EdgeInsets.all(8),
                child: Text(cell),
              ),
            ),
        ],
      );
    }
  }
}

class CSVDataSource extends DataGridSource {
  CSVDataSource({
    required List<String> header,
    required List<List<String>> rows,
  }) {
    _rows = rows
        .map<DataGridRow>(
          (r) => DataGridRow(
            cells: [
              for (var i = 0; i < header.length; i++)
                DataGridCell<String>(columnName: header[i], value: r[i]),
            ],
          ),
        )
        .toList();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }
}

class InspectBody extends StatelessWidget {
  const InspectBody({
    super.key,
    required this.drawer,
    required this.content,
  });

  final Widget drawer;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        drawer,
        Expanded(
          child: PageTransitionSwitcher(
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(),
              clipBehavior: Clip.none,
              elevation: 0,
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(message ?? 'Loading...'),
          )
        ],
      ),
    );
  }
}

class Error extends StatelessWidget {
  const Error({super.key, required this.exception, this.stackTrace});

  final Object exception;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Error: $exception',
              textAlign: TextAlign.center,
            ),
          ),
          if (stackTrace != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Stacktrace: $stackTrace',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
