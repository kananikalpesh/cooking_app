import 'dart:io';

 //const String IMAGE = "image";
 //const String VIDEO = "video";
 //const String PDF = "PDF";

class AttachmentModel {
  int id;
  String fileType;
  String filePath;
  String thumbnailPath;
  File localFile;
  String localThumbnail;
  //String localVideoThumbnail;

  AttachmentModel(
      {this.id,
      this.fileType,
      this.filePath,
      this.thumbnailPath,
      this.localFile,
        this.localThumbnail,
     }); // this.localVideoThumbnail

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return AttachmentModel(
      id: json["id"],
      fileType: json["type"],
      filePath: json["orig"],
      thumbnailPath: json["thumb"],
    );
  }

  void setLocalFile(File file){
    this.localFile = file;
  }

  void setId(int id){
    this.id = id;
  }

  /*static AttachmentFileType getAttachementType(String type){
    switch(type){
      case IMAGE:
        return AttachmentFileType.Image;
        break;
      case VIDEO:
        return AttachmentFileType.Video;
        break;
      case PDF:
        return AttachmentFileType.Document;
        break;
    }
  }*/

}

//enum AttachmentFileType { Image, Video, Document }
