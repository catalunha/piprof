import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/questao/questao_list_bloc.dart';

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
          title: Text('Suas Questões nesta avaliação'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Navigator.pushNamed(
            //   context,
            //   "/avaliacao/crud",
            //   arguments: AvaliacaoCRUDPageArguments(
            //     turmaID: widget.turmaID,
            //   ),
            // );
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

                for (var questao in snapshot.data.questaoList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            trailing: Text('${questao.numero}'),
                            title: Text('''
Turma: ${questao.turma.nome}
Prof.: ${questao.professor.nome}
Aval.: ${questao.avaliacao.nome}
Sit.: ${questao.situacao.nome}
Inicio: ${questao.inicio}
fim: ${questao.fim}
Tentativa | Tempo : ${questao.tentativa} | ${questao.tempo}h
Nota da questao: ${questao.nota}
                            '''),
                            subtitle: Text('''
id: ${questao.id}
                            '''),
                          ),
                          Center(
                            child: Wrap(
                            children: <Widget>[
                              IconButton(
                                tooltip: 'Editar esta questão',
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   "/turma/crud",
                                  //   arguments: turma.id,
                                  // );
                                },
                              ),
                              // IconButton(
                              //   tooltip: 'Descer ordem da turma',
                              //   icon: Icon(Icons.arrow_downward),
                              //   onPressed: (ordemLocal) < lengthTurma
                              //       ? () {
                              //           bloc.eventSink(
                              //               OrdenarEvent(turma, false));
                              //         }
                              //       : null,
                              // ),
                              // IconButton(
                              //   tooltip: 'Subir ordem da turma',
                              //   icon: Icon(Icons.arrow_upward),
                              //   onPressed: ordemLocal > 1
                              //       ? () {
                              //           bloc.eventSink(
                              //               OrdenarEvent(turma, true));
                              //         }
                              //       : null,
                              // ),
                              IconButton(
                                tooltip: 'Gerenciar alunos',
                                icon: Icon(Icons.people),
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   "/turma/aluno",
                                  //   arguments: turma.id,
                                  // );
                                },
                              ),
                              IconButton(
                                tooltip: 'Agenda de encontros da turma',
                                icon: Icon(Icons.calendar_today),
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   "/turma/encontro/list",
                                  //   arguments: turma.id,
                                  // );
                                },
                              ),
                              IconButton(
                                tooltip: 'Gerenciar avaliações',
                                icon: Icon(Icons.assignment),
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   "/avaliacao/list",
                                  //   arguments: turma.id,
                                  // );
                                },
                              ),
                            ],
                          ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  children: listaWidget,
                );
              } else {
                return Text('Existem dados inválidos. Informe o suporte.');
              }
            }));
  }
}
