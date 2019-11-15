import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/paginas/simulacao/simulacao_pedese_list_bloc.dart';

class SimulacaoPedeseListPage extends StatefulWidget {
  final String simulacaoID;

  const SimulacaoPedeseListPage(this.simulacaoID);
  @override
  _SimulacaoPedeseListPageState createState() =>
      _SimulacaoPedeseListPageState();
}

class _SimulacaoPedeseListPageState extends State<SimulacaoPedeseListPage> {
  SimulacaoPedeseListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoPedeseListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetSimulacaoEvent(widget.simulacaoID));
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
        title: Text('Gabarito'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/simulacao/pedese/crud",
            arguments: SimulacaoPedeseCRUDPageArguments(
                simulacaoID: widget.simulacaoID),
          );
        },
      ),
      body: StreamBuilder<SimulacaoPedeseListBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoPedeseListBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();

            int lengthTurma = snapshot.data.pedeseMap.length;
            int ordemLocal = 1;
            Widget icone;
            for (var pedese in snapshot.data.pedeseMap.entries) {
              if (pedese.value.tipo == 'numero') {
                icone = Icon(Icons.looks_one);
              } else if (pedese.value.tipo == 'palavra') {
                icone = Icon(Icons.text_format);
              } else if (pedese.value.tipo == 'texto') {
                icone = Icon(Icons.text_fields);
              } else if (pedese.value.tipo == 'url') {
                icone = IconButton(
                  tooltip: 'Um link ao um site ou arquivo',
                  icon: Icon(Icons.link),
                  onPressed: () {
                    launch(pedese.value.gabarito);
                  },
                );
              } else if (pedese.value.tipo == 'urlimagem') {
                icone = IconButton(
                  tooltip: 'Um link ao uma imagem',
                  icon: Icon(Icons.image),
                  onPressed: () {
                    launch(pedese.value.gabarito);
                  },
                );
              } else if (pedese.value.tipo == 'arquivo') {
                icone = IconButton(
                  tooltip: 'Um arquivo anexado',
                  icon: Icon(Icons.description),
                  onPressed: () {
                    launch(pedese.value.gabarito);
                  },
                );
              } else if (pedese.value.tipo == 'imagem') {
                icone = IconButton(
                  tooltip: 'Uma imagem anexada',
                  icon: Icon(Icons.add_photo_alternate),
                  onPressed: () {
                    launch(pedese.value.gabarito);
                  },
                );
              }

              listaWidget.add(
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('${pedese.value.nome}'),
                        subtitle: Text('${pedese.value.gabarito}'),
                        trailing: icone,
                      ),
                      Center(
                        child: Wrap(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Editar este Pede-se',
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/pedese/crud",
                                  arguments: SimulacaoPedeseCRUDPageArguments(
                                      simulacaoID: snapshot.data.simulacao.id,
                                      pedeseKey: pedese.key),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Descer ordem da Pede-se',
                              icon: Icon(Icons.arrow_downward),
                              onPressed: (ordemLocal) < lengthTurma
                                  ? () {
                                      bloc.eventSink(
                                          OrdenarInMapEvent(pedese.key, false));
                                    }
                                  : null,
                            ),
                            IconButton(
                              tooltip: 'Subir ordem da Pede-se',
                              icon: Icon(Icons.arrow_upward),
                              onPressed: ordemLocal > 1
                                  ? () {
                                      bloc.eventSink(
                                          OrdenarInMapEvent(pedese.key, true));
                                    }
                                  : null,
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
            return Center(
              child: Text('Sem pedese para listar.'),
            );
          }
        },
      ),
    );
  }
}
