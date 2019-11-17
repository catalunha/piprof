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
              Text("Atualizar número do celular"),
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
              Text("Atualizar nome curto para crachá"),
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
          children: <Widget>[
            if (Recursos.instance.disponivel("file_picking"))
              ButtonBar(children: <Widget>[
                Text('Atualizar foto de usuario'),
                IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () async {
                    await _selecionarNovoArquivo().then((arq) {
                      localPath = arq;
                    });
                    print('localPath: $localPath');
                    bloc.eventSink(UpdateFotoEvent(localPath));
                    // if (localPath != null) {
                    //   showDialog(
                    //     context: context,
                    //     builder: (context) => Dialog(
                    //       elevation: 5,
                    //       child: ListTile(
                    //         selected: true,
                    //         title: Text(
                    //             "Você apenas selecionou a foto.\nApós salvar este perfil é necessário enviar a foto em upload de arquivos."),
                    //         onTap: () {},
                    //       ),
                    //     ),
                    //   );
                    // }
                  },
                ),
              ]),
            _ImagemPerfilUpload(
                uploadID: snapshot.data?.fotoUploadID,
                url: snapshot.data?.fotoUrl,
                path: snapshot.data?.localPath),
          ],
        );
      },
    );
  }

  Future<String> _selecionarNovoArquivo() async {
    try {
      var arquivoPath = await FilePicker.getFilePath(type: FileType.ANY);
      if (arquivoPath != null) {
        return arquivoPath;
      }
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
    return null;
  }
}

class _ImagemPerfilUpload extends StatelessWidget {
  final String uploadID;
  final String url;
  final String path;

  const _ImagemPerfilUpload({this.uploadID, this.url, this.path});

  @override
  Widget build(BuildContext context) {
    Widget foto = Text('?');
    Widget msg = Text('');

    if (path == null && url == null) {
      foto = Text('Você ainda não enviou uma foto de perfil.');
    }
    if (path != null && url == null) {
      try {
        foto = Container(
            // color: Colors.yellow,
            child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.asset(path),
        ));
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
          'Esta foto precisa ser enviada. Salve este edição de perfil e acesse o menu upload de arquivos.');
    }
    if (url != null && uploadID != null) {
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
              flex: 1,
            ),
            Expanded(
              flex: 8,
              child: foto,
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
      ],
    );
  }
}
