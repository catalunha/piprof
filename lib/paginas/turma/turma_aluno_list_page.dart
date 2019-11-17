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
                  listaWidget.add(Card(
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
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: _ImagemUnica(url: aluno?.foto?.url),
                              )),
                          Expanded(
                            flex: 5,
                            // child: Container(
                            // padding: EdgeInsets.only(left: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Nome: ${aluno.nome}"),
                                Text("matricula: ${aluno.matricula}"),
                                Text("Crachá: ${aluno.cracha ?? '?'}"),
                                Text("Celular: ${aluno.celular ?? '?'}"),
                                Text("email: ${aluno.email}"),
                                Text("id: ${aluno.id}"),
                                Wrap(
                                  children: <Widget>[
                                    IconButton(
                                      tooltip: 'Retirar aluno desta turma',
                                      icon: Icon(Icons.delete_forever),
                                      onPressed: () {
                                        bloc.eventSink(
                                            DeleteAlunoEvent(aluno.id));
                                      },
                                    ),
                                    // IconButton(
                                    //     tooltip: 'Desativar aluno',
                                    //     icon: aluno.ativo
                                    //         ? Icon(Icons.lock_open)
                                    //         : Icon(
                                    //             Icons.lock_outline,
                                    //             color: Colors.red,
                                    //           ),
                                    //     onPressed: () {
                                    //       bloc.eventSink(
                                    //           DesativarAlunoEvent(aluno.id));
                                    //     }),
                                    Text('                 '),
                                    IconButton(
                                      tooltip: 'Gerar notas deste aluno',
                                      icon: Icon(Icons.grid_on),
                                      onPressed: () {
                                        GenerateCsvService.csvAlunoListaNota(
                                            aluno);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // ),
                          ),
                        ],
                      ),
                    ),
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
