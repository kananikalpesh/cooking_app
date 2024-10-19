import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

enum Level { INFO, WARNING, ERROR, SEVERE }

extension LevelEx on Level {
  String getLogLevel() {
    switch (this) {
      case Level.INFO:
        return "INFO";
      case Level.WARNING:
        return "WARNING";
      case Level.ERROR:
        return "ERROR";
      case Level.SEVERE:
        return "SEVERE";
    }
  }
}

class LogManager {
  static final LogManager _instance = new LogManager._internal();

  factory LogManager() => _instance;

  LogManager._internal();

  String path = "";
  File get _file => File('$path/logger.txt');

  File get log5 => File("$path/logger_5.txt");
  File get log4 => File("$path/logger_4.txt");
  File get log3 => File("$path/logger_3.txt");
  File get log2 => File("$path/logger_2.txt");

  void setup() async {
    path = (await getApplicationDocumentsDirectory()).path + "/logs";
    if (_file.existsSync()){
        var length = _file.lengthSync();
        if (length != null && length > 10 * 1024 * 1024) {

          if (log5.existsSync()) {
            await log5.delete();
          }

          if (log4.existsSync()) {
            await log4.rename(log5.path);
          }

          if (log3.existsSync()) {
            await log3.rename(log4.path);
          }

          if (log2.existsSync()) {
            await log2.rename(log3.path);
          }

          await _file.rename(log2.path);

        }
    }else{
      _file.create(recursive: true);
    }
  }

  void log(String className, String functionName, String message,
      {Level logLevel = Level.INFO, dynamic e}) async {
    var statement = "";
    if (e is Error) {
      statement = "${DateTime.now()}, ${logLevel.getLogLevel()}, $className, $functionName, $message, ${e.toString()}, ${e.stackTrace.toString()}\n";
    } else if (e is Exception) {
      statement = "${DateTime.now()}, ${logLevel.getLogLevel()}, $className, $functionName, $message, ${e.toString()} \n";
    } else {
      statement = "${DateTime.now()}, ${logLevel.getLogLevel()}, $className, $functionName, $message\n";

    }
    await _file.writeAsString(statement, mode: FileMode.append);
  }

  Future<File> getReportZip() async {
    List zipList = [];

    if (log5.existsSync()) {
      zipList.add(log5);
    }

    if (log4.existsSync()) {
      zipList.add(log4);
    }

    if (log3.existsSync()) {
      zipList.add(log3);
    }

    if (log2.existsSync()) {
      zipList.add(log2);
    }

    if (_file.existsSync()) {
      zipList.add(_file);
    }

    if (zipList.length == 0) {
      return null;
    }

    var encoder = ZipFileEncoder();
    var zipPath = (await getApplicationDocumentsDirectory()).path + "/reportIssue.zip";
    encoder.create(zipPath);

    zipList.forEach((element) {
      encoder.addFile(element);
    });
    encoder.close();

    File reportZip = File(zipPath);

    if(reportZip.existsSync())
      return reportZip;
    else
      return null;
  }

  Future<void> deleteZip(file) async {
    if (file.existsSync()) {
    //  await file.delete();
    }
  }

}
