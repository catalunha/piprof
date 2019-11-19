import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/naosuportato/url_launcher.dart' if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/paginas/problema/problema_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';

class ProblemaListPage extends StatefulWidget {
  final String pastaID;

  const ProblemaListPage(this.pastaID);
  @override
  _ProblemaListPageState createState() => _ProblemaListPageState();
}

class _ProblemaListPageState extends State<ProblemaListPage> {
  ProblemaListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = ProblemaListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetProblemaListEvent(widget.pastaID));
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
          title: Text('Problemas'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/problema/crud",
              arguments: ProblemaCRUDPageArguments(
                pastaID: widget.pastaID,
              ),
            );
          },
        ),
        body: StreamBuilder<ProblemaListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<ProblemaListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                int lengthTurma = snapshot.data.problemaList.length;
                int ordemLocal = 1;
                for (var problema in snapshot.data.problemaList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: problema.ativo ? null : Icon(Icons.airplanemode_inactive),
                            trailing: problema.precisaAlgoritmoPSimulacao == true ? Icon(Icons.code) : null,
                            title: Text('${problema.nome}'),
                            subtitle: Text('Simulações: ${problema.simulacaoNumero ?? 0}\n${problema.id}'),
                          ),
                          Center(
                            child: Wrap(
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Editar esta problema',
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/problema/crud",
                                      arguments: ProblemaCRUDPageArguments(problemaID: problema.id),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Descer ordem da turma',
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: (ordemLocal) < lengthTurma
                                      ? () {
                                          bloc.eventSink(OrdenarEvent(problema, false));
                                        }
                                      : null,
                                ),
                                IconButton(
                                  tooltip: 'Subir ordem da turma',
                                  icon: Icon(Icons.arrow_upward),
                                  onPressed: ordemLocal > 1
                                      ? () {
                                          bloc.eventSink(OrdenarEvent(problema, true));
                                        }
                                      : null,
                                ),
                                if (problema.url != null)
                                  IconButton(
                                    tooltip: 'Ver doc do problema',
                                    icon: Icon(Icons.local_library),
                                    onPressed: () {
                                      try {
                                        launch(problema.url);
                                      } catch (e) {}
                                    },
                                  ),
                                IconButton(
                                  tooltip: 'Listar de problema e simulações em planilha',
                                  icon: Icon(Icons.grid_on),
                                  onPressed: () {
                                    GenerateCsvService.csvProblemaListaSimulacao(problema);
                                  },
                                ),
                                IconButton(
                                    tooltip: 'Simulações',
                                    icon: Icon(Icons.bug_report),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/simulacao/list",
                                        arguments: problema.id,
                                      );
                                    }),
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
            }));
  }
}
