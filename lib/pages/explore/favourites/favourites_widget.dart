import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/actions/get_location_and_air_quality.dart'
    show epaColor, epaCategory;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'favourites_model.dart';
export 'favourites_model.dart';

class FavouritesWidget extends StatefulWidget {
  const FavouritesWidget({super.key});

  static String routeName = 'Favourites';
  static String routePath = '/favourites';

  @override
  State<FavouritesWidget> createState() => _FavouritesWidgetState();
}

class _FavouritesWidgetState extends State<FavouritesWidget> {
  late FavouritesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _favourites = [];
  final Map<String, int> _aqiByLocation = {};
  List<actions.LocationResult>? _searchResults;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FavouritesModel());
    _loadFavourites();
  }

  void _loadFavourites() {
    final raw = currentUserDocument?.favouriteLocations ?? [];
    _favourites = raw
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
    _refreshAqi();
  }

  Future<void> _refreshAqi() async {
    await Future.wait(_favourites.map((fav) async {
      final lat = (fav['latitude'] as num).toDouble();
      final lon = (fav['longitude'] as num).toDouble();
      final aqi = await actions.fetchAqiForCoordinates(lat, lon);
      if (mounted) {
        setState(() {
          _aqiByLocation[fav['name'] as String] = aqi;
        });
      }
    }));
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searching = true);
    final results = await actions.searchLocation(query);
    if (mounted) {
      setState(() {
        _searching = false;
        _searchResults = results;
      });
    }
  }

  Future<void> _addFavourite(actions.LocationResult result) async {
    if (currentUserReference == null) return;
    final entry = {
      'name': result.name,
      'latitude': result.latitude,
      'longitude': result.longitude,
    };
    await currentUserReference!.update({
      'favourite_locations': FieldValue.arrayUnion([entry]),
    });
    setState(() {
      _favourites.add(entry);
      _searchResults = null;
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
    final aqi = await actions.fetchAqiForCoordinates(
        result.latitude, result.longitude);
    if (mounted) {
      setState(() => _aqiByLocation[result.name] = aqi);
    }
  }

  Future<void> _removeFavourite(Map<String, dynamic> fav) async {
    if (currentUserReference == null) return;
    await currentUserReference!.update({
      'favourite_locations': FieldValue.arrayRemove([fav]),
    });
    setState(() {
      _favourites.removeWhere((f) => f['name'] == fav['name']);
      _aqiByLocation.remove(fav['name']);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => context.safePop(),
                        child: Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: theme.slateDeep,
                            size: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.0),
                      Text(
                        'Favourites',
                        style: GoogleFonts.manrope(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(56.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Follow locations for timely air quality updates.',
                      style: GoogleFonts.manrope(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // ---------- Search ----------
                  Container(
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16.0),
                        Icon(Icons.search_rounded,
                            color: theme.secondaryText, size: 20.0),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _search(),
                            style: GoogleFonts.manrope(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search a city or place...',
                              hintStyle: GoogleFonts.manrope(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: theme.secondaryText,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14.0),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _search,
                          child: Container(
                            margin: EdgeInsets.all(6.0),
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 10.0, 16.0, 10.0),
                            decoration: BoxDecoration(
                              color: theme.lime,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: _searching
                                ? SizedBox(
                                    width: 16.0,
                                    height: 16.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: theme.raisinBlack,
                                    ),
                                  )
                                : Text(
                                    'Search',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w800,
                                      color: theme.raisinBlack,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_searchResults != null) ...[
                    SizedBox(height: 10.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: _searchResults!.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No matching places found.',
                                style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.secondaryText,
                                ),
                              ),
                            )
                          : Column(
                              children: _searchResults!
                                  .map((r) => InkWell(
                                        onTap: () => _addFavourite(r),
                                        child: Padding(
                                          padding: EdgeInsets.all(14.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.add_location_alt_outlined,
                                                  color: theme.slateDeep,
                                                  size: 18.0),
                                              SizedBox(width: 10.0),
                                              Expanded(
                                                child: Text(
                                                  r.name,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.primaryText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],

                  SizedBox(height: 24.0),
                  Text(
                    'YOUR FAVOURITES',
                    style: GoogleFonts.manrope(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: theme.secondaryText,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  if (_favourites.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Text(
                        'No favourites yet. Search above and tap a place to '
                        'follow its air quality.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: theme.secondaryText,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Column(
                        children: _favourites
                            .asMap()
                            .entries
                            .expand((entry) => [
                                  _favouriteRow(context, entry.value),
                                  if (entry.key < _favourites.length - 1)
                                    Divider(
                                      height: 1.0,
                                      indent: 16.0,
                                      endIndent: 16.0,
                                      color: theme.alternate,
                                    ),
                                ])
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _favouriteRow(BuildContext context, Map<String, dynamic> fav) {
    final theme = FlutterFlowTheme.of(context);
    final name = fav['name'] as String;
    final aqi = _aqiByLocation[name];
    final color = (aqi != null && aqi > 0) ? epaColor(aqi) : theme.secondaryText;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 8.0, 12.0),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: theme.slateDeep, size: 18.0),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: theme.primaryText,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 6.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Text(
              aqi == null
                  ? '...'
                  : (aqi > 0 ? '$aqi · ${epaCategory(aqi)}' : '--'),
              style: GoogleFonts.manrope(
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeFavourite(fav),
            icon: Icon(Icons.close_rounded, color: theme.secondaryText, size: 18.0),
          ),
        ],
      ),
    );
  }
}
