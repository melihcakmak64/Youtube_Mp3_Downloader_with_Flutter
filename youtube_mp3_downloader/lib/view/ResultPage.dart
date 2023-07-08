import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../controller/service.dart';

class ResultPage extends StatefulWidget {
  final String searchTerm;

  const ResultPage({required this.searchTerm});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final DownloadController controller = Get.put(DownloadController());
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  String currentVideoUrl = "";

  @override
  void initState() {
    controller.searchVideos(widget.searchTerm);
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    controller.getList().clear();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.maxScrollExtent ==
        scrollController.position.pixels) {
      controller.getNextPage();
      print(controller.getList().length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Results'),
        ),
        body: Center(
          child: Obx(
            () {
              if (controller.getList().isEmpty) {
                return const CircularProgressIndicator();
              } else {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: controller.getList().length,
                  itemBuilder: (context, index) {
                    var video = controller.getList()[index];
                    return getCard(video);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Card getCard(Video video) {
    final duration = Duration(milliseconds: video.duration!.inMilliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final formattedDuration = hours > 0
        ? '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        leading: Image.network(video.thumbnails.mediumResUrl),
        title: Text(video.title + " ($formattedDuration)"),
        trailing: Obx(() {
          return controller.currentUrl.value == video.url
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    controller.download(video.url, video.title);
                  },
                );
        }),
      ),
    );
  }
}
