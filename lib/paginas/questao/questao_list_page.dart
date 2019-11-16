import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/questao/questao_list_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class QuestaoListPage extends StatefulWidget {
  final String avaliacaoID;

  const QuestaoListPage(this.avaliacaoID);

  @override
  _QuestaoListPageState createState() => _QuestaoListPageState();
}

class _QuestaoListPageState extends State<QuestaoListPage> {
  QuestaoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = QuestaoListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(UpdateQuestaoListEvent(widget.avaliacaoID));
    bloc.eventSink(GetAvaliacaoEvent(widget.avaliacaoID));
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
          title: Text('Questões'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/questao/crud",
              arguments: QuestaoCRUDPageArguments(
                avaliacaoID: widget.avaliacaoID,
              ),
            );
          },
        ),
        body: StreamBuilder<QuestaoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuestaoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                int lengthTurma = snapshot.data.questaoList.length;

                int ordemLocal = 1;

                for (var questao in snapshot.data.questaoList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            selected: questao?.aplicada != null && !questao.aplicada,
                                // ? true
                                // : false,
                            trailing: Text('Núm.: ${questao.numero}'),
                            title: Text('''
Turma: ${questao.turma.nome}
Aval.: ${questao.avaliacao.nome}
Sit.: ${questao.problema.nome}
Aberta: ${DateFormat('dd-MM HH:mm').format(questao.inicio)} até ${DateFormat('dd-MM HH:mm').format(questao.fim)}
Tentativas: ${questao.tentativa} | Tempo : ${questao.tempo}h
Nota/Peso: ${questao.nota}'''),
// Prof.: ${questao.professor.nome}
                            subtitle: Text('''
id: ${questao.id}'''),
                          ),
                          Center(
                            child: Wrap(
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Editar esta questão',
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/questao/crud",
                                      arguments: QuestaoCRUDPageArguments(
                                        questaoID: questao.id,
                                        avaliacaoID: widget.avaliacaoID,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Descer ordem da turma',
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: (ordemLocal) < lengthTurma
                                      ? () {
                                          bloc.eventSink(
                                              OrdenarEvent(questao, false));
                                        }
                                      : null,
                                ),
                                IconButton(
                                  tooltip: 'Subir ordem da turma',
                                  icon: Icon(Icons.arrow_upward),
                                  onPressed: ordemLocal > 1
                                      ? () {
                                          bloc.eventSink(
                                              OrdenarEvent(questao, true));
                                        }
                                      : null,
                                ),
                                IconButton(
                                  tooltip: 'Ver pdf da problema',
                                  icon: Icon(Icons.picture_as_pdf),
                                  onPressed: () {
                                    launch(questao.problema.url);
                                  },
                                ),
                                if(questao.aplicada!=null && questao.aplicada)
                                 IconButton(
                                  tooltip: 'Reset tempo e tentativa',
                                  icon: Icon(Icons.child_care),
                                  onPressed: () {
                                    bloc.eventSink(
                                              ResetTempoTentativaQuestaEvent(questao.id,questao.aplicada));
                                    
                                  },
                                ),
                                if (snapshot.data?.avaliacao?.aplicada !=
                                        null &&
                                    snapshot.data?.avaliacao?.aplicada)
                                  IconButton(
                                    tooltip: 'Alunos nesta questão',
                                    icon: Icon(Icons.perm_contact_calendar),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/tarefa/list",
                                        arguments: questao.id,
                                      );
                                    },
                                  ),
                                // IconButton(
                                //   tooltip: 'Agenda de encontros da turma',
                                //   icon: Icon(Icons.calendar_today),
                                //   onPressed: () {
                                //     // Navigator.pushNamed(
                                //     //   context,
                                //     //   "/turma/encontro/list",
                                //     //   arguments: turma.id,
                                //     // );
                                //   },
                                // ),
                                // IconButton(
                                //   tooltip: 'Gerenciar avaliações',
                                //   icon: Icon(Icons.assignment),
                                //   onPressed: () {
                                //     // Navigator.pushNamed(
                                //     //   context,
                                //     //   "/avaliacao/list",
                                //     //   arguments: turma.id,
                                //     // );
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  ordemLocal++;
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
