import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/encontro/encontro_aluno_list_bloc.dart';

class EncontroAlunoListPage extends StatefulWidget {
  final String encontroID;

  const EncontroAlunoListPage({this.encontroID});
  @override
  _EncontroAlunoListPageState createState() => _EncontroAlunoListPageState();
}

class _EncontroAlunoListPageState extends State<EncontroAlunoListPage> {
  EncontroAlunoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = EncontroAlunoListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetAlunoListEvent(
      encontroID: widget.encontroID,
    ));
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
          title: Text('Marcar aluno presente'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cloud_upload),
          onPressed: () async {
            await bloc.eventSink(SaveEvent());
            Navigator.pop(context);
            // showDialog(
            //   context: context,
            //   builder: (context) => Dialog(
            //     elevation: 5,
            //     child: ListTile(
            //       selected: true,
            //       title: Text("Lista salva com sucesso."),
            //       onTap: () {},
            //     ),
            //   ),
            // );
          },
        ),
        body: StreamBuilder<EncontroAlunoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<EncontroAlunoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                for (var item in snapshot.data.alunoInfoMap.entries) {
                  var aluno = item.value.usuario;
                  var presente = item.value.presente;
                  listaWidget.add(Card(
                    child: Container(
                      // padding: EdgeInsets.symmetric(
                      //   vertical: 2,
                      //   horizontal: 2,
                      // ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: _ImagemUnica(url: aluno?.foto?.url),
                          ),
                          Expanded(
                            flex: 4,
                            // child: Container(
                            // padding: EdgeInsets.only(left: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Nome: ${aluno.nome}"),
                                Text("Crachá: ${aluno.cracha}"),
                                Text("Celular: ${aluno.celular}"),
                                Text("matricula: ${aluno.matricula}"),
                                Text("email: ${aluno.email}"),
                                Text("id: ${aluno.id}"),
                                Wrap(
                                  children: <Widget>[
                                    IconButton(
                                        tooltip: 'Aluno presente',
                                        icon: presente
                                            ? Icon(Icons.check)
                                            : Icon(
                                                Icons.flight_takeoff,
                                                color: Colors.red,
                                              ),
                                        onPressed: () {
                                          bloc.eventSink(
                                              MarcarAlunoEvent(aluno.id));
                                        }),
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
          flex: 8,
          child: foto,
        ),
        Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
