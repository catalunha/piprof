import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_selecionar_aluno_bloc.dart';

class AvaliacaoSelecionarAlunoPage extends StatefulWidget {
  final String avaliacaoID;

  const AvaliacaoSelecionarAlunoPage({this.avaliacaoID});
  @override
  _AvaliacaoSelecionarAlunoPageState createState() => _AvaliacaoSelecionarAlunoPageState();
}

class _AvaliacaoSelecionarAlunoPageState extends State<AvaliacaoSelecionarAlunoPage> {
  AvaliacaoSelecionarAlunoBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = AvaliacaoSelecionarAlunoBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetAlunoListEvent(
      widget.avaliacaoID,
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
          title: Text('Selecionar aluno'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cloud_upload),
          onPressed: () async {
            await bloc.eventSink(SaveEvent());
            showDialog(
              context: context,
              builder: (context) => Dialog(
                elevation: 5,
                child: ListTile(
                  selected: true,
                  title: Text("Lista salva com sucesso."),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        ),
        body: StreamBuilder<AvaliacaoSelecionarAlunoBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<AvaliacaoSelecionarAlunoBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                listaWidget.add(
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text('Alternar marcações:'),
                        IconButton(
                          tooltip: 'Selecionar todos',
                          icon: Icon(Icons.check_box),
                          onPressed: () {
                            bloc.eventSink(MarcarTodosEvent());
                          },
                        ),
                        IconButton(
                          tooltip: 'Desmarcar todos',
                          icon: Icon(Icons.check_box_outline_blank),
                          onPressed: () {
                            bloc.eventSink(DesmarcarTodosEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                );
                for (var item in snapshot.data.alunoInfoMap.entries) {
                  var aluno = item.value.usuario;
                  var aplicar = item.value.aplicar;
                  var aplicada = item.value.aplicada;
                  listaWidget.add(
                    Card(
                      color: aplicada ? Colors.green[900] : null,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                              leading: aluno.foto.url == null
                                  ? Text('')
                                  : CircleAvatar(
                                      minRadius: 25,
                                      maxRadius: 25,
                                      backgroundImage: NetworkImage(aluno.foto.url),
                                    ),
                              title: Text('${aluno.nome}'),
                              subtitle: Text('${aluno.matricula}'),
                              trailing: aplicada
                                  ? Text('')
                                  : aplicar
                                      ? Icon(Icons.check)
                                      : Icon(
                                          Icons.flight_takeoff,
                                          color: Colors.red,
                                        ),
                              onTap: aplicada
                                  ? null
                                  : () {
                                      bloc.eventSink(MarcarAlunoEvent(aluno.id));
                                    }),
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
