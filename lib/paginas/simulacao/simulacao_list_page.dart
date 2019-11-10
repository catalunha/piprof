import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_list_bloc.dart';

class SimulacaoListPage extends StatefulWidget {
  final String situacaoID;

  const SimulacaoListPage(this.situacaoID);
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
    bloc.eventSink(GetSimulacaoEvent(widget.situacaoID));
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
              situacaoID: widget.situacaoID,
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
                        title: Text('${simulacao.nome}'),
                        subtitle: Text(
                            '${simulacao.descricao}\nVariáveis: ${simulacao?.variavel?.length ?? 0}\nPede-se: ${simulacao?.pedese?.length ?? 0}\nid:${simulacao.id}'),
                      ),
                      Center(
                        child: Wrap(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Editar este simulação',
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/crud",
                                  arguments: SimulacaoCRUDPageArguments(
                                    simulacaoID: simulacao.id,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Gerenciar variáveis',
                              icon: Icon(Icons.videogame_asset),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/variavel/list",
                                  arguments: simulacao.id,
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Gerenciar Pede-se',
                              icon: Icon(Icons.assignment),
                              onPressed: () {
                                 Navigator.pushNamed(
                                  context,
                                  "/simulacao/pedese/list",
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
