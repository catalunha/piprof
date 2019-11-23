import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/paginas/tarefa/tarefa_list_bloc.dart';
import 'package:queries/collections.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class TarefaListPage extends StatefulWidget {
  final String tarefaID;

  const TarefaListPage(this.tarefaID);
  @override
  _TarefaListPageState createState() => _TarefaListPageState();
}

class _TarefaListPageState extends State<TarefaListPage> {
  TarefaListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TarefaListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetTarefaListPorQuestaoEvent(widget.tarefaID));
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
          title: Text('Tarefa do aluno'),
        ),
        body: StreamBuilder<TarefaListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<TarefaListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                String notas = '';
                Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();

                for (var tarefa in snapshot.data.tarefaList) {
                  gabaritoMap.clear();
                  var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
                  var gabaritoOrderBy = dicGabarito
                      .orderBy((kv) => kv.value.ordem)
                      .toDictionary$1((kv) => kv.key, (kv) => kv.value);
                  gabaritoMap = gabaritoOrderBy.toMap();
                  notas = '';
                  for (var gabarito in gabaritoMap.entries) {
                    notas +=
                        '${gabarito.value.nome}=${gabarito.value.nota ?? "?"} ';
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
                                    backgroundImage:
                                        NetworkImage(tarefa.aluno.foto),
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
                          Wrap(
                            children: <Widget>[
                              IconButton(
                                tooltip: 'Ver problema da questão',
                                icon: Icon(Icons.local_library),
                                onPressed: tarefa.problema.url != null &&
                                        tarefa.problema.url.isNotEmpty
                                    ? () {
                                        launch(tarefa.problema.url);
                                      }
                                    : null,
                              ),
                              IconButton(
                                tooltip: 'Corrigir tarefa',
                                icon: Icon(Icons.playlist_add_check),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/tarefa/corrigir",
                                    arguments: tarefa.id,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Reset tempo e tentativa',
                                icon: Icon(Icons.child_care),
                                onPressed: () {
                                  bloc.eventSink(ResetTempoTentativaTarefaEvent(
                                      tarefa.id));
                                },
                              ),
                              IconButton(
                                tooltip: 'Editar tarefa para este aluno',
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/tarefa/crud",
                                    arguments: tarefa.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
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
