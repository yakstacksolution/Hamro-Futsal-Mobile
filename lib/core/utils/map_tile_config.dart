final class MapTileConfig {
  const MapTileConfig._();

  static const String urlTemplate =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  static const List<String> subdomains = <String>['a', 'b', 'c', 'd'];
  static const String userAgentPackageName = 'com.hamro.futsal';
  static const String attribution = '© OpenStreetMap contributors © CARTO';
}
