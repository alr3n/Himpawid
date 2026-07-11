import 'dart:html' as html;

void loadGoogleMapsScript(String apiKey) {
  if (apiKey.isEmpty) return;
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..async = true
    ..defer = true;
  html.document.head!.append(script);
}
