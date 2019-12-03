import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/paginas/tarefa/tarefa_corrigir_bloc.dart';
import 'package:queries/collections.dart';
import 'package:piprof/naosuportato/url_launcher.dart' if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class TarefaCorrigirPage extends StatefulWidget {
  final String tarefaID;

  const TarefaCorrigirPage(this.tarefaID);
  @override
  _TarefaCorrigirPageState createState() => _TarefaCorrigirPageState();
}

class _TarefaCorrigirPageState extends State<TarefaCorrigirPage> {
  TarefaCorrigirBloc bloc;

    final List<Tab> myTabs = <Tab>[
    Tab(text: "Tarefa"),
    Tab(text: "Valores"),
    Tab(text: "Resposta"),
  ];
  @override
  void initState() {
    super.initState();
    bloc = TarefaCorrigirBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetTarefaEvent(widget.tarefaID));
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Corrigir tarefa'),
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: _body(context),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cloud_upload),
          onPressed: () {
            bloc.eventSink(SaveEvent());
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  TabBarView _body(context) {
    return TabBarView(
      children: [
        _tarefa(),
        _valores(),
        _gabarito(),
      ],
    );
  }

  _tarefa() {
    return 
    StreamBuilder<TarefaCorrigirBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<TarefaCorrigirBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();
            String notas = '';
            var tarefa = snapshot.data.tarefa;

            // Map<String, Variavel> variavelMap;
            // var dic = Dictionary.fromMap(tarefa.variavel);
            // var dicOrderBy = dic.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
            // variavelMap = dicOrderBy.toMap();

            Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();
            gabaritoMap.clear();
            var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
            var gabaritoOrderBy =
                dicGabarito.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
            gabaritoMap = gabaritoOrderBy.toMap();
            notas = '';
            for (var gabarito in gabaritoMap.entries) {
              notas += '${gabarito.value.nome}=${gabarito.value.nota ?? ""} ';
            }
            listaWidget.add(
              Card(
                child: Column(
                  children: <Widget>[
                    card(
                        tarefa.aluno?.foto,
                        tarefa.aluno.nome,
                        notas,),
                    // ListTile(
                    //   leading: tarefa.aluno?.foto == null
                    //       ? Text('')
                    //       : CircleAvatar(
                    //           minRadius: 25,
                    //           maxRadius: 25,
                    //           backgroundImage: NetworkImage(tarefa.aluno.foto),
                    //         ),
                    //   title: Text('${tarefa.aluno.nome}'),
                    //   subtitle: Text('Sit.: $notas'),
                    // ),
                    ListTile(
                      title: Text('''Avaliação: ${tarefa.avaliacao.nome}
Questão: ${tarefa.questao.numero}. Prob.: ${tarefa.problema.nome}
Simulacao: ${tarefa.simulacao.nome}
Aberta: ${DateFormat('dd-MM HH:mm').format(tarefa.inicio)} até ${DateFormat('dd-MM HH:mm').format(tarefa.fim)}
Iniciou: ${tarefa.iniciou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.iniciou)} | Enviou ${tarefa.enviou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.enviou)}
Tempo: ${tarefa.tempo} h | Usou: ${tarefa.tentou ?? 0} das ${tarefa.tentativa} tentativas.'''),
                      subtitle: Text('id: ${tarefa.id}'),
                    ),
                  ],
                ),
              ),
            );
             listaWidget.add(ListTile(
              title: Text('Link para o problema proposto, clique aqui.'),
              trailing: Icon(Icons.local_library),
              onTap: () {
                launch(tarefa.problema.url);
              },
             ));
            listaWidget.add(Container(
              padding: EdgeInsets.only(top: 70),
            ));

            return ListView(
              children: listaWidget,
            );
          } else {
            return Text('Existem dados inválidos. Informe o suporte.');
          }
        });
  }

  _valores() {
    return StreamBuilder<TarefaCorrigirBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<TarefaCorrigirBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();
            String notas = '';
            var tarefa = snapshot.data.tarefa;

            Map<String, Variavel> variavelMap;
            var dic = Dictionary.fromMap(tarefa.variavel);
            var dicOrderBy = dic.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
            variavelMap = dicOrderBy.toMap();

            // Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();

            // gabaritoMap.clear();
            // var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
            // var gabaritoOrderBy =
            //     dicGabarito.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
            // gabaritoMap = gabaritoOrderBy.toMap();
            // notas = '';
            // for (var gabarito in gabaritoMap.entries) {
            //   notas += '${gabarito.value.nome}=${gabarito.value.nota ?? ""} ';
            // }

            Widget icone;

            for (var variavel in variavelMap.entries) {
              if (variavel.value.tipo == 'numero') {
                icone = Icon(Icons.looks_one);
              } else if (variavel.value.tipo == 'palavra') {
                icone = Icon(Icons.text_format);
              } else if (variavel.value.tipo == 'texto') {
                icone = Icon(Icons.text_fields);
              } else if (variavel.value.tipo == 'url') {
                icone = IconButton(
                  tooltip: 'Um link ao um site ou arquivo',
                  icon: Icon(Icons.link),
                  onPressed: () {
                    launch(variavel.value.valor);
                  },
                );
              } else if (variavel.value.tipo == 'urlimagem') {
                icone = Icon(Icons.image);
              }

// https://drive.google.com/file/d/1mCmbdcgY_f7jbBC8O04Z2wffku5ZpahI/view?usp=drivesdk
// https://drive.google.com/file/d/1mCmbdcgY_f7jbBC8O04Z2wffku5ZpahI/view?usp=sharing
// https://drive.google.com/open?id=1mCmbdcgY_f7jbBC8O04Z2wffku5ZpahI
              if (variavel.value.tipo == 'urlimagem') {
                String urlModificada;
                if (variavel?.value?.valor != null) {
                  urlModificada = modificarUrlImagemGoogleDrive(variavel.value.valor);
                }

                listaWidget.add(
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('${variavel.value.nome}'),
                          // subtitle: Text('${variavel?.value?.valor}'),
                          trailing: icone,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: VerUrlImagem(
                                urlModificada: urlModificada,
                                urlOriginal: variavel.value.valor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                listaWidget.add(
                  Card(
                    child: ListTile(
                      title: Text('${variavel.value.nome}'),
                      subtitle: Text('${variavel?.value?.valor}'),
                      trailing: icone,
                    ),
                  ),
                );
              }
            }
            listaWidget.add(Container(
              padding: EdgeInsets.only(top: 70),
            ));

            return ListView(
              children: listaWidget,
            );
          } else {
            return Text('Existem dados inválidos. Informe o suporte.');
          }
        });
  }

  _gabarito() {
    return StreamBuilder<TarefaCorrigirBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<TarefaCorrigirBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();
            String notas = '';
            var tarefa = snapshot.data.tarefa;

            // Map<String, Variavel> variavelMap;
            // var dic = Dictionary.fromMap(tarefa.variavel);
            // var dicOrderBy = dic.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
            // variavelMap = dicOrderBy.toMap();

            // Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();

            // gabaritoMap.clear();
            // var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
            // var gabaritoOrderBy =
            //     dicGabarito.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
            // gabaritoMap = gabaritoOrderBy.toMap();
            // notas = '';
            // for (var gabarito in gabaritoMap.entries) {
            //   notas += '${gabarito.value.nome}=${gabarito.value.nota ?? ""} ';
            // }

            for (var gabaritoInfoMap in snapshot.data.gabaritoInfoMap.entries) {
              if (gabaritoInfoMap.value.gabarito.tipo == 'numero') {
                listaWidget.add(
                  Card(
                    child: ListTile(
                      title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                      subtitle: Text(
                          'Gab.:${gabaritoInfoMap.value.gabarito.valor}\nResp.:${gabaritoInfoMap.value.gabarito.resposta}'),
                      trailing: gabaritoInfoMap.value.nota
                          ? Icon(
                              Icons.looks_one,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.looks_one,
                              color: Colors.red,
                            ),
                      onTap: () {
                        bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                      },
                    ),
                  ),
                );
              }
              if (gabaritoInfoMap.value.gabarito.tipo == 'palavra') {
                listaWidget.add(
                  Card(
                    child: ListTile(
                      title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                      subtitle: Text(
                          'Gab.:${gabaritoInfoMap.value.gabarito.valor}\nResp.:${gabaritoInfoMap.value.gabarito.resposta}'),
                      trailing: gabaritoInfoMap.value.nota
                          ? Icon(
                              Icons.text_format,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.text_format,
                              color: Colors.red,
                            ),
                      onTap: () {
                        bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                      },
                    ),
                  ),
                );
              }
              if (gabaritoInfoMap.value.gabarito.tipo == 'texto') {
                listaWidget.add(
                  Card(
                    child: ListTile(
                      title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                      subtitle: Text(
                          'Gabarito:\n${gabaritoInfoMap.value.gabarito.valor}\nResposta:\n${gabaritoInfoMap.value.gabarito.resposta}'),
                      trailing: gabaritoInfoMap.value.nota
                          ? Icon(
                              Icons.text_fields,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.text_fields,
                              color: Colors.red,
                            ),
                      onTap: () {
                        bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                      },
                    ),
                  ),
                );
              }

              if (gabaritoInfoMap.value.gabarito.tipo == 'url') {
                listaWidget.add(
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                          trailing: gabaritoInfoMap.value.nota
                              ? Icon(
                                  Icons.link,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.link,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                          },
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: gabaritoInfoMap.value.gabarito.valor == null
                                  ? ListTile(
                                      subtitle: Text('Link do gabarito não anexado'),
                                      trailing: Icon(Icons.launch),
                                      onTap: null,
                                    )
                                  : ListTile(
                                      subtitle: Text('Clique para ver o link do gabarito'),
                                      trailing: Icon(Icons.launch),
                                      onTap: () {
                                        launch(gabaritoInfoMap.value.gabarito.valor);
                                      },
                                    ),
                            ),
                            Expanded(
                              flex: 2,
                              child: gabaritoInfoMap.value.gabarito.resposta == null
                                  ? ListTile(
                                      subtitle: Text('Link da resposta não anexado'),
                                      trailing: Icon(Icons.launch),
                                      onTap: null,
                                    )
                                  : ListTile(
                                      subtitle: Text('Clique para ver o link da resposta'),
                                      trailing: Icon(Icons.launch),
                                      onTap: () {
                                        launch(gabaritoInfoMap.value.gabarito.resposta);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (gabaritoInfoMap.value.gabarito.tipo == 'urlimagem') {
                String urlValorModificado;
                if (gabaritoInfoMap.value.gabarito?.valor != null) {
                  urlValorModificado = modificarUrlImagemGoogleDrive(gabaritoInfoMap.value.gabarito.valor);
                }

                String urlRespostaModificado;
                if (gabaritoInfoMap.value.gabarito?.resposta != null) {
                  urlRespostaModificado = modificarUrlImagemGoogleDrive(gabaritoInfoMap.value.gabarito.resposta);
                }

                listaWidget.add(
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                          trailing: gabaritoInfoMap.value.nota
                              ? Icon(
                                  Icons.image,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.image,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                          },
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: _ImagemUnica(
                                urlModificada: urlValorModificado,
                                urlOriginal: gabaritoInfoMap.value.gabarito.valor,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _ImagemUnica(
                                urlModificada: urlRespostaModificado,
                                urlOriginal: gabaritoInfoMap.value.gabarito.resposta,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (gabaritoInfoMap.value.gabarito.tipo == 'arquivo') {
                listaWidget.add(
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                          trailing: gabaritoInfoMap.value.nota
                              ? Icon(
                                  Icons.description,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.description,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                          },
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: gabaritoInfoMap.value.gabarito.valor == null
                                  ? ListTile(
                                      subtitle: Text('Arquivo do gabarito não anexado'),
                                      trailing: Icon(Icons.launch),
                                      onTap: null,
                                    )
                                  : ListTile(
                                      subtitle: Text('Clique para ver o arquivo do gabarito'),
                                      trailing: Icon(Icons.launch),
                                      onTap: () {
                                        launch(gabaritoInfoMap.value.gabarito.valor);
                                      },
                                    ),
                            ),
                            Expanded(
                              flex: 2,
                              child: gabaritoInfoMap.value.gabarito.resposta == null
                                  ? ListTile(
                                      subtitle: Text('Arquivo da resposta não anexado'),
                                      trailing: Icon(Icons.launch),
                                      onTap: null,
                                    )
                                  : ListTile(
                                      subtitle: Text('Clique para ver o arquivo da resposta'),
                                      trailing: Icon(Icons.launch),
                                      onTap: () {
                                        launch(gabaritoInfoMap.value.gabarito.resposta);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (gabaritoInfoMap.value.gabarito.tipo == 'imagem') {
                String urlValorModificado;
                if (gabaritoInfoMap.value.gabarito?.valor != null) {
                  urlValorModificado = modificarUrlImagemGoogleDrive(gabaritoInfoMap.value.gabarito.valor);
                }
                listaWidget.add(
                  Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('${gabaritoInfoMap.value.gabarito.nome}'),
                          // subtitle: Text(
                          //     'Tipo:${gabaritoInfoMap.value.gabarito.tipo}\nNota:${gabaritoInfoMap.value.gabarito.nota}'),
                          trailing: gabaritoInfoMap.value.nota
                              ? Icon(
                                  Icons.photo_camera,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.photo_camera,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(UpdateGabaritoNotaEvent(gabaritoInfoMap.key));
                          },
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: _ImagemUnica(
                                  urlModificada: urlValorModificado, urlOriginal: gabaritoInfoMap.value.gabarito.valor),
                            ),
                            Expanded(
                              flex: 2,
                              child: _ImagemUnica(
                                urlModificada: gabaritoInfoMap.value.gabarito.resposta,
                                urlOriginal: gabaritoInfoMap.value.gabarito.resposta,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            }

            listaWidget.add(Container(
              padding: EdgeInsets.only(top: 70),
            ));

            return ListView(
              children: listaWidget,
            );
          } else {
            return Text('Existem dados inválidos. Informe o suporte.');
          }
        });
  }

  String modificarUrlImagemGoogleDrive(String url) {
    String urlModificada = url;
    if (url.contains('drive.google.com/open')) {
      urlModificada = url.replaceFirst('open', 'uc');
    }
    if (url.contains('drive.google.com/file/d/')) {
      if (url.contains('usp=drivesdk')) {
        urlModificada =
            url.replaceAll('/view?usp=drivesdk', '').replaceAll('file/d/', 'open?id=').replaceFirst('open', 'uc');
      }
      if (url.contains('usp=sharing')) {
        urlModificada =
            url.replaceAll('/view?usp=sharing', '').replaceAll('file/d/', 'open?id=').replaceFirst('open', 'uc');
      }
    }
    return urlModificada;
  }

  card(String url, String nome,String nota) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: Container(
        height: 80.0,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 50.0,
              right: 5,
              child: Container(
                width: 290.0,
                height: 90.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.green[900],
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 30.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Nome: ${nome}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Sit.: ${nota}",
                            style: Theme.of(context).textTheme.subhead),
                        // Text("Celular: ${celular}",
                        //     style: Theme.of(context).textTheme.subhead),
                        // Text("Crachá: ${cracha}",
                        //     style: Theme.of(context).textTheme.subhead),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: 7,
                child: Container(
                  width: 70.0,
                  height: 70.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: url != null
                          ? NetworkImage(url)
                          : NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/PIBrintec_512x512px_Aluno.png?alt=media&token=3890ede1-b09f-48da-a07a-2eea315503fd"),
                    ),
                  ),
                )

                // Image.network("https://image.freepik.com/vetores-gratis/perfil-de-avatar-de-mulher-no-icone-redondo_24640-14042.jpg",height: 100,)
                ),
          ],
        ),
      ),
    );
  }
}

class VerUrlImagem extends StatelessWidget {
  final String urlModificada;
  final String urlOriginal;

  const VerUrlImagem({this.urlModificada, this.urlOriginal});

  @override
  Widget build(BuildContext context) {
    Widget url;
    Widget link;
    link = Center(child: ListTile(subtitle: Text('')));

    if (urlModificada == null) {
      url = Center(child: ListTile(subtitle: Text('Não consigo visualizar este tipo de imagem aqui.')));
    } else {
      if (urlOriginal != null) {
        link = ListTile(
          subtitle: Text('Se não visualizar a imagem, click aqui.'),
          trailing: Icon(Icons.launch),
          onTap: () {
            launch(urlOriginal);
          },
        );
      }
      try {
        url = Container(
          child: Image.network(urlModificada),
        );
      } on Exception {
        url = ListTile(
          subtitle: Text('Não consegui abrir este link como imagem. Use o Chrome.'),
        );
      } catch (e) {
        url = ListTile(
          subtitle: Text('Não consegui abrir este link como imagem. Use o Chrome.'),
        );
      }
    }

    return Container(
      padding: EdgeInsets.only(left: 25, bottom: 10),
      child: Row(
        children: <Widget>[
          // Spacer(
          //   flex: 1,
          // ),
          Expanded(
            flex: 2,
            child: url,
          ),
          // Spacer(
          //   flex: 2,
          // ),
          Expanded(
            flex: 2,
            child: link,
          ),
        ],
      ),
    );
  }
}

class _ImagemUnica extends StatelessWidget {
  final String urlModificada;
  final String urlOriginal;

  const _ImagemUnica({this.urlModificada, this.urlOriginal});

  @override
  Widget build(BuildContext context) {
    Widget url;
    Widget link;
    // print('urlModificada: $urlModificada');
    // print('urlOriginal: $urlOriginal');
    link = Center(child: ListTile(subtitle: Text('')));
    if (urlModificada == null) {
      url = Center(child: ListTile(subtitle: Text('Sem imagem nesta resposta.')));
    } else {
      if (urlOriginal != null) {
        link = ListTile(
          subtitle: Text('Se não visualizar a imagem, click aqui.'),
          trailing: Icon(Icons.launch),
          onTap: () {
            launch(urlOriginal);
          },
        );
      }

      try {
        url = Container(
          child: Image.network(urlModificada),
        );
      } on Exception {
        url = ListTile(
          subtitle: Text('Não consegui abrir este link como imagem. Use o link.'),
        );
      } catch (e) {
        url = ListTile(
          subtitle: Text('Não consegui abrir este link como imagem. Use o link.'),
        );
      }
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 16,
              child: url,
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
        link,
      ],
    );
  }
}
