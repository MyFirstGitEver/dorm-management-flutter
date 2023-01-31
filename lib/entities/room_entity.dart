class RoomEntity{
  static String prefix = 'room';

  int id, capacity, currentStays;

  RoomEntity(this.id, this.capacity, this.currentStays);

  RoomEntity.fromJson(Map<String, dynamic> json) :
      id = json['id'], capacity = json['capacity'], currentStays = json['currentStays'];

  Map<String, dynamic> toJson() => {
    'id' : id,
    'capacity' : capacity,
    'currentStays' : currentStays
  };

  @override
  String toString() {
    return "$prefix$capacity-$id";
  }
}