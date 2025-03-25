import 'package:chat_app/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

final _fileService = FileService();

class MediaFilesSettingScreen extends StatefulWidget {
  const MediaFilesSettingScreen({super.key});

  @override
  State<MediaFilesSettingScreen> createState() =>
      _MediaFilesSettingScreenState();
}

class _MediaFilesSettingScreenState extends State<MediaFilesSettingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _appBarAnimation;
  late Animation<Offset> _contentAnimtaion;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _appBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInBack,
      ),
    );

    _contentAnimtaion =
        Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _appBarAnimation,
          child: AppBar(
            title: Text(
              "Ảnh & file phương tiện",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
      body: SlideTransition(
        position: _contentAnimtaion,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
                onTap: () async =>
                    await OpenFile.open(_fileService.getMediaFilesDirectory()),
                title: Text("Thư mục lưu file"),
                subtitle: Text(_fileService.getMediaFilesDirectory()),
              ),
              ListTile(
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
                onTap: () {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Xoá tất cả các file"),
                        content: Text(
                            "Các file đã tải xuống sẽ không thể truy cập được sau khi xoá."),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              _fileService.deleteAllMediaFiles();
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color?>(
                                Colors.red[700],
                              ),
                            ),
                            child: Text(
                              "Xoá",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Huỷ"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                title: Text("Xoá tất cả các file"),
                textColor: Colors.red[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
