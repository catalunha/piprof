import 'dart:io';
// import 'dart:io' if (dart.library.io) 'package:piprof/naosuportato/empty.dart';
// import 'package:piprof/naosuportato/empty.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/usuario/perfil_bloc.dart';
import 'package:piprof/plataforma/recursos.dart';
import 'package:piprof/naosuportato/naosuportado.dart'
    show FilePicker, FileType;

class PerfilPage extends StatefulWidget {
  final AuthBloc authBloc;

  const PerfilPage(this.authBloc);

  @override
  State<StatefulWidget> createState() {
    return ConfiguracaoState(authBloc);
  }
}

class ConfiguracaoState extends State<PerfilPage> {
  final PerfilBloc bloc;

  ConfiguracaoState(AuthBloc authBloc)
      : bloc = PerfilBloc(Bootstrap.instance.firestore, authBloc);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AtualizarCelular(bloc),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AtualizarCracha(bloc),
            ),
            FotoUsuario(bloc),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bloc.eventSink(SaveEvent());
          Navigator.pop(context);
        },
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}

class AtualizarCelular extends StatefulWidget {
  final PerfilBloc bloc;

  const AtualizarCelular(this.bloc);

  @override
  State<StatefulWidget> createState() {
    return AtualizarNumeroCelularState(bloc);
  }
}

class AtualizarNumeroCelularState extends State<AtualizarCelular> {
  final PerfilBloc bloc;

  final _controller = TextEditingController();

  AtualizarNumeroCelularState(this.bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PerfilState>(
        stream: bloc.stateStream,
        builder: (context, snapshot) {
          if (_controller.text == null || _controller.text.isEmpty) {
            _controller.text = snapshot.data?.celular;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Atualizar número do celular",
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
              TextField(
                controller: _controller,
                onChanged: (celular) {
                  bloc.eventSink(UpdateCelularEvent(celular));
                },
              ),
            ],
          );
        });
  }
}

class AtualizarCracha extends StatefulWidget {
  final PerfilBloc bloc;

  AtualizarCracha(this.bloc);

  @override
  State<StatefulWidget> createState() {
    return AtualizarNomeNoProjetoState(bloc);
  }
}

class AtualizarNomeNoProjetoState extends State<AtualizarCracha> {
  final PerfilBloc bloc;

  final _controller = TextEditingController();

  AtualizarNomeNoProjetoState(this.bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PerfilState>(
        stream: bloc.stateStream,
        builder: (context, snapshot) {
          if (_controller.text == null || _controller.text.isEmpty) {
            _controller.text = snapshot.data?.cracha;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Atualizar nome curto para crachá",
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
              TextField(
                controller: _controller,
                onChanged: (cracha) {
                  bloc.eventSink(UpdateCrachaEvent(cracha));
                },
              ),
            ],
          );
        });
  }
}

class FotoUsuario extends StatelessWidget {
  String fotoUrl;
  String localPath;
  final PerfilBloc bloc;

  FotoUsuario(this.bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PerfilState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<PerfilState> snapshot) {
        if (snapshot.hasError) {
          return Container(
            child: Center(child: Text('Erro.')),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (Recursos.instance.disponivel("file_picking"))
              Wrap(children: <Widget>[
                Text(
                  'Atualizar foto. Destaque exclussivamente sua cabeça, evitando paisagem ao fundo e acessórios na face. Favorece reconhecimento facial.',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
                ListTile(
                  title: Text(
                    'Selecione no dispositivo',
                  ),
                  trailing: Icon(Icons.file_download),
                  onTap: () async {
                    await _selecionarNovoArquivo().then((localPath) {
                      bloc.eventSink(
                        UpdateFotoEvent(localPath),
                      );
                    });
                  },
                ),
              ]),
            if (Recursos.instance.disponivel("file_picking"))
              _ImagemFileUpload(
                url: snapshot.data?.fotoUrl,
                path: snapshot.data?.localPath,
              ),
          ],
        );
      },
    );
  }

  Future<String> _selecionarNovoArquivo() async {
    try {
      var arquivoPath = await FilePicker.getFilePath(type: FileType.IMAGE);
      if (arquivoPath != null) {
        return arquivoPath;
      }
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
    return null;
  }
}

class _ImagemFileUpload extends StatelessWidget {
  // final String uploadID;
  final String url;
  final String path;

  const _ImagemFileUpload({this.url, this.path});

  Future<File> _getLocalFile(String filename) async {
    File f = new File(filename);
    return f;
  }

