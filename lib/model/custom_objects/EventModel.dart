
class EventModel<T extends Object> {
  final String eventType;
  final T data;
  EventModel(this.eventType, {this.data});
}