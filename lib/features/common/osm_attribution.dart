import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:url_launcher/url_launcher.dart';

/// The OpenStreetMap attribution every [FlutterMap] must carry: the "©
/// OpenStreetMap contributors" line linking to the copyright page, as ODbL and
/// the OSM tile policy require (audit F-H9). Drop it in as the last child of a
/// map's `children`.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  static final _copyright = Uri.parse(
    'https://www.openstreetmap.org/copyright',
  );

  @override
  Widget build(BuildContext context) {
    return RichAttributionWidget(
      showFlutterMapAttribution: false,
      attributions: [
        TextSourceAttribution(
          'OpenStreetMap contributors',
          onTap: () => launchUrl(
            _copyright,
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}

/// Process-wide in-memory tile cache. The OSM tile usage policy forbids hitting
/// the public CDN on every pan and zoom (audit F-H9); this keeps recently seen
/// tiles for the session. A persistent on-disk store (and, at real traffic, a
/// commercial or self-hosted tile source) is the follow-up.
final _tileCache = MemCacheStore(maxSize: 20 << 20); // ~20 MiB

/// The standard OSM [TileLayer] for this app: cached, with the required
/// User-Agent. Use everywhere instead of a bare `TileLayer(urlTemplate: ...)`.
TileLayer osmTileLayer() {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'app.racha',
    tileProvider: CachedTileProvider(store: _tileCache),
  );
}
