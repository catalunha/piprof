import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/turma/turma_aluno_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';

class TurmaAlunoListPage extends StatefulWidget {
  final String turmaID;

  const TurmaAlunoListPage(this.turmaID);
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
    bloc.eventSink(GetTurmaAlunoListEvent(widget.turmaID));
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
            builder: (BuildContext context,
                AsyncSnapshot<TurmaAlunoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                for (var aluno in snapshot.data.turmaAlunoList) {
                  listaWidget.add(
                    Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: aluno?.foto?.url == null
                                ? Text('')
                                : CircleAvatar(
                                    radius: 50,
                                    // minRadius: 35,
                                    // maxRadius: 35,
                                    backgroundImage:
                                        NetworkImage(aluno.foto.url),
                                  ),
                          ),
                          Expanded(
                            flex: 8,
                            child: ListTile(
                              // leading: aluno.foto.url == null
                              //     ? Text('')
                              //     : CircleAvatar(
                              //         radius: 40,
                              //         // minRadius: 35,
                              //         // maxRadius: 35,
                              //         backgroundImage:
                              //             NetworkImage(aluno.foto.url),
                              //       ),
                              title: Text('${aluno.nome}'),
                              subtitle: Text(
                                  'matricula: ${aluno.matricula}\nCelular: ${aluno.celular ?? '?'}\nemail: ${aluno.email}\nid: ${aluno.id.substring(0,10)}'),
                              trailing: IconButton(
                                tooltip: 'Gerar notas deste aluno',
                                icon: Icon(Icons.grid_on),
                                onPressed: () {
                                  GenerateCsvService.csvAlunoListaNota(aluno);
                                },
                              ),
                              onLongPress: () {
                                bloc.eventSink(DeleteAlunoEvent(aluno.id));
                              },
                            ),
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
