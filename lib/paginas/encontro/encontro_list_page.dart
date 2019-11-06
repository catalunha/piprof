import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/encontro/encontro_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';

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
                List<Widget> listaWidget = List<Widget>();
                listaWidget.add(
                  ListTile(
                    title: Text('Lista de encontros em planilha'),
                    trailing: Icon(Icons.recent_actors),
                    onTap: () {
                      GenerateCsvService.generateCsvFromEncontro(
                          widget.turmaID);
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
                            trailing: Text(
                                '${DateFormat('dd-MM HH:mm').format(encontro.inicio)}\n${DateFormat('dd-MM HH:mm').format(encontro.fim)}'),
                          ),
                          Center(
                            child: Wrap(
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Marcar presença de alunos',
                                  icon: Icon(Icons.person_pin_circle),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/turma/encontro/aluno",
                                      arguments: encontro.id,
                                    );
                                  },
                                ),
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
