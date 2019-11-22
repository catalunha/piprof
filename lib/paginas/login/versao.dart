import 'package:flutter/material.dart';
import 'package:piprof/naosuportato/url_launcher.dart' if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/plataforma/recursos.dart';

class Versao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Versão & Suporte'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Recursos.instance.plataforma == 'android' ? Text("Versão 1.0.0") : Text("Build: 20191128"),
          ),
          ListTile(
            title: Text("Click aqui para suporte via WhatsApp no número +55 63 984495507"),
            trailing: Icon(Icons.phonelink_ring),
            onTap: () {
              try {
                launch('https://api.whatsapp.com/send?phone=5563984495507');
              } catch (e) {}
            },
          ),
          ListTile(
            title: Text('Tutorial'),
            trailing: Icon(Icons.help),
            onTap: () {
              try {
                launch('https://drive.google.com/open?id=142J7T2l_Ae8cT-NYL3rrWIVGAX03HfX7QO7VWk2NpEM');
              } catch (e) {}
            },
          ),
        ],
      ),
    );
  }
}
