import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/paginas/simulacao/simulacao_gabarito_list_bloc.dart';

class SimulacaoGabaritoListPage extends StatefulWidget {
  final String simulacaoID;

  const SimulacaoGabaritoListPage(this.simulacaoID);
  @override
  _SimulacaoGabaritoListPageState createState() =>
      _SimulacaoGabaritoListPageState();
}

class _SimulacaoGabaritoListPageState extends State<SimulacaoGabaritoListPage> {
  SimulacaoGabaritoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoGabaritoListBloc(
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
            "/simulacao/gabarito/crud",
            arguments: SimulacaoGabaritoCRUDPageArguments(
                simulacaoID: widget.simulacaoID),
          );
        },
      ),
      body: StreamBuilder<SimulacaoGabaritoListBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoGabaritoListBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();

            int lengthTurma = snapshot.data.gabaritoMap.length;
            int ordemLocal = 1;
            Widget icone;
            for (var gabarito in snapshot.data.gabaritoMap.entries) {
              if (gabarito.value.tipo == 'numero') {
                icone = Icon(Icons.looks_one);
              } else if (gabarito.value.tipo == 'palavra') {
                icone = Icon(Icons.text_format);
              } else if (gabarito.value.tipo == 'texto') {
                icone = Icon(Icons.text_fields);
              } else if (gabarito.value.tipo == 'url') {
                icone = IconButton(
                  tooltip: 'Um link ao um site ou arquivo',
                  icon: Icon(Icons.link),
                  onPressed: () {
                    launch(gabarito.value.valor);
                  },
                );
              } else if (gabarito.value.tipo == 'urlimagem') {
                icone = IconButton(
                  tooltip: 'Um link ao uma imagem',
                  icon: Icon(Icons.image),
                  onPressed: () {
                    launch(gabarito.value.valor);
                  },
                );
              } else if (gabarito.value.tipo == 'arquivo') {
                icone = IconButton(
                  tooltip: 'Um arquivo anexado',
                  icon: Icon(Icons.description),
                  onPressed: () {
                    launch(gabarito.value.valor);
                  },
                );
              } else if (gabarito.value.tipo == 'imagem') {
                icone = IconButton(
                  tooltip: 'Uma imagem anexada',
                  icon: Icon(Icons.add_photo_alternate),
                  onPressed: () {
                    launch(gabarito.value.valor);
                  },
                );
              }

              listaWidget.add(
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('${gabarito.value.nome}'),
                        subtitle: Text('${gabarito.value.valor}'),
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
                                  "/simulacao/gabarito/crud",
                                  arguments: SimulacaoGabaritoCRUDPageArguments(
                                      simulacaoID: snapshot.data.simulacao.id,
                                      gabaritoKey: gabarito.key),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Descer ordem da Pede-se',
                              icon: Icon(Icons.arrow_downward),
                              onPressed: (ordemLocal) < lengthTurma
                                  ? () {
                                      bloc.eventSink(
                                          OrdenarInMapEvent(gabarito.key, false));
                                    }
                                  : null,
                            ),
                            IconButton(
                              tooltip: 'Subir ordem da Pede-se',
                              icon: Icon(Icons.arrow_upward),
                              onPressed: ordemLocal > 1
                                  ? () {
                                      bloc.eventSink(
                                          OrdenarInMapEvent(gabarito.key, true));
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
              child: Text('Sem gabarito para listar.'),
            );
          }
        },
      ),
    );
  }
}
