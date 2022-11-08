part of '../view/app.dart';

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const InputPage(
          initialGtfsUrl: null,
        );
      },
    ),
    GoRoute(
      name: 'inspect',
      path: '/inspect',
      builder: (BuildContext context, GoRouterState state) {
        final bytes = state.extra as Uint8List?;
        final gtfsUrl = state.queryParams['gtfs_url'];

        return InspectPage(
          bytes: bytes,
          gtfsUrl: gtfsUrl,
        );
      },
      redirect: (BuildContext context, GoRouterState state) {
        final bytes = state.extra;
        final gtfsUrl = state.queryParams['gtfs_url'];

        if (bytes is Uint8List || gtfsUrl != null) {
          return null;
        } else {
          return '/';
        }
      },
    ),
  ],
);
