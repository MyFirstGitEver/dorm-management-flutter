class RenterEntity{
  static String prefix = 'renter';

  int id, roomId;
  bool isMale;
  String name, email, phoneNumber;

  RenterEntity(this.id, this.roomId, this.isMale, this.name, this.email, this.phoneNumber);

  RenterEntity.fromJson(Map<String, dynamic> json) :
        id = json['id'], roomId = json['roomId'], isMale = json['isMale'], name = json['name'],
        email = json['email'], phoneNumber = json['phoneNumber'];

  Map<String, dynamic> toJson() => {
    'id' : id,
    'roomId' : roomId,
    'isMale' : isMale,
    'name' : name,
    'email' : email,
    'phoneNumber' : phoneNumber
  };

  @override
  String toString() {
    return "renter$roomId-$id";
  }

  String getInfoInString(){
    return "Họ và tên: $name(${isMale ? "Nam" : "Nữ"})\n\nEmail: $email\n\nSố điện thoại: $phoneNumber";
  }

  void resetInformation(String name, email, phoneNumber){
    this.name = name;
    this.email = email;
    this.phoneNumber = phoneNumber;
    isMale = true;
  }

  RenterEntity clone(){
    return RenterEntity(id, roomId, isMale, name, email, phoneNumber);
  }
}