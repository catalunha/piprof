import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/naosuportato/naosuportado.dart';
import 'package:piprof/paginas/tarefa/tarefa_corrigir_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';
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

                Map<String, Pedese> pedeseMap = Map<String, Pedese>();

                pedeseMap.clear();
                var dicPedese = Dictionary.fromMap(tarefa.pedese);
                var pedeseOrderBy =
                    dicPedese.orderBy((kv) => kv.value.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
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
                                Wrap(
                                  children: <Widget>[
                                    IconButton(
                                      tooltip: 'Relatorio detalhado desta tarefa',
                                      icon: Icon(Icons.recent_actors),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      tooltip: 'Ver situação da questão',
                                      icon: Icon(Icons.picture_as_pdf),
                                      onPressed: () {
                                        launch(tarefa.situacao.url);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                listaWidget.add(Divider());
                for (var variavel in variavelMap.entries) {
                  listaWidget.add(
                    Card(
                      child: ListTile(
                        title: Text('${variavel.value.nome}'),
                        subtitle: Text('${variavel.value.valor}'),
                      ),
                    ),
                  );
                }
                listaWidget.add(Divider());

                for (var pedeseInfoMap in snapshot.data.pedeseInfoMap.entries) {
                  if (['numero', 'palavra', 'texto'].contains(pedeseInfoMap.value.pedese.tipo)) {
//  if (infoMap.value.pedese.tipo == 'numero' ||
//                   infoMap.value.pedese.tipo == 'palavra' ||
//                   infoMap.value.pedese.tipo == 'url' ||
//                   infoMap.value.pedese.tipo == 'texto') {
//                   }

                    listaWidget.add(
                      Card(
                        child: ListTile(
                          title: Text('${pedeseInfoMap.value.pedese.nome}'),
                          subtitle: Text(
                              'Tipo:${pedeseInfoMap.value.pedese.tipo}\nGab.:${pedeseInfoMap.value.pedese.gabarito}\nResp.:${pedeseInfoMap.value.pedese.resposta}\nNota:${pedeseInfoMap.value.pedese.nota}'),
                          trailing: pedeseInfoMap.value.nota
                              ? Icon(
                                  Icons.thumb_up,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.thumb_down,
                                  color: Colors.red,
                                ),
                          onTap: () {
                            bloc.eventSink(UpdatePedeseNotaEvent(pedeseInfoMap.key));
                          },
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
      foto = Center(child: Text('Sem foto.'));
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
        // Spacer(
        //   flex: 1,
        // ),
        Expanded(
          flex: 4,
          child: foto,
        ),
        Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
