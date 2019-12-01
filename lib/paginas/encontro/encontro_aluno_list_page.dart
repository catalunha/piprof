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
                                    backgroundImage:
                                        NetworkImage(aluno.foto.url),
                                  ),
                          ),
                          Expanded(
                            flex: 8,
                            child: ListTile(
                              title: Text('${aluno.nome}'),
                              subtitle: Text(
                                  'Crachá: ${aluno.cracha}\nMat.: ${aluno.matricula}\nCel.: ${aluno.celular}\nid: ${aluno.id.substring(0, 10)}'),
                              trailing: item.value.presente
                                  ? Icon(Icons.check)
                                  : Icon(
                                      Icons.flight_takeoff,
                                      color: Colors.red,
                                    ),
                              onTap: () {
                                bloc.eventSink(MarcarAlunoEvent(aluno.id));
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
