// File: lib/core/utils/firebase_mocks.dart

/// A mock class replicating cloud_firestore's Timestamp to keep models compile-safe.
class Timestamp {
  final int seconds;
  final int nanoseconds;

  const Timestamp(this.seconds, this.nanoseconds);

  factory Timestamp.now() {
    final now = DateTime.now();
    return Timestamp.fromDate(now);
  }

  factory Timestamp.fromDate(DateTime date) {
    return Timestamp(date.millisecondsSinceEpoch ~/ 1000, 0);
  }

  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  @override
  String toString() => 'Timestamp(seconds: $seconds, nanoseconds: $nanoseconds)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timestamp &&
          seconds == other.seconds &&
          nanoseconds == other.nanoseconds;

  @override
  int get hashCode => seconds.hashCode ^ nanoseconds.hashCode;
}

/// A mock class replicating cloud_firestore's DocumentSnapshot for local/memory data parsing.
class DocumentSnapshot {
  final String id;
  final Map<String, dynamic>? _data;

  const DocumentSnapshot(this.id, this._data);

  Map<String, dynamic>? data() => _data;
}
