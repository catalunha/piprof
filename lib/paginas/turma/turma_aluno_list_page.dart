import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/turma/turma_aluno_list_bloc.dart';

class TurmaAlunoListPage extends StatefulWidget {
  final AuthBloc authBloc;

  const TurmaAlunoListPage(this.authBloc);
  @override
  _TurmaAlunoListPageState createState() => _TurmaAlunoListPageState();
}

class _TurmaAlunoListPageState extends State<TurmaAlunoListPage> {
    TurmaAlunoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TurmaAlunoListBloc(
      Bootstrap.instance.firestore,
    );
    
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
        title: Text('Lista de alunos'),
      ),
      body: StreamBuilder<TurmaAlunoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<TurmaAlunoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                for (var aluno in snapshot.data.turmaAlunoList) {
                  listaWidget.add(Column(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          // trailing: Text('${turma.questaoNumeroAdicionado ?? 0 - turma.questaoNumeroExcluido ?? 0}'),
                          title: Text('''
Nome: ${aluno.nome}
'''),
                          // onTap: () {
                          //   Navigator.pushNamed(
                          //     context,
                          //     "/turma/crud",
                          //     arguments: turma.id,
                          //   );
                          // },
                        ),
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
                          
                        ],
                      )
                    ],
                  ));
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
            })
    );
  }
}