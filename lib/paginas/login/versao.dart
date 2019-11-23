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
            title: Recursos.instance.plataforma == 'android' ? Text("Versão Android: 1.0.0") : Text("Versão Chrome: 1.0.1"),
          ),
          ListTile(
            title: Text("Suporte via WhatsApp pelo número +55 63 984495507"),
            trailing: Icon(Icons.phonelink_ring),
          ),
          ListTile(
            title: Text("Suporte via email em brintec.education@gmail.com"),
            trailing: Icon(Icons.email),
          ),
          ListTile(
            title: Text('Click aqui para ir ao tutorial'),
            trailing: Icon(Icons.help),
            onTap: () {
              try {
                launch('https://drive.google.com/open?id=142J7T2l_Ae8cT-NYL3rrWIVGAX03HfX7QO7VWk2NpEM');
              } catch (e) {}
            },
          ),
          Container(
                alignment: Alignment.center,
                child: Image.asset('assets/imagem/logo2.png'),
              ),
        ],
      ),
    );
  }
}
