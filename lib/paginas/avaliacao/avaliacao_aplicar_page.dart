import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_aplicar_bloc.dart';

class AvaliacaoMarcarPage extends StatefulWidget {
  final String avaliacaoID;

  const AvaliacaoMarcarPage({this.avaliacaoID});
  @override
  _AvaliacaoMarcarPageState createState() => _AvaliacaoMarcarPageState();
}

class _AvaliacaoMarcarPageState extends State<AvaliacaoMarcarPage> {
  AvaliacaoAplicarBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = AvaliacaoAplicarBloc(
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
          title: Text('Aplicar avaliação'),
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
        body: StreamBuilder<AvaliacaoAplicarBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<AvaliacaoAplicarBlocState> snapshot) {
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
                  listaWidget.add(Card(
                    color: aplicada ? Colors.green[900] : null,
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
                            child: _ImagemUnica(url: aluno?.foto?.url),
                          ),
                          Expanded(
                            flex: 4,
                            // child: Container(
                            // padding: EdgeInsets.only(left: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Crachá: ${aluno.cracha}"),
                                Text("matricula: ${aluno.matricula}"),
                                Text("Nome: ${aluno.nome}"),
                                Text("Celular: ${aluno.celular}"),
                                Text("email: ${aluno.email}"),
                                // Text("id: ${aluno.id}"),
                                aplicada
                                    ? Text('... Ja aplicada ...')
                                    : Wrap(
                                        children: <Widget>[
                                          IconButton(
                                              tooltip:
                                                  'Selecionar aluno para fazer a avaliação',
                                              icon: aplicar
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
        // Spacer(
        //   flex: 1,
        // ),
        Expanded(
          flex: 4,
          child: foto,
        ),
        Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
