import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/paginas/turma/turma_ativa_list_bloc.dart';

class TurmaAtivaListPage extends StatefulWidget {
  final AuthBloc authBloc;

  const TurmaAtivaListPage(this.authBloc);

  @override
  _TurmaAtivaListPageState createState() => _TurmaAtivaListPageState();
}

class _TurmaAtivaListPageState extends State<TurmaAtivaListPage> {
  TurmaAtivaListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TurmaAtivaListBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(UpdateTurmaAtivaListEvent());
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
        title: Text('Turmas ativas'),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/turma/crud",
              arguments: null,
            );
          },
        ),
        body: StreamBuilder<TurmaAtivaListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<TurmaAtivaListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                int lengthTurma = snapshot.data.turmaList.length;
                int ordemLocal = 1;

                for (var turma in snapshot.data.turmaList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            trailing: Text('Qts: ${turma.questaoNumeroAdicionado ?? 0 - turma.questaoNumeroExcluido ?? 0}'),
                            title: Text('''
Instit.: ${turma.instituicao}
Comp.: ${turma.componente}
Turma: ${turma.nome}
Num. Alunos: ${turma.alunoList?.length ?? 0}'''),
subtitle: Text('${turma?.id}'),
                          ),
                          Wrap(
                            children: <Widget>[
                              IconButton(
                                  tooltip: 'Agenda de encontros da turma',
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () {}),
                              IconButton(
                                tooltip: 'Gerenciar avaliações',
                                icon: Icon(Icons.assignment),
                                onPressed: () {},
                              ),
                              IconButton(
                                tooltip: 'Gerenciar alunos',
                                icon: Icon(Icons.people),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/turma/aluno",
                                    arguments: turma.id,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Descer ordem da turma',
                                icon: Icon(Icons.arrow_downward),
                                onPressed: (ordemLocal) < lengthTurma
                                    ? () {
                                        bloc.eventSink(OrdenarEvent(turma, false));
                                      }
                                    : null,
                              ),
                              IconButton(
                                tooltip: 'Subir ordem da turma',
                                icon: Icon(Icons.arrow_upward),
                                onPressed: ordemLocal > 1
                                    ? () {
                                        bloc.eventSink(OrdenarEvent(turma, true));
                                      }
                                    : null,
                              ),
                              IconButton(
                                tooltip: 'Editar turma',
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/turma/crud",
                                    arguments: turma.id,
                                  );
                                },
                              ),
                            ],
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
