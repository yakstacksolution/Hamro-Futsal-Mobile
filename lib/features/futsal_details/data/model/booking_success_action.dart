/// What the checkout flow does once a booking has been created.
///
/// The funnel is entered from two very different places, and they want
/// opposite things when it ends, so the destination travels with the
/// navigation arguments instead of being guessed by the checkout page.
enum BookingSuccessAction {
  /// The normal journey (venue -> slots -> checkout): drop the funnel and open
  /// the new booking's details page on top of the bookings list.
  openBookingDetails,

  /// The caller is a wizard that needs the confirmed draft handed back to it
  /// (opponent-match requests, the vendor's manual booking form). The funnel
  /// pops with the draft as its result and nothing else is navigated.
  returnDraft,
}
