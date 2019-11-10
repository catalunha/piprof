import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/paginas/pasta/pasta_list_bloc.dart';

class PastaListPage extends StatefulWidget {
  final AuthBloc authBloc;

  const PastaListPage(this.authBloc);
  @override
  _PastaListPageState createState() => _PastaListPageState();
}

class _PastaListPageState extends State<PastaListPage> {
  PastaListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = PastaListBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: Text('Pastas'),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/pasta/crud",
            arguments: null,
          );
        },
      ),
      body: StreamBuilder<PastaListBlocState>(
        stream: bloc.stateStream,
        builder:
            (BuildContext context, AsyncSnapshot<PastaListBlocState> snapshot) {
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
                title: Text('Lista de pastas em planilha'),
                trailing: Icon(Icons.recent_actors),
                onTap: () {
                  // GenerateCsvService.generateCsvFromPasta(widget.turmaID);
                },
              ),
            );
            int lengthTurma = snapshot.data.pastaList.length;

            int ordemLocal = 1;
            for (var pasta in snapshot.data.pastaList) {
              print('listando pasta: ${pasta.id}');
              listaWidget.add(
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('${pasta.nome}'),
                      ),
                      Center(
                        child: Wrap(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Editar este pasta',
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/pasta/crud",
                                  arguments: pasta.id,
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Descer ordem da turma',
                              icon: Icon(Icons.arrow_downward),
                              onPressed: (ordemLocal) < lengthTurma
                                  ? () {
                                      bloc.eventSink(
                                          OrdenarEvent(pasta, false));
                                    }
                                  : null,
                            ),
                            IconButton(
                              tooltip: 'Subir ordem da turma',
                              icon: Icon(Icons.arrow_upward),
                              onPressed: ordemLocal > 1
                                  ? () {
                                      bloc.eventSink(OrdenarEvent(pasta, true));
                                    }
                                  : null,
                            ),
                            IconButton(
                                    tooltip: 'Lista de situações em planilha',
                                    icon: Icon(Icons.recent_actors),
                                    onPressed: () {
                                      // GenerateCsvService.generateCsvFromEncontro(
                                      //     widget.pastaID);
                                    }),
                            IconButton(
                              tooltip: 'Gerenciar situações nesta pasta',
                              icon: Icon(Icons.folder),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/situacao/list",
                                  arguments: pasta.id,
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
        },
      ),
    );
  }
}
