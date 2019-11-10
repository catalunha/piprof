import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/naosuportato/naosuportado.dart';
import 'package:piprof/paginas/tarefa/tarefa_corrigir_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';
import 'package:queries/collections.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

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
            builder: (BuildContext context,
                AsyncSnapshot<TarefaCorrigirBlocState> snapshot) {
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
                var dicOrderBy = dic
                    .orderBy((kv) => kv.value.ordem)
                    .toDictionary$1((kv) => kv.key, (kv) => kv.value);
                variavelMap = dicOrderBy.toMap();

                Map<String, Pedese> pedeseMap = Map<String, Pedese>();

                pedeseMap.clear();
                var dicPedese = Dictionary.fromMap(tarefa.pedese);
                var pedeseOrderBy = dicPedese
                    .orderBy((kv) => kv.value.ordem)
                    .toDictionary$1((kv) => kv.key, (kv) => kv.value);
                pedeseMap = pedeseOrderBy.toMap();
                notas = '';
                for (var pedese in pedeseMap.entries) {
                  notas += '${pedese.value.nome}=${pedese.value.nota ?? ""} ';
                }
                listaWidget.add(
                  Card(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 2,
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: _ImagemUnica(url: tarefa.aluno.foto),
                          ),
                          Expanded(
                            flex: 4,
                            // child: Container(
                            // padding: EdgeInsets.only(left: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("id: ${tarefa.id}"),
                                Text("Turma: ${tarefa.turma.nome}"),
                                Text("Avaliação: ${tarefa.avaliacao.nome}"),
                                Text("Questão: ${tarefa.questao.numero}"),
                                Text("Aluno: ${tarefa.aluno.nome}"),
                                Text(
                                    "Aberta: ${DateFormat('dd-MM HH:mm').format(tarefa.inicio)} até ${DateFormat('dd-MM HH:mm').format(tarefa.fim)}"),
                                Text(
                                    "Iniciou: ${tarefa.iniciou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.iniciou)} | Enviou ${tarefa.enviou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.enviou)}"),
                                Text(
                                    "Tempo: ${tarefa.tempo} | Tentativas: ${tarefa.tentativa} | Tentou: ${tarefa.tentou}"),
                                Text("Notas: $notas"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                listaWidget.add(Divider());
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
                    icone = IconButton(
                      tooltip: 'Link para uma imagem',
                      icon: Icon(Icons.image),
                      onPressed: () {
                        launch(variavel.value.valor);
                      },
                    );
                  }



                  listaWidget.add(
                    Card(
                      child: ListTile(
                        title: Text('${variavel.value.nome}'),
                        subtitle: Text(
                            '${variavel?.value?.valor}'),
                        trailing: icone,
                      ),
                    ),
                  );
                }
                listaWidget.add(Divider());

                for (var pedeseInfoMap in snapshot.data.pedeseInfoMap.entries) {

                  if (pedeseInfoMap.value.pedese.tipo=='numero') {
                    listaWidget.add(
                      Card(
                        child: ListTile(
                          title: Text('${pedeseInfoMap.value.pedese.nome}'),
                          subtitle: Text(
                              'Tipo:${pedeseInfoMap.value.pedese.tipo}\nGab.:${pedeseInfoMap.value.pedese.gabarito}\nResp.:${pedeseInfoMap.value.pedese.resposta}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                          trailing: pedeseInfoMap.value.nota
                              ? Icon(
                                  Icons.looks_one,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.looks_one,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(
                                UpdatePedeseNotaEvent(pedeseInfoMap.key));
                          },
                        ),
                      ),
                    );
                  }
                  if (pedeseInfoMap.value.pedese.tipo=='palavra') {
                    listaWidget.add(
                      Card(
                        child: ListTile(
                          title: Text('${pedeseInfoMap.value.pedese.nome}'),
                          subtitle: Text(
                              'Tipo:${pedeseInfoMap.value.pedese.tipo}\nGab.:${pedeseInfoMap.value.pedese.gabarito}\nResp.:${pedeseInfoMap.value.pedese.resposta}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                          trailing: pedeseInfoMap.value.nota
                              ? Icon(
                                  Icons.text_format,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.text_format,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(
                                UpdatePedeseNotaEvent(pedeseInfoMap.key));
                          },
                        ),
                      ),
                    );
                  }
                  if (pedeseInfoMap.value.pedese.tipo=='texto') {
                    listaWidget.add(
                      Card(
                        child: ListTile(
                          title: Text('${pedeseInfoMap.value.pedese.nome}'),
                          subtitle: Text(
                              'Tipo:${pedeseInfoMap.value.pedese.tipo}\nGab.:${pedeseInfoMap.value.pedese.gabarito}\nResp.:${pedeseInfoMap.value.pedese.resposta}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                          trailing: pedeseInfoMap.value.nota
                              ? Icon(
                                  Icons.text_fields,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.text_fields,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(
                                UpdatePedeseNotaEvent(pedeseInfoMap.key));
                          },
                        ),
                      ),
                    );
                  }


                  if (pedeseInfoMap.value.pedese.tipo == 'url') {
                    listaWidget.add(
                      Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text('${pedeseInfoMap.value.pedese.nome}'),
                              subtitle: Text(
                                  'Tipo:${pedeseInfoMap.value.pedese.tipo}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                              trailing: pedeseInfoMap.value.nota
                                  ? Icon(
                                      Icons.link,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.link,
                                      color: Colors.red,
                                    ),
                              onTap: () {
                                bloc.eventSink(
                                    UpdatePedeseNotaEvent(pedeseInfoMap.key));
                              },
                            ),
                            Wrap(
                              children: <Widget>[
                                pedeseInfoMap.value.pedese.gabarito == null
                                    ? IconButton(
                                        tooltip: 'url do gabarito não anexada',
                                        icon: Icon(Icons.link_off),
                                        onPressed: null,
                                      )
                                    : IconButton(
                                        tooltip:
                                            'Clique para ver a url do gabarito',
                                        icon: Icon(Icons.link),
                                        onPressed: () {
                                          launch(pedeseInfoMap
                                              .value.pedese.gabarito);
                                        },
                                      ),
                                pedeseInfoMap.value.pedese.resposta == null
                                    ? IconButton(
                                        tooltip: 'url da resposta não anexada',
                                        icon: Icon(Icons.link_off),
                                        onPressed: null,
                                      )
                                    : IconButton(
                                        tooltip:
                                            'Clique para ver a url da resposta',
                                        icon: Icon(Icons.link),
                                        onPressed: () {
                                          launch(pedeseInfoMap
                                              .value.pedese.resposta);
                                        },
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (pedeseInfoMap.value.pedese.tipo == 'urlimagem') {
                    listaWidget.add(
                      Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text('${pedeseInfoMap.value.pedese.nome}'),
                              subtitle: Text(
                                  'Tipo:${pedeseInfoMap.value.pedese.tipo}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                              trailing: pedeseInfoMap.value.nota
                                  ? Icon(
                                      Icons.image,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.image,
                                      color: Colors.red,
                                    ),
                              onTap: () {
                                bloc.eventSink(
                                    UpdatePedeseNotaEvent(pedeseInfoMap.key));
                              },
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: _ImagemUnica(
                                      url:
                                          pedeseInfoMap.value.pedese.gabarito ??
                                              null),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _ImagemUnica(
                                      url:
                                          pedeseInfoMap.value.pedese.resposta ??
                                              null),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }


                  if (pedeseInfoMap.value.pedese.tipo == 'arquivo') {
                    listaWidget.add(
                      Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text('${pedeseInfoMap.value.pedese.nome}'),
                              subtitle: Text(
                                  'Tipo:${pedeseInfoMap.value.pedese.tipo}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                              trailing: pedeseInfoMap.value.nota
                                  ? Icon(
                                      Icons.description,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.description,
                                      color: Colors.red,
                                    ),
                              onTap: () {
                                bloc.eventSink(
                                    UpdatePedeseNotaEvent(pedeseInfoMap.key));
                              },
                            ),
                            Wrap(
                              children: <Widget>[
                                pedeseInfoMap.value.pedese.gabarito == null
                                    ? IconButton(
                                        tooltip: 'url do gabarito não anexada',
                                        icon: Icon(Icons.link_off),
                                        onPressed: null,
                                      )
                                    : IconButton(
                                        tooltip:
                                            'Clique para ver a url do gabarito',
                                        icon: Icon(Icons.link),
                                        onPressed: () {
                                          launch(pedeseInfoMap
                                              .value.pedese.gabarito);
                                        },
                                      ),
                                pedeseInfoMap.value.pedese.resposta == null
                                    ? IconButton(
                                        tooltip: 'url da resposta não anexada',
                                        icon: Icon(Icons.link_off),
                                        onPressed: null,
                                      )
                                    : IconButton(
                                        tooltip:
                                            'Clique para ver a url da resposta',
                                        icon: Icon(Icons.link),
                                        onPressed: () {
                                          launch(pedeseInfoMap
                                              .value.pedese.resposta);
                                        },
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }


                  if (pedeseInfoMap.value.pedese.tipo == 'imagem') {
                    listaWidget.add(
                      Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text('${pedeseInfoMap.value.pedese.nome}'),
                              subtitle: Text(
                                  'Tipo:${pedeseInfoMap.value.pedese.tipo}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                              trailing: pedeseInfoMap.value.nota
                                  ? Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.red,
                                    ),
                              onTap: () {
                                bloc.eventSink(
                                    UpdatePedeseNotaEvent(pedeseInfoMap.key));
                              },
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: _ImagemUnica(
                                      url:
                                          pedeseInfoMap.value.pedese.gabarito ??
                                              null),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _ImagemUnica(
                                      url:
                                          pedeseInfoMap.value.pedese.resposta ??
                                              null),
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

class _ImagemUnica extends StatelessWidget {
  final String url;

  const _ImagemUnica({this.url});

  @override
  Widget build(BuildContext context) {
    Widget foto;
    if (url == null) {
      foto = Center(child: Text('Sem imagem.'));
    } else {
      foto = Container(
        // child: Padding(
        // padding: const EdgeInsets.all(2.0),
        child: Image.network(url),
        // ),
      );
    }
    return Row(
      children: <Widget>[
        Spacer(
          flex: 1,
        ),
        Expanded(
          flex: 16,
          child: foto,
        ),
        Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
