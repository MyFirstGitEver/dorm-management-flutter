class RoomInitializerEntity{
  static String prefix = 'init';

  int capacity;
  int total;


  RoomInitializerEntity(this.capacity, this.total);

  RoomInitializerEntity.fromJson(Map<String, dynamic> json) :
        capacity = json['capacity'], total = json['total'];

  Map<String, dynamic> toJson() => {
    'capacity' : capacity,
    'total' : total
  };

  @override
  String toString() {
    return "init$capacity";
  }
}