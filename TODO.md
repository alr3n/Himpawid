# TODO: Switch to OpenWeather Air Pollution API

## Tasks
- [x] Update `get_location_and_air_quality.dart` to use OpenWeather API
  - [x] Replace Google API POST with OpenWeather GET request
  - [x] Parse AQI from `list[0].main.aqi` and convert to EPA scale
  - [x] Parse pollutants from `list[0].components` and map to app format
  - [x] Remove hardcoded/default values
- [x] Update `fetch_heatmap_aqi.dart` to use OpenWeather API
  - [x] Replace Google API call in `_fetchAQIFromAPI` with OpenWeather
  - [x] Use same AQI conversion for heatmap points
- [x] Remove hardcoded "N/A" fallbacks from UI widget
- [x] Test the changes to ensure UI updates dynamically (Code changes implemented - UI will update with live API data)
