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
    return Scaffold(
        appBar: AppBar(
          title: Text('Corrigir tarefa'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cloud_upload),
          onPressed: () {
            bloc.eventSink(SaveEvent());
            Navigator.pop(context);
          },
        ),
        body: StreamBuilder<TarefaCorrigirBlocState>(
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
                        ListTile(
                          leading: tarefa.aluno?.foto == null
                              ? Text('')
                              : CircleAvatar(
                                  minRadius: 25,
                                  maxRadius: 25,
                                  backgroundImage: NetworkImage(tarefa.aluno.foto),
                                ),
                          title: Text('${tarefa.aluno.nome}'),
                          subtitle: Text('Sit.: $notas'),
                        ),
                        ListTile(
                          title: Text('''Avaliação: ${tarefa.avaliacao.nome}
Questão: ${tarefa.questao.numero}. Prob.: ${tarefa.problema.nome}
Simulacao: ${tarefa.simulacao.nome}
Aberta: ${DateFormat('dd-MM HH:mm').format(tarefa.inicio)} até ${DateFormat('dd-MM HH:mm').format(tarefa.fim)}
Iniciou: ${tarefa.iniciou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.iniciou)} | Enviou ${tarefa.enviou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.enviou)}
Tempo: ${tarefa.tempo} h | Usou: ${tarefa.tentou ?? 0} das ${tarefa.tentativa} tentativas.'''),
                        ),
                      ],
                    ),
                  ),
                );
                listaWidget.add(Divider());
                listaWidget.add(ListTile(
                  selected: true,
                  title: Text('Variáveis'),
                  trailing: Icon(Icons.sort_by_alpha),
                ));
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

                  if (variavel.value.tipo == 'urlimagem') {
                    String linkValorModificado;
                    if (variavel?.value?.valor != null && variavel.value.valor.contains('drive.google.com/open')) {
                      linkValorModificado = variavel.value.valor.replaceFirst('open', 'uc');
                    } else {
                      linkValorModificado = variavel.value.valor;
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
                                  child: _ImagemUnicaVariavel(
                                    urlModificada: linkValorModificado,
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
                listaWidget.add(Divider());
                listaWidget.add(ListTile(
                  selected: true,
                  title: Text('Gabarito e respostas'),
                  trailing: Icon(Icons.question_answer),
                ));

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
                    String linkValorModificado;
                    if (gabaritoInfoMap.value.gabarito?.valor != null &&
                        gabaritoInfoMap.value.gabarito.valor.contains('drive.google.com/open')) {
                      String linkOriginal = gabaritoInfoMap.value.gabarito.valor;
                      linkValorModificado = linkOriginal.replaceFirst('open', 'uc');
                    } else {
                      linkValorModificado = gabaritoInfoMap.value.gabarito.valor;
                    }
                    String linkRespostaModificado;
                    if (gabaritoInfoMap.value.gabarito?.resposta != null &&
                        gabaritoInfoMap.value.gabarito.resposta.contains('drive.google.com/open')) {
                      String linkOriginal = gabaritoInfoMap.value.gabarito.resposta;
                      linkRespostaModificado = linkOriginal.replaceFirst('open', 'uc');
                    } else {
                      linkRespostaModificado = gabaritoInfoMap.value.gabarito.resposta;
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
                                    urlModificada: linkValorModificado,
                                    urlOriginal: gabaritoInfoMap.value.gabarito.valor,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _ImagemUnica(
                                    urlModificada: linkRespostaModificado,
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
                    String linkValorModificado;
                    if (gabaritoInfoMap.value.gabarito?.valor != null &&
                        gabaritoInfoMap.value.gabarito.valor.contains('drive.google.com/open')) {
                      String linkOriginal = gabaritoInfoMap.value.gabarito.valor;
                      linkValorModificado = linkOriginal.replaceFirst('open', 'uc');
                    } else {
                      linkValorModificado = gabaritoInfoMap.value.gabarito.valor;
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
                                      Icons.add_photo_alternate,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.add_photo_alternate,
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
                                      urlModificada: linkValorModificado,
                                      urlOriginal: gabaritoInfoMap.value.gabarito.valor),
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
            }));
  }
}

class _ImagemUnicaVariavel extends StatelessWidget {
  final String urlModificada;
  final String urlOriginal;

  const _ImagemUnicaVariavel({this.urlModificada, this.urlOriginal});

  @override
  Widget build(BuildContext context) {
    Widget url;
    Widget link;

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