  @override
  Widget build(BuildContext context) {
    // print('url: $url');
    // print('path: $path');
    Widget foto = Text('?');
    Widget msg = Text('');

    if (path == null && url == null) {
      foto = Text('Você ainda não enviou uma foto de perfil.');
    }
    if (path != null && url == null) {
      try {
        foto = FutureBuilder(
            future: _getLocalFile(path),
            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
              return snapshot.data != null
                  ? new Image.file(snapshot.data)
                  : new Container();
            });
      } on Exception {
        msg = ListTile(
          title: Text('Não consegui abrir a imagem.'),
        );
      } catch (e) {
        msg = ListTile(
          title: Text('Não consegui abrir a imagem.'),
        );
      }
      msg = Text(
          'Esta foto precisa ser enviada. Salve esta edição de perfil e depois acesse o menu upload de arquivos para enviar esta imagem.');
    }
    if (url != null) {
      try {
        foto = Container(
            child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.network(url),
        ));
      } on Exception {
        print('Exception');
        msg = ListTile(
          title: Text('Não consegui abrir a imagem.'),
        );
      } catch (e) {
        print('catch');
        msg = ListTile(
          title: Text('Não consegui abrir a imagem.'),
        );
      }
    }

    return Column(
      children: <Widget>[
        msg,
        Row(
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Expanded(
              flex: 8,
              child: foto,
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ],
    );
  }
}

// class ArquivoImagemItem extends StatelessWidget {
//   final String nome;
//   String localPath;
//   final String url;
//   final Function() onDeleted;

//   ArquivoImagemItem(
//     this.nome, {
//     Key key,
//     this.onDeleted,
//     this.localPath,
//     this.url,
//   })  : assert(localPath != null || url != null),
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     print('url: $url');
//     print('localPath: $localPath');
//     // localPath='/storage/emulated/0/DCIM/Camera/IMG_20191120_085428.jpg';
//     return Card(
//       child: Container(
//         constraints: BoxConstraints.expand(
//           height: 150.0,
//         ),
//         padding: EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             // image: url != null ? NetworkImage(url) : AssetImage('/storage/emulated/0/DCIM/Camera/IMG_20191120_085428.jpg'),
//             image: url != null ? NetworkImage(url) : AssetImage(localPath),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               left: 0.0,
//               bottom: 0.0,
//               child: Text(nome,
//                   style: TextStyle(
//                     color: Colors.yellow,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12.0,
//                   )),
//             ),
//             Positioned(
//                 right: 0.0,
//                 bottom: 0.0,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(40.0),
//                   child: Container(
//                     color: Colors.white,
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.delete,
//                         color: Colors.black,
//                       ),
//                       onPressed: onDeleted,
//                     ),
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ImagemPerfilUpload extends StatelessWidget {
//   final String uploadID;
//   final String url;
//   final String path;

//   const _ImagemPerfilUpload({this.uploadID, this.url, this.path});

//   @override
//   Widget build(BuildContext context) {
//         print('url: $url');
//     print('path: $path');

//     Widget foto = Text('?');
//     Widget msg = Text('');

//     if (path == null && url == null) {
//       foto = Text('Você ainda não enviou uma foto de perfil.');
//     }
//     if (path != null && url == null && path.indexOf(' ') < 0) {
//       try {
//         foto = Container(
//             // color: Colors.yellow,
//             child: Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: Image.asset(path),
//         ));
//       } on Exception {
//         msg = ListTile(
//           title: Text('Não consegui abrir a imagem.'),
//         );
//       } catch (e) {
//         msg = ListTile(
//           title: Text('Não consegui abrir a imagem.'),
//         );
//       }
//       msg = Text(
//           'Esta foto precisa ser enviada. Salve esta edição de perfil e depois acesse o menu upload de arquivos para enviar esta imagem.');
//     }
//     if (url != null && uploadID != null) {
//       try {
//         foto = Container(
//             child: Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: Image.network(url),
//         ));
//       } on Exception {
//         print('Exception');
//         msg = ListTile(
//           title: Text('Não consegui abrir a imagem.'),
//         );
//       } catch (e) {
//         print('catch');
//         msg = ListTile(
//           title: Text('Não consegui abrir a imagem.'),
//         );
//       }
//     }
//     if (path != null && url == null && path.indexOf(' ') > 0) {
//       msg = ListTile(
//         title: Text('EXISTE ESPAÇO NO CAMINHO DO ARQUIVO: $path'),
//       );
//       foto = ListTile(
//         title: Text(
//             'FAVOR SELECIONAR IMAGEM DA CÂMERA OU OUTRO CAMINHO SEM ESPAÇO. Se necessário mova a foto para uma pasta com caminho sem espaços.'),
//       );
//     }
//     return Column(
//       children: <Widget>[
//         msg,
//         Row(
//           children: <Widget>[
//             Spacer(
//               flex: 1,
//             ),
//             Expanded(
//               flex: 8,
//               child: foto,
//             ),
//             Spacer(
//               flex: 1,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
