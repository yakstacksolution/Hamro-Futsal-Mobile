import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/public/data/model/help_video_model.dart';

void main() {
  test('empty staging response yields no videos', () {
    expect(
      HelpVideo.listFromResponse(<String, dynamic>{
        'status': 'success',
        'message': 'Videos fetched successfully.',
        'data': <String, dynamic>{'videos': <dynamic>[]},
      }),
      isEmpty,
    );
  });

  test('parses the /youtube-videos payload', () {
    final List<HelpVideo> videos = HelpVideo.listFromResponse(<String, dynamic>{
      'status': 'success',
      'message': 'Videos fetched successfully.',
      'data': <String, dynamic>{
        'videos': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 2,
            'title': 'Booking',
            'type': 'player',
            'url': 'https://www.youtube.com/watch?v=NY23x-9ZmRI',
            'youtube_id': 'NY23x-9ZmRI',
            'order_no': 2,
            'status': true,
          },
          <String, dynamic>{
            'id': 1,
            'title': 'Onboarding',
            'description': 'How to onboard venues and courts',
            'type': 'vendor',
            'url': 'https://www.youtube.com/watch?v=IzRbM-ZO6zE',
            'youtube_id': 'IzRbM-ZO6zE',
            'thumbnail_url':
                'https://img.youtube.com/vi/IzRbM-ZO6zE/hqdefault.jpg',
            'embed_url': 'https://www.youtube.com/embed/IzRbM-ZO6zE',
            'order_no': 1,
            'status': true,
          },
          <String, dynamic>{
            'id': 3,
            'title': 'Disabled',
            'youtube_id': 'AAAAAAAAAAA',
            'order_no': 0,
            'status': false,
          },
        ],
      },
    });

    expect(videos.map((HelpVideo v) => v.id), <String>['1', '2']);
    final HelpVideo onboarding = videos.first;
    expect(onboarding.youtubeId, 'IzRbM-ZO6zE');
    expect(onboarding.title, 'Onboarding');
    expect(onboarding.description, 'How to onboard venues and courts');
    expect(onboarding.audience, HelpVideoAudience.vendor);
    expect(onboarding.category, isNull);
    expect(onboarding.duration, isNull);
    expect(
      onboarding.thumbnailUrl,
      'https://img.youtube.com/vi/IzRbM-ZO6zE/hqdefault.jpg',
    );
    expect(videos[1].audience, HelpVideoAudience.player);
  });

  test('extracts the id from every YouTube link shape', () {
    const String id = 'NY23x-9ZmRI';
    for (final String link in <String>[
      id,
      'https://www.youtube.com/shorts/$id',
      'https://www.youtube.com/watch?v=$id&t=10s',
      'https://youtu.be/$id',
      'https://m.youtube.com/embed/$id',
      'https://www.youtube.com/live/$id',
    ]) {
      expect(HelpVideo.youtubeIdFrom(link), id, reason: link);
    }
    expect(HelpVideo.youtubeIdFrom('https://vimeo.com/123'), isNull);
    expect(HelpVideo.youtubeIdFrom(''), isNull);
  });

  test('parses, filters and orders items', () {
    final List<HelpVideo> videos = HelpVideo.listFromResponse(<String, dynamic>{
      'data': <String, dynamic>{
        'videos': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 2,
            'title': 'Adding courts',
            'youtube_url': 'https://youtu.be/AAAAAAAAAAA',
            'user_type': 'vendor',
            'duration': 222,
            'sort_order': 2,
          },
          <String, dynamic>{
            'id': 1,
            'title': 'Booking a court',
            'youtube_url': 'https://www.youtube.com/shorts/NY23x-9ZmRI',
            'category': <String, dynamic>{'name': 'Booking'},
            'audience': 'player',
            'sort_order': 1,
          },
          <String, dynamic>{
            'id': 3,
            'title': 'Welcome',
            'url': 'https://www.youtube.com/watch?v=BBBBBBBBBBB',
            'sort_order': 3,
          },
          // Dropped: no YouTube video, and switched off.
          <String, dynamic>{'id': 4, 'title': 'Broken', 'url': 'nope'},
          <String, dynamic>{
            'id': 5,
            'title': 'Hidden',
            'youtube_url': 'https://youtu.be/CCCCCCCCCCC',
            'status': 'inactive',
          },
        ],
      },
    });

    expect(videos.map((HelpVideo v) => v.id), <String>['1', '2', '3']);
    expect(videos[0].youtubeId, 'NY23x-9ZmRI');
    expect(videos[0].category, 'Booking');
    expect(videos[0].audience, HelpVideoAudience.player);
    expect(videos[1].duration, '3:42');
    expect(videos[1].audience, HelpVideoAudience.vendor);
    expect(videos[2].audience, HelpVideoAudience.all);
    expect(
      videos[2].thumbnailUrl,
      'https://img.youtube.com/vi/BBBBBBBBBBB/hqdefault.jpg',
    );

    // "All" guides show on both sides.
    expect(videos[2].audience.includes(HelpVideoAudience.player), isTrue);
    expect(videos[2].audience.includes(HelpVideoAudience.vendor), isTrue);
    expect(videos[1].audience.includes(HelpVideoAudience.player), isFalse);
  });
}
