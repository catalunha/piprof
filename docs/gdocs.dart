import 'package:flutter/material.dart';
import 'package:flutter_native_web/flutter_native_web.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
void main() => runApp(new MyApp());
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}
class _MyAppState extends State<MyApp> {
  WebController webController;
  FlutterNativeWeb flutterWebView;
  @override
  void initState() {
    this.webview();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
                Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
            title: Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              Column(
                children: <Widget>[
                  ListTile(title: Text("data"),),
                  Container(
                    child: flutterWebView,
                    height: 300.0,
                    width: 500.0,
                  ),
                ],
              ),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
  webview(){
      this.flutterWebView = new FlutterNativeWeb(
      onWebCreated: onWebCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => TapGestureRecognizer(),
                        ),
                      ].toSet(),
    );
    return;
  }
  void onWebCreated(webController) {
    this.webController = webController;
    this.webController.loadUrl("https://docs.google.com/document/d/16yTCmubD-IHu7VDhjFY4SGxWp9XYAjtW-I_2StafsD0/edit#heading=h.4nme0svt2xhv");
    this.webController.onPageStarted.listen((url) =>
        print("Loading $url")
    );
    this.webController.onPageFinished.listen((url) =>
        print("Finished loading $url")
    );
  }
}