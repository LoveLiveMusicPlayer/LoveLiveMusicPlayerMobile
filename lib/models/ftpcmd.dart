class FtpCommand {
  String cmd;
  FtpBody body;

  FtpCommand({required this.cmd, required this.body});

  factory FtpCommand.fromJson(Map<String, dynamic> json) =>
      FtpCommand(cmd: json["cmd"], body: FtpBody.fromJson(json["body"]));

  Map<String, dynamic> toJson() => {"cmd": cmd, "body": body};
}

class FtpBody {
  String? host;
  int? port;

  String? folderName;
  List<File>? fileList;

  FtpBody({this.host, this.port, this.folderName, this.fileList});

  factory FtpBody.fromJson(Map<String, dynamic> json) {
    List<File>? fileList;
    if (json['fileList'] != null) {
      var list = json['fileList'] as List;
      fileList = list.map((i) => File.fromJson(i)).toList();
    }
    return FtpBody(
        host: json["host"], port: json["port"], folderName: json["folderName"], fileList: fileList);
  }

  Map<String, dynamic> toJson() => {"host": host, "port": port, "folderName": folderName};
}

class File {
  String name;

  File({required this.name});

  factory File.fromJson(Map<String, dynamic> json) => File(name: json["name"]);

  Map<String, dynamic> toJson() => {"name": name};
}
