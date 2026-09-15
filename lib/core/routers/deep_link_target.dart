/// A link the app knows how to open, parsed out of an incoming URI.
///
/// Parsing is kept separate from navigation so the URI shapes can be tested
/// without a router, a network call, or a platform channel.
sealed class DeepLinkTarget {
  const DeepLinkTarget();

  /// Reads one of the app's own links.
  ///
  /// Both shapes the backend hands out are accepted, since a shared message
  /// can carry either:
  ///
  /// * `https://hamrofutsal.com/venues/un-park-futsal?venue=38` — the web URL,
  ///   which is what stays clickable in a chat.
  /// * `hamrofutsal://venues/un-park-futsal` — the app scheme.
  ///
  /// Anything else returns null and is left to the OS.
  static DeepLinkTarget? parse(Uri uri) {
    final String scheme = uri.scheme.toLowerCase();
    final bool isAppScheme = scheme == 'hamrofutsal';
    final bool isWebLink =
        (scheme == 'https' || scheme == 'http') &&
        _knownHosts.contains(uri.host.toLowerCase());
    if (!isAppScheme && !isWebLink) return null;

    // The app scheme puts the collection in the authority
    // (`hamrofutsal://venues/<slug>`), the web URL in the path.
    final List<String> segments = <String>[
      if (isAppScheme && uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments,
    ].where((String segment) => segment.trim().isNotEmpty).toList();

    if (segments.isEmpty) return null;

    switch (segments.first.toLowerCase()) {
      case 'venues':
      case 'venue':
        final String slug = segments.length > 1 ? segments[1].trim() : '';
        // `?venue=38` is the reliable half: a slug can be renamed, an id
        // cannot, so the id wins when both are present.
        final int? id = int.tryParse(
          (uri.queryParameters['venue'] ??
                  uri.queryParameters['venue_id'] ??
                  '')
              .trim(),
        );
        if (slug.isEmpty && id == null) return null;
        return VenueDeepLink(slug: slug.isEmpty ? null : slug, id: id);
      default:
        return null;
    }
  }

  /// Reads an in-app location — the router path a link was turned into, or the
  /// route name the platform hands the engine on a cold start
  /// (`/venues/<slug>?venue=38`). Same shapes as [parse], minus the scheme.
  static DeepLinkTarget? parseLocation(String location) {
    final String trimmed = location.trim();
    if (trimmed.isEmpty || trimmed == '/') return null;

    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    if (uri.hasScheme) return parse(uri);

    // Rebuilt onto a known host so [parse] takes the same path for a bare
    // location as it does for a tapped web URL.
    return parse(
      Uri(
        scheme: 'https',
        host: 'hamrofutsal.com',
        pathSegments: uri.pathSegments,
        queryParameters: uri.queryParameters.isEmpty
            ? null
            : uri.queryParameters,
      ),
    );
  }

  static const Set<String> _knownHosts = <String>{
    'hamrofutsal.com',
    'www.hamrofutsal.com',
    'staging.hamrofutsal.com',
  };
}

/// A venue's detail page, identified by id and/or slug.
final class VenueDeepLink extends DeepLinkTarget {
  const VenueDeepLink({this.slug, this.id})
    : assert(slug != null || id != null, 'A venue link needs a slug or an id');

  final String? slug;
  final int? id;

  /// A search term for `GET /venues?search=…`.
  ///
  /// The listing searches names, and the slug is the name with hyphens, so the
  /// hyphens come back out: `un-park-futsal` → `un park futsal`.
  String? get searchTerm {
    final String? value = slug?.replaceAll('-', ' ').trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  /// The in-app location this link opens.
  String get location {
    final String path = '/venues/${slug ?? ''}';
    return id == null ? path : '$path?venue=$id';
  }

  @override
  bool operator ==(Object other) =>
      other is VenueDeepLink && other.id == id && other.slug == slug;

  @override
  int get hashCode => Object.hash(id, slug);

  @override
  String toString() => 'VenueDeepLink(id: $id, slug: $slug)';
}
