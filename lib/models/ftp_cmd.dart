import 'dart:convert';

FtpCmd ftpCmdFromJson(String str) => FtpCmd.fromJson(json.decode(str));

String ftpCmdToJson(FtpCmd data) => json.encode(data.toJson());

class FtpCmd {
  FtpCmd({
    required this.cmd,
    required this.body,
  });

  String cmd;
  String body;

  factory FtpCmd.fromJson(Map<String, dynamic> json) => FtpCmd(
        cmd: json["cmd"],
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "cmd": cmd,
        "body": body,
      };
}
