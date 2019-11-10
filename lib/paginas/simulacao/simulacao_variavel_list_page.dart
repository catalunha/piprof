import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_variavel_list_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class SimulacaoVariavelListPage extends StatefulWidget {
  final String simulacaoID;

  const SimulacaoVariavelListPage(this.simulacaoID);
  @override
  _SimulacaoVariavelListPageState createState() =>
      _SimulacaoVariavelListPageState();
}

class _SimulacaoVariavelListPageState extends State<SimulacaoVariavelListPage> {
  SimulacaoVariavelListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoVariavelListBloc(
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
        title: Text('Variáveis da simulação'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/simulacao/variavel/crud",
            arguments: SimulacaoVariavelCRUDPageArguments(
                simulacaoID: widget.simulacaoID),
          );
        },
      ),
      body: StreamBuilder<SimulacaoVariavelListBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoVariavelListBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.isDataValid) {
            List<Widget> listaWidget = List<Widget>();

            int lengthTurma = snapshot.data.variavelMap.length;
            int ordemLocal = 1;
            Widget icone;

            for (var variavel in snapshot.data.variavelMap.entries) {
              if (variavel.value.tipo == 'numero') {
                icone = Icon(Icons.looks_one);
              } else if (variavel.value.tipo == 'palavra') {
                icone = Icon(Icons.text_format);
              } else if (variavel.value.tipo == 'texto') {
                icone = Icon(Icons.text_fields);
              } else if (variavel.value.tipo == 'url') {
                icone = IconButton(
                  tooltip: 'Um link ao um site ou arquivo',
                  icon: Icon(Icons.link),
                  onPressed: () {
                    launch(variavel.value.valor);
                  },
                );
              } else if (variavel.value.tipo == 'imagem') {
                icone = IconButton(
                  tooltip: 'Click para ver a imagem',
                  icon: Icon(Icons.image),
                  onPressed: () {
                    launch(variavel.value.valor);
                  },
                );
              }

              listaWidget.add(
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('${variavel.value.nome}'),
                        subtitle: Text('${variavel?.value?.valor}'),
                        trailing: icone,
                      ),
                      Center(
                        child: Wrap(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Editar este variável',
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/simulacao/variavel/crud",
                                  arguments: SimulacaoVariavelCRUDPageArguments(
                                      simulacaoID: snapshot.data.simulacao.id,
                                      variavelKey: variavel.key),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Descer ordem da variavel',
                              icon: Icon(Icons.arrow_downward),
                              onPressed: (ordemLocal) < lengthTurma
                                  ? () {
                                      bloc.eventSink(OrdenarInMapEvent(
                                          variavel.key, false));
                                    }
                                  : null,
                            ),
                            IconButton(
                              tooltip: 'Subir ordem da variavel',
                              icon: Icon(Icons.arrow_upward),
                              onPressed: ordemLocal > 1
                                  ? () {
                                      bloc.eventSink(OrdenarInMapEvent(
                                          variavel.key, true));
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
              child: Text('Sem variáveis para listar.'),
            );
          }
        },
      ),
    );
  }
}
