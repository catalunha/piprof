import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_list_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class SimulacaoListPage extends StatefulWidget {
  final String problemaID;

  const SimulacaoListPage(this.problemaID);
  @override
  _SimulacaoListPageState createState() => _SimulacaoListPageState();
}

class _SimulacaoListPageState extends State<SimulacaoListPage> {
  SimulacaoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetSimulacaoEvent(widget.problemaID));
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
        title: Text('Simulações'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/simulacao/crud",
            arguments: SimulacaoCRUDPageArguments(
              problemaID: widget.problemaID,
            ),
          );
        },
      ),
      body: StreamBuilder<SimulacaoListBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoListBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();

            for (var simulacao in snapshot.data.simulacaoList) {
              listaWidget.add(
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        selected: simulacao?.gabarito?.length == null ||
                                simulacao?.gabarito?.length == 0
                            ? true
                            : false,
                        title: Text('${simulacao.nome}'),
                        subtitle: Text(
                          'Variaveis: ${simulacao?.variavel?.length ?? 0} | Gabarito: ${simulacao?.gabarito?.length == null || simulacao?.gabarito?.length == 0 ? '\n\nFALTA PEDE-SE. FAVOR CORRIGIR !\n\n' : simulacao?.gabarito?.length}\nid:${simulacao.id}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Um link ao um site ou arquivo',
                          icon: Icon(Icons.link),
                          onPressed: simulacao.url != null
                              ? () {
                                  launch(simulacao.url);
                                }
                              : null,
                        ),
                      ),
                      Center(
                        child: Wrap(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Editar esta simulação',
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/crud",
                                  arguments: SimulacaoCRUDPageArguments(
                                    simulacaoID: simulacao.id,
                                    problemaID: widget.problemaID,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Gerenciar valores',
                              icon: Icon(Icons.sort_by_alpha),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/variavel/list",
                                  arguments: simulacao.id,
                                );
                              },
                            ),
                            
                            IconButton(
                              tooltip: 'Gerenciar gabarito',
                              icon: Icon(Icons.question_answer),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/gabarito/list",
                                  arguments: simulacao.id,
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
        },
      ),
    );
  }
}
