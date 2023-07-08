import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:get/get.dart';

class DownloadController extends GetxController {
  final RxList<Video> _videoList = <Video>[].obs;
  VideoSearchList? searchResult;
  final YoutubeExplode youtube = YoutubeExplode();
  RxString currentUrl = "".obs;

  void download(String link, String name) async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      currentUrl.value = link;
      StreamManifest manifest =
          await youtube.videos.streamsClient.getManifest(link);
      AudioOnlyStreamInfo streamInfo = manifest.audioOnly.withHighestBitrate();
      if (streamInfo != null) {
        var stream = youtube.videos.streamsClient.get(streamInfo);
        var directory = await getExternalStorageDirectory();
        String downloadPath =
            '${directory!.parent.parent.parent.parent.path}/Download';
        await Directory(downloadPath).create(recursive: true);
        File file = File('$downloadPath/$name.mp3');
        var fileStream = file.openWrite();
        await stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();
        currentUrl.value = "";
      }
    } else {
      status = await Permission.storage.request();
    }
  }

  Future<RxList<Video>> searchVideos(String query) async {
    searchResult = await youtube.search(query);
    searchResult!.forEach((p0) {
      _videoList.add(p0);
    });

    return _videoList;
  }

  RxList<Video> getList() {
    return _videoList;
  }

  Future<void> getNextPage() async {
    searchResult = await searchResult!.nextPage();
    searchResult!.forEach((p0) {
      _videoList.add(p0);
    });
  }
}
