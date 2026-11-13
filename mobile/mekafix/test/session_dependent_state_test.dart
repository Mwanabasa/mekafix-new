import 'package:flutter_test/flutter_test.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';

void main() {
  late SessionState session;

  setUp(() {
    session = SessionState()
      ..token = 'token'
      ..user = AppUser(
        id: 1,
        phone: '256700000000',
        fullName: 'Test User',
        role: 'owner',
        isVerified: true,
      );
  });

  test('clears jobs, vehicles, and notifications when session changes', () {
    final state = JobsState()..bind(session);
    state.jobs.add(JobRequest({
      'id': 1,
      'kind': 'booking',
      'status': 'pending',
    }));
    state.vehicles.add({'plate': 'UAA 123A'});
    state.notifications.add({'title': 'New job'});

    session
      ..token = null
      ..user = null;
    state.bind(session);

    expect(state.jobs, isEmpty);
    expect(state.vehicles, isEmpty);
    expect(state.notifications, isEmpty);
  });

  test('clears mechanic results when session changes', () {
    final state = MechanicState()..bind(session);
    state.items.add(Mechanic(
      id: 1,
      garageName: 'Test Garage',
      specialty: '',
      services: const [],
      address: '',
      area: '',
      latitude: 0,
      longitude: 0,
      priceMin: 0,
      priceMax: 0,
      ratingAvg: 0,
      ratingCount: 0,
      isAvailable: true,
      isVerified: false,
      bio: '',
      phone: '',
    ));

    session
      ..token = null
      ..user = null;
    state.bind(session);

    expect(state.items, isEmpty);
  });
}
