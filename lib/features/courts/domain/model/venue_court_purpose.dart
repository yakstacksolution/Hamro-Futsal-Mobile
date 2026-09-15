/// Why `/auth/get-venue-courts` is being asked for the vendor's venues.
///
/// The same endpoint backs two screens with different needs, and the server
/// shapes its answer from this `purpose`: taking a walk-in booking wants the
/// venues and courts that can actually be booked, while the vendor's own
/// portfolio wants everything they own — including the courts that are
/// inactive, incomplete or still in onboarding.
///
/// Every caller states one. There is deliberately no default: which of the two
/// a screen wants is never incidental, and a wrong answer here shows up as
/// courts missing from a booking form, or hidden from their own owner.
enum VenueCourtPurpose {
  /// Taking a booking — the manual/walk-in booking form.
  booking('booking'),

  /// The vendor's own venues and courts — "Your venues".
  myVenues('my_venues');

  const VenueCourtPurpose(this.query);

  /// The value the endpoint's `purpose` query parameter takes.
  final String query;
}
