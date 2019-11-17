import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/naosuportato/naosuportado.dart';
import 'package:piprof/paginas/tarefa/tarefa_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';
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
                              child: _ImagemUnica(url: tarefa.aluno?.foto),
                            ),
                            Expanded(
                              flex: 4,
                              // child: Container(
                              // padding: EdgeInsets.only(left: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("id: ${tarefa.id}"),
                                  // Text("Turma: ${tarefa.turma.nome}"),
                                  Text("Aluno: ${tarefa.aluno.nome}"),
                                  Text("Avaliação: ${tarefa.avaliacao.nome}"),
                                  Text(
                                      "Questão: ${tarefa.questao.numero}. Prob.:${tarefa.problema.nome}"),
                                  Text("Simulacao: ${tarefa.simulacao.nome}"),
                                  Text(
                                      "Aberta: ${DateFormat('dd-MM HH:mm').format(tarefa.inicio)} até ${DateFormat('dd-MM HH:mm').format(tarefa.fim)}"),
                                  Text(
                                      "Iniciou: ${tarefa.iniciou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.iniciou)} | Enviou ${tarefa.enviou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.enviou)}"),
                                  Text(
                                      "Tempo: ${tarefa.tempo} h | Tentou: ${tarefa.tentou ?? 0} em ${tarefa.tentativa} tentativa(s)."),
                                  Text("Sit.: $notas"),
                                  Wrap(
                                    children: <Widget>[
                                      IconButton(
                                        tooltip: 'Ver problema da questão',
                                        icon: Icon(Icons.local_library),
                                        onPressed: () {
                                          launch(tarefa.problema.url);
                                        },
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
                                      // IconButton(
                                      //   tooltip: 'Relatorio detalhado desta tarefa',
                                      //   icon: Icon(Icons.grid_on),
                                      //   onPressed: () {},
                                      // ),
                                      IconButton(
                                        tooltip: 'Reset tempo e tentativa',
                                        icon: Icon(Icons.child_care),
                                        onPressed: () {
                                          bloc.eventSink(
                                              ResetTempoTentativaTarefaEvent(
                                                  tarefa.id));
                                        },
                                      ),
                                      IconButton(
                                        tooltip:
                                            'Editar tarefa para este aluno',
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
                          ],
                        ),
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
          flex: 14,
          child: foto,
        ),
        Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
