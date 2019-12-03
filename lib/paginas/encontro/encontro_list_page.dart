import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/encontro/encontro_list_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class EncontroListPage extends StatefulWidget {
  final String turmaID;

  const EncontroListPage(this.turmaID);
  @override
  _EncontroListPageState createState() => _EncontroListPageState();
}

class _EncontroListPageState extends State<EncontroListPage> {
  EncontroListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = EncontroListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetTurmaEncontroListEvent(widget.turmaID));
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
          title: Text('Lista de encontros'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/turma/encontro/crud",
              arguments: EncontroCRUDPageArguments(
                turmaID: widget.turmaID,
              ),
            );
          },
        ),
        body: StreamBuilder<EncontroListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<EncontroListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                if (snapshot.data.pedidoRelatorio != null) {
                  launch(
                      'https://us-central1-pi-brintec.cloudfunctions.net/relatorioOnRequest/listadeencontros?pedido=${snapshot.data.pedidoRelatorio}');
                  bloc.eventSink(ResetCreateRelatorioEvent());
                }
                List<Widget> listaWidget = List<Widget>();
                listaWidget.add(
                  ListTile(
                    title: Text('Lista de encontros em planilha'),
                    trailing: Icon(Icons.grid_on),
                    onTap: () {
                      bloc.eventSink(CreateRelatorioEvent(widget.turmaID));
                    },
                  ),
                );
                for (var encontro in snapshot.data.encontroList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text('${encontro.nome}'),
                            subtitle: Text(
                                'Alunos: ${encontro?.aluno?.length ?? 0}\nid: ${encontro.id}'),
                            trailing: Text(
                                '${DateFormat('dd-MM HH:mm').format(encontro?.inicio)}\n${DateFormat('dd-MM HH:mm').format(encontro?.fim)}'),
                          ),
                          Center(
                            child: Wrap(
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Editar este encontro',
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/turma/encontro/crud",
                                      arguments: EncontroCRUDPageArguments(
                                          encontroID: encontro.id),
                                    );
                                  },
                                ),
                                if (encontro.url != null &&
                                    encontro.url.isNotEmpty)
                                  IconButton(
                                    tooltip: 'Ver doc do encontro',
                                    icon: Icon(Icons.local_library),
                                    onPressed: () {
                                      try {
                                        launch(encontro.url);
                                      } catch (e) {}
                                    },
                                  ),
                                IconButton(
                                  tooltip: 'Marcar presença de alunos',
                                  icon: Icon(Icons.person_add),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/turma/encontro/aluno",
                                      arguments: encontro.id,
                                    );
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
