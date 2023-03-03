import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_browser/custom_image.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/pages/settings/main.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class FloatingBubble extends StatefulWidget {
  const FloatingBubble({super.key});

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  static Bubble makeBubble(String title, IconData icon, fn) {
    return Bubble(
      title: title,
      iconColor: Colors.white,
      bubbleColor: Colors.blue,
      icon: icon,
      titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
      onPress: fn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var webViewController = webViewModel.webViewController;
    var items = <Bubble>[
      makeBubble("새로고침", Icons.refresh, () {
        webViewController?.reload();
        _animationController.reverse();
      }),
      makeBubble("홈 화면", Icons.home, () {
        goUrl(WebUri("https://m.naver.com"));
        _animationController.reverse();
      }),
      makeBubble("히스토리", Icons.history, () {
        showHistory();
        _animationController.reverse();
      }),
      makeBubble("공유", Icons.share, () {
        share();
        _animationController.reverse();
      }),
      makeBubble("앱 설정", Icons.settings, () {
        goToSettingsPage();
        _animationController.reverse();
      }),
    ];

    return Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionBubble(
          // Menu items
          items: items,

          // animation controller
          animation: _animation,

          // On pressed change animation state
          onPress: () => _animationController.isCompleted
              ? _animationController.reverse()
              : _animationController.forward(),

          // Floating Action button Icon color
          iconColor: Colors.blue,

          // Flaoting Action button Icon
          iconData: Icons.add_box,
          backGroundColor: Colors.white,
        ));
  }

  void showHistory() {
    showDialog(
        context: context,
        builder: (context) {
          var webViewModel = Provider.of<WebViewModel>(context, listen: false);

          return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              content: FutureBuilder(
                future:
                    webViewModel.webViewController?.getCopyBackForwardList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  WebHistory history = snapshot.data as WebHistory;
                  return SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        children: history.list?.reversed.map((historyItem) {
                              var url = historyItem.url;

                              return ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // CachedNetworkImage(
                                    //   placeholder: (context, url) =>
                                    //       CircularProgressIndicator(),
                                    //   imageUrl: (url?.origin ?? "") + "/favicon.ico",
                                    //   height: 30,
                                    // )
                                    CustomImage(
                                        url: WebUri(
                                            "${url?.origin ?? ""}/favicon.ico"),
                                        maxWidth: 30.0,
                                        height: 30.0)
                                  ],
                                ),
                                title: Text(historyItem.title ?? url.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(url?.toString() ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                isThreeLine: true,
                                onTap: () async {
                                  goUrl(url!);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList() ??
                            <Widget>[],
                      ));
                },
              ));
        });
  }

  void share() {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var url = webViewModel.url;
    if (url != null) {
      Share.share(url.toString(), subject: webViewModel.title);
    }
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  void goUrl(WebUri url) async {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    await webViewModel.webViewController
        ?.loadUrl(urlRequest: URLRequest(url: url));
  }
}
