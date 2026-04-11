import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/theme.dart';

enum BookingStatus { confirmed, pending, paid, cancelled }

class _Booking {
  const _Booking({
    required this.teamName,
    required this.courtName,
    required this.schedule,
    required this.bookedAt,
    required this.amount,
    required this.status,
  });

  final String teamName;
  final String courtName;
  final String schedule;
  final String bookedAt;
  final String amount;
  final BookingStatus status;

  String get initials {
    final parts = teamName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '--';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.paid:
        return 'Paid';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.confirmed:
        return LightColor.skyBlue;
      case BookingStatus.pending:
        return LightColor.orange;
      case BookingStatus.paid:
        return LightColor.secondaryGreen;
      case BookingStatus.cancelled:
        return LightColor.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.access_time_filled_rounded;
      case BookingStatus.paid:
        return Icons.verified_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

class _Summary {
  const _Summary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class RecentBookingsWidget extends StatelessWidget {
  const RecentBookingsWidget({super.key});

  static const List<_Booking> _bookings = [
    _Booking(
      teamName: 'Rabin FC',
      courtName: 'Arena A',
      schedule: 'Today • 6:00 – 7:00 PM',
      bookedAt: '8 min ago',
      amount: 'NPR 1,800',
      status: BookingStatus.confirmed,
    ),
    _Booking(
      teamName: 'KTM Strikers',
      courtName: 'Arena B',
      schedule: 'Today • 7:30 – 9:00 PM',
      bookedAt: '21 min ago',
      amount: 'NPR 2,400',
      status: BookingStatus.pending,
    ),
    _Booking(
      teamName: 'Shivam Futsal',
      courtName: 'Training Turf',
      schedule: 'Tomorrow • 5:30 – 6:30 AM',
      bookedAt: 'Just now',
      amount: 'NPR 1,600',
      status: BookingStatus.paid,
    ),
  ];

  static const List<_Summary> _summaries = [
    _Summary(
      label: 'New Today',
      value: '08',
      icon: Icons.add_task_rounded,
      color: LightColor.skyBlue,
    ),
    _Summary(
      label: 'Revenue',
      value: 'NPR 17.8k',
      icon: Icons.payments_rounded,
      color: LightColor.secondaryGreen,
    ),
    _Summary(
      label: 'Pending',
      value: '02',
      icon: Icons.timelapse_rounded,
      color: LightColor.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(),
        const SizedBox(height: 16),

        Row(
          children: List.generate(_summaries.length, (index) {
            final item = _summaries[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == _summaries.length - 1 ? 0 : 10,
                ),
                child: _SummaryCard(summary: item, surface: surface),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _BookingTile(booking: _bookings[index]);
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: LightColor.skyBlue,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Recent Bookings',
            style: AppTheme.h6Style.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.titleTextColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: LightColor.skyBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style: AppTheme.subTitleStyle.copyWith(
                    color: LightColor.skyBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: LightColor.skyBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.surface});

  final _Summary summary;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(summary.icon, color: summary.color, size: 18),
          const SizedBox(height: 4),
          Text(
            summary.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.titleStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: LightColor.titleTextColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            summary.label,
            style: AppTheme.subTitleStyle.copyWith(
              fontSize: 10,
              color: LightColor.darkgrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final _Booking booking;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow,
        border: Border.all(
          color: booking.statusColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _BookingAvatar(booking: booking),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.titleStyle.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: LightColor.titleTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.bookedAt,
                      style: AppTheme.subTitleStyle.copyWith(
                        fontSize: 11,
                        color: LightColor.subTitleTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(booking: booking),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.stadium_outlined,
                      size: 16,
                      color: LightColor.darkgrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.courtName,
                        style: AppTheme.subTitleStyle.copyWith(
                          color: LightColor.titleTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: LightColor.darkgrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.schedule,
                        style: AppTheme.subTitleStyle.copyWith(
                          color: LightColor.darkgrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: LightColor.skyBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 14,
                      color: LightColor.skyBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Booking Fee',
                      style: AppTheme.subTitleStyle.copyWith(
                        fontSize: 10.5,
                        color: LightColor.skyBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                booking.amount,
                style: AppTheme.titleStyle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: LightColor.titleTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingAvatar extends StatelessWidget {
  const _BookingAvatar({required this.booking});

  final _Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            booking.statusColor.withOpacity(0.18),
            booking.statusColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          booking.initials,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: booking.statusColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.booking});

  final _Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: booking.statusColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(booking.statusIcon, size: 13, color: booking.statusColor),
          const SizedBox(width: 5),
          Text(
            booking.statusLabel,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: booking.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';
// import 'package:hamro_footsall/core/theme/theme.dart';

// enum BookingStatus { confirmed, pending, paid, cancelled }

// class _Booking {
//   const _Booking({
//     required this.teamName,
//     required this.courtName,
//     required this.schedule,
//     required this.bookedAt,
//     required this.amount,
//     required this.status,
//   });

//   final String teamName;
//   final String courtName;
//   final String schedule;
//   final String bookedAt;
//   final String amount;
//   final BookingStatus status;

//   String get initials {
//     final String compactName = teamName.replaceAll(RegExp(r'\s+'), '');
//     if (compactName.isEmpty) {
//       return '--';
//     }
//     if (compactName.length == 1) {
//       return compactName.toUpperCase();
//     }
//     return compactName.substring(0, 2).toUpperCase();
//   }

//   String get statusLabel {
//     switch (status) {
//       case BookingStatus.confirmed:
//         return 'Confirmed';
//       case BookingStatus.pending:
//         return 'Pending';
//       case BookingStatus.paid:
//         return 'Paid';
//       case BookingStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   Color get statusColor {
//     switch (status) {
//       case BookingStatus.confirmed:
//         return LightColor.skyBlue;
//       case BookingStatus.pending:
//         return LightColor.orange;
//       case BookingStatus.paid:
//         return LightColor.secondaryGreen;
//       case BookingStatus.cancelled:
//         return LightColor.red;
//     }
//   }
// }

// class _Summary {
//   const _Summary({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
// }

// class RecentBookingsWidget extends StatelessWidget {
//   const RecentBookingsWidget({super.key});

//   static const List<_Booking> _bookings = [
//     _Booking(
//       teamName: 'Rabin FC',
//       courtName: 'Arena A',
//       schedule: 'Today • 6:00 – 7:00 PM',
//       bookedAt: '8 min ago',
//       amount: 'NPR 1,800',
//       status: BookingStatus.confirmed,
//     ),
//     _Booking(
//       teamName: 'KTM Strikers',
//       courtName: 'Arena B',
//       schedule: 'Today • 7:30 – 9:00 PM',
//       bookedAt: '21 min ago',
//       amount: 'NPR 2,400',
//       status: BookingStatus.pending,
//     ),
//     _Booking(
//       teamName: 'Shivam Futsal',
//       courtName: 'Training Turf',
//       schedule: 'Tomorrow • 5:30 – 6:30 AM',
//       bookedAt: 'Just now',
//       amount: 'NPR 1,600',
//       status: BookingStatus.paid,
//     ),
//   ];

//   static const List<_Summary> _summaries = [
//     _Summary(
//       label: 'New Today',
//       value: '08',
//       icon: Icons.add_task_rounded,
//       color: LightColor.skyBlue,
//     ),
//     _Summary(
//       label: 'Revenue',
//       value: 'NPR 17.8k',
//       icon: Icons.payments_rounded,
//       color: LightColor.secondaryGreen,
//     ),
//     _Summary(
//       label: 'Pending',
//       value: '02',
//       icon: Icons.timelapse_rounded,
//       color: LightColor.orange,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Recent Bookings',
//               style: AppTheme.h6Style.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: LightColor.titleTextColor,
//               ),
//             ),
//             Text(
//               'View all',
//               style: AppTheme.subTitleStyle.copyWith(
//                 color: LightColor.skyBlue,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 14),

//         Row(
//           children: List.generate(_summaries.length, (i) {
//             final s = _summaries[i];
//             return Expanded(
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   right: i < _summaries.length - 1 ? 10 : 0,
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 14,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: AppTheme.shadow,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(s.icon, color: s.color, size: 18),
//                       const SizedBox(height: 10),
//                       Text(
//                         s.value,
//                         style: AppTheme.h6Style.copyWith(
//                           fontWeight: FontWeight.w500,
//                           color: LightColor.titleTextColor,
//                           letterSpacing: -0.3,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         s.label,
//                         style: AppTheme.subTitleStyle.copyWith(
//                           fontSize: 11,
//                           color: LightColor.darkgrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),

//         const SizedBox(height: 20),

//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _bookings.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 10),
//           itemBuilder: (context, index) =>
//               _BookingTile(booking: _bookings[index]),
//         ),
//       ],
//     );
//   }
// }

// // class _BookingTile extends StatelessWidget {
// //   const _BookingTile({required this.booking});
// //   final _Booking booking;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: Theme.of(context).colorScheme.surface,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: AppTheme.shadow,
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 44,
// //             height: 44,
// //             decoration: BoxDecoration(
// //               color: booking.statusColor.withOpacity(0.10),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 booking.teamName.substring(0, 2).toUpperCase(),
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w800,
// //                   color: booking.statusColor,
// //                 ),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(width: 12),

// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   booking.teamName,
// //                   style: AppTheme.titleStyle.copyWith(
// //                     fontWeight: FontWeight.w700,
// //                     color: LightColor.titleTextColor,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 3),
// //                 Text(
// //                   '${booking.courtName}  •  ${booking.schedule}',
// //                   style: AppTheme.subTitleStyle.copyWith(
// //                     color: LightColor.darkgrey,
// //                     fontSize: 11.5,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   booking.bookedAt,
// //                   style: AppTheme.subTitleStyle.copyWith(
// //                     color: LightColor.subTitleTextColor,
// //                     fontSize: 11,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(width: 10),

// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               Text(
// //                 booking.amount,
// //                 style: AppTheme.titleStyle.copyWith(
// //                   fontWeight: FontWeight.w800,
// //                   color: LightColor.titleTextColor,
// //                 ),
// //               ),
// //               const SizedBox(height: 6),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                 decoration: BoxDecoration(
// //                   color: booking.statusColor.withOpacity(0.10),
// //                   borderRadius: BorderRadius.circular(6),
// //                 ),
// //                 child: Text(
// //                   booking.statusLabel,
// //                   style: TextStyle(
// //                     fontSize: 10.5,
// //                     fontWeight: FontWeight.w700,
// //                     color: booking.statusColor,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class _BookingTile extends StatelessWidget {
//   const _BookingTile({required this.booking});
//   final _Booking booking;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: AppTheme.shadow,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: booking.statusColor.withValues(alpha: 0.10),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 booking.initials,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w800,
//                   color: booking.statusColor,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   booking.teamName,
//                   style: AppTheme.titleStyle.copyWith(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: LightColor.titleTextColor,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _BookingInfoChip(
//                       icon: Icons.stadium_outlined,
//                       label: booking.courtName,
//                     ),
//                     _BookingInfoChip(
//                       icon: Icons.schedule_rounded,
//                       label: booking.schedule,
//                     ),
//                   ],
//                 ),
//                 // const SizedBox(height: 6),
//                 // Text(
//                 //   booking.bookedAt,
//                 //   style: AppTheme.subTitleStyle.copyWith(
//                 //     fontSize: 10,
//                 //     color: LightColor.subTitleTextColor,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 10),

//           SizedBox(
//             width: 78,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   booking.amount,
//                   style: AppTheme.titleStyle.copyWith(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                     color: LightColor.titleTextColor,
//                   ),
//                   textAlign: TextAlign.right,
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: booking.statusColor.withValues(alpha: 0.10),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     booking.statusLabel,
//                     style: TextStyle(
//                       fontSize: 8.5,
//                       fontWeight: FontWeight.w700,
//                       color: booking.statusColor,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 Text(
//                   booking.bookedAt,
//                   style: AppTheme.subTitleStyle.copyWith(
//                     fontSize: 10,
//                     color: LightColor.subTitleTextColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BookingInfoChip extends StatelessWidget {
//   const _BookingInfoChip({required this.icon, required this.label});

//   final IconData icon;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//       decoration: BoxDecoration(
//         color: LightColor.background,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: LightColor.darkgrey),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: AppTheme.subTitleStyle.copyWith(
//               fontSize: 10,
//               color: LightColor.darkgrey,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
