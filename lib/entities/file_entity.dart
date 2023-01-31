class FileEntity{
  static final folderIds = [0, 1];
  static const prefix = 'file';

  int id;
  String name, extension;
  String? alias;

  FileEntity(this.id, this.name, this.extension, this.alias);

  FileEntity.fromJson(Map<String, dynamic> json) :
        id = json['id'], name = json['name'], extension = json['extension'];

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'extension' : extension
  };

  @override
  String toString() {
    return 'file$id';
  }
}