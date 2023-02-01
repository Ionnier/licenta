class TimelineRepository {
  static final TimelineRepository _singleton = TimelineRepository._internal();

  factory TimelineRepository() {
    return _singleton;
  }

  TimelineRepository._internal();
}
