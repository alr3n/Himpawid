import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'lat_lng.dart' as latlng;

export 'lat_lng.dart' show LatLng;
export 'package:flutter_map/flutter_map.dart' show MapController;

/// MapTiler key used for both the map tiles below and geocoding (see
/// `get_location_and_air_quality.dart`) - MapTiler works with just an API
/// key, no billing account required, unlike Google Maps Platform.
String get kMapTilerApiKey => dotenv.env['MAPTILER_API_KEY'] ?? '';

/// MapTiler-hosted raster styles used in the app. Referenced by id in
/// https://api.maptiler.com/maps/{id}/{z}/{x}/{y}.png
enum MapTileStyle { airQuality, aqiLive }

const Map<MapTileStyle, String> _mapTileStyleIds = {
  MapTileStyle.airQuality: 'dataviz', // light, muted - dashboard preview card
  MapTileStyle.aqiLive: 'dataviz-dark', // dark - full-screen live AQI map
};

enum MapMarkerColor {
  red,
  orange,
  yellow,
  green,
  cyan,
  azure,
  blue,
  violet,
  magenta,
  rose,
}

const Map<MapMarkerColor, Color> mapMarkerColorMap = {
  MapMarkerColor.red: Color(0xFFE53935),
  MapMarkerColor.orange: Color(0xFFFB8C00),
  MapMarkerColor.yellow: Color(0xFFFDD835),
  MapMarkerColor.green: Color(0xFF43A047),
  MapMarkerColor.cyan: Color(0xFF00ACC1),
  MapMarkerColor.azure: Color(0xFF039BE5),
  MapMarkerColor.blue: Color(0xFF1E88E5),
  MapMarkerColor.violet: Color(0xFF8E24AA),
  MapMarkerColor.magenta: Color(0xFFD81B60),
  MapMarkerColor.rose: Color(0xFFEC407A),
};

class FlutterFlowMarker {
  const FlutterFlowMarker(this.markerId, this.location, [this.onTap]);
  final String markerId;
  final latlng.LatLng location;
  final Future Function()? onTap;
}

/// Live air-quality map, backed by MapTiler tiles instead of Google Maps -
/// MapTiler works immediately with just an API key (no Google Cloud billing
/// account needed), which is what made the map reliably loadable at all.
class FlutterFlowMap extends StatefulWidget {
  const FlutterFlowMap({
    required this.controller,
    this.onCameraIdle,
    this.initialLocation,
    this.markers = const [],
    this.markerColor = MapMarkerColor.red,
    this.style = MapTileStyle.airQuality,
    this.initialZoom = 12,
    this.allowInteraction = true,
    this.allowZoom = true,
    this.showLocation = true,
    this.centerMapOnMarkerTap = false,
    this.overlayLayers = const [],
    // Whether the map takes gesture preference over the surrounding page.
    // Useful when the map sits inside a scrolling widget and gestures
    // within the map shouldn't also scroll the page behind it.
    this.mapTakesGesturePreference = false,
    super.key,
  });

  final MapController controller;
  final Function(latlng.LatLng)? onCameraIdle;
  final latlng.LatLng? initialLocation;
  final Iterable<FlutterFlowMarker> markers;
  final MapMarkerColor markerColor;
  final MapTileStyle style;
  final double initialZoom;
  final bool allowInteraction;
  final bool allowZoom;
  final bool showLocation;
  final bool centerMapOnMarkerTap;
  /// Extra map layers drawn above the base tiles and below the markers -
  /// e.g. a live data overlay like the AQI color-wash tile layer.
  final List<Widget> overlayLayers;
  final bool mapTakesGesturePreference;

  @override
  State<StatefulWidget> createState() => _FlutterFlowMapState();
}

class _FlutterFlowMapState extends State<FlutterFlowMap> {
  latlong2.LatLng get initialPosition =>
      widget.initialLocation?.toMapTiler() ?? const latlong2.LatLng(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    final mapHasGesturePreference =
        widget.mapTakesGesturePreference && widget.allowInteraction;
    final styleId = _mapTileStyleIds[widget.style]!;

    final interactionFlags = widget.allowInteraction
        ? (widget.allowZoom
            ? InteractiveFlag.all
            : (InteractiveFlag.all & ~InteractiveFlag.pinchZoom &
                ~InteractiveFlag.doubleTapZoom &
                ~InteractiveFlag.scrollWheelZoom))
        : InteractiveFlag.none;

    final mapWidget = FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: widget.initialZoom,
        interactionOptions: InteractionOptions(flags: interactionFlags),
        onMapEvent: (event) {
          if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
            widget.onCameraIdle?.call(event.camera.center.toLatLng());
          }
        },
      ),
      children: [
        TileLayer(
          // MapTiler serves 512px tiles by default when no size is given
          // in the path, but flutter_map's TileLayer assumes 256px tiles
          // unless told otherwise - that mismatch renders the map at the
          // wrong effective zoom. The explicit /256/ segment keeps the
          // fetched tile size and flutter_map's assumption in sync.
          urlTemplate:
              'https://api.maptiler.com/maps/$styleId/256/{z}/{x}/{y}.png?key=$kMapTilerApiKey',
          userAgentPackageName: 'com.himpawid.app',
          maxNativeZoom: 20,
        ),
        ...widget.overlayLayers,
        if (widget.showLocation && widget.initialLocation != null)
          MarkerLayer(markers: [
            Marker(
              point: initialPosition,
              width: 22.0,
              height: 22.0,
              child: _LocationDot(),
            ),
          ]),
        MarkerLayer(
          markers: widget.markers
              .map(
                (m) => Marker(
                  point: m.location.toMapTiler(),
                  width: 34.0,
                  height: 34.0,
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.centerMapOnMarkerTap) {
                        widget.controller.move(
                          m.location.toMapTiler(),
                          widget.controller.camera.zoom,
                        );
                        widget.onCameraIdle?.call(m.location);
                      }
                      await m.onTap?.call();
                    },
                    child:
                        _MarkerPin(color: mapMarkerColorMap[widget.markerColor]!),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );

    return AbsorbPointer(
      absorbing: !widget.allowInteraction,
      child: mapHasGesturePreference
          ? GestureDetector(
              onVerticalDragStart: (_) {},
              behavior: HitTestBehavior.opaque,
              child: mapWidget,
            )
          : mapWidget,
    );
  }
}

class _MarkerPin extends StatelessWidget {
  const _MarkerPin({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x4D000000),
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
    );
  }
}

class _LocationDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F6FED),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6.0,
            color: Color(0x552F6FED),
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
    );
  }
}

extension ToMapTilerLatLng on latlng.LatLng {
  latlong2.LatLng toMapTiler() => latlong2.LatLng(latitude, longitude);
}

extension MapTilerToLatLng on latlong2.LatLng {
  latlng.LatLng toLatLng() => latlng.LatLng(latitude, longitude);
}
