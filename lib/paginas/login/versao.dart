import 'package:flutter/material.dart';
import 'package:piprof/naosuportato/url_launcher.dart' if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/plataforma/recursos.dart';

class Versao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Versão & Sobre'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Recursos.instance.plataforma == 'android' ? Text("Versão 1.0.0") : Text("Build: 20191128"),
          ),
          ListTile(
            title: Text('Tutorial'),
            trailing: Icon(Icons.help),
            onTap: () {
              launch('https://drive.google.com/open?id=142J7T2l_Ae8cT-NYL3rrWIVGAX03HfX7QO7VWk2NpEM');
            },
          ),
        ],
      ),
    );
  }
}
