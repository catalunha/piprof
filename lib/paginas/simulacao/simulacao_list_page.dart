import 'package:flutter/foundation.dart';
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
            List<String> variavelList = List<String>();
            List<String> variavelTipoList = List<String>();
            List<String> gabaritoList = List<String>();
            List<String> gabaritoTipoList = List<String>();
            if (snapshot.data.simulacaoList != null &&
                snapshot.data.simulacaoList.length > 0) {
              if (snapshot.data?.simulacaoList[0]?.variavel != null) {
                for (var variavel
                    in snapshot.data?.simulacaoList[0].variavel.entries) {
                  variavelList.add(variavel.value.nome);
                }
                variavelList.sort((a, b) => a.compareTo(b));
                for (var variavel
                    in snapshot.data?.simulacaoList[0].variavel.entries) {
                  variavelTipoList.add(variavel.value.tipo);
                }
                variavelTipoList.sort((a, b) => a.compareTo(b));
                print('variaveis: $variavelList');
              }

              if (snapshot.data?.simulacaoList[0]?.gabarito != null) {
                for (var gabarito
                    in snapshot.data?.simulacaoList[0].gabarito.entries) {
                  gabaritoList.add(gabarito.value.nome);
                }
                gabaritoList.sort((a, b) => a.compareTo(b));

                for (var gabarito
                    in snapshot.data?.simulacaoList[0].gabarito.entries) {
                  gabaritoTipoList.add(gabarito.value.tipo);
                }
                gabaritoTipoList.sort((a, b) => a.compareTo(b));

                print('gabaritos: $gabaritoList');
              }
            }
            bool alerta = false;
            String msg = '';
            for (var simulacao in snapshot.data.simulacaoList) {
              if (simulacao?.gabarito?.length == null ||
                  simulacao?.gabarito?.length == 0) {
                alerta = true;
                msg = '\n\nFALTA GABARITO. FAVOR CORRIGIR !';
              } else {
                alerta = false;
                msg = '';
              }

              List<String> variavelListAtual = List<String>();
              List<String> variavelTipoListAtual = List<String>();
              if (simulacao.variavel != null) {
                variavelListAtual.clear();
                for (var variavel in simulacao.variavel.entries) {
                  variavelListAtual.add(variavel.value.nome);
                }
                variavelListAtual.sort((a, b) => a.compareTo(b));
                variavelTipoListAtual.clear();
                for (var variavel in simulacao.variavel.entries) {
                  variavelTipoListAtual.add(variavel.value.tipo);
                }
                variavelTipoListAtual.sort((a, b) => a.compareTo(b));
              }
              if (!listEquals(variavelList, variavelListAtual)) {
                print('${simulacao.nome}');
                print(variavelList);
                print(variavelListAtual);
                alerta = true;
                msg =
                    msg + '\n\nVALORES COM NOMES DIFERENTES. FAVOR CORRIGIR !';
              }
              if (!listEquals(variavelTipoList, variavelTipoListAtual)) {
                print('${simulacao.nome}');
                print(variavelList);
                print(variavelListAtual);
                alerta = true;
                msg =
                    msg + '\n\nVALORES COM TIPOS DIFERENTES. FAVOR CORRIGIR !';
              }

              List<String> gabaritoListAtual = List<String>();
              List<String> gabaritoTipoListAtual = List<String>();
              if (simulacao.gabarito != null) {
                gabaritoListAtual.clear();
                for (var gabarito in simulacao.gabarito.entries) {
                  gabaritoListAtual.add(gabarito.value.nome);
                }
                gabaritoListAtual.sort((a, b) => a.compareTo(b));
                gabaritoTipoListAtual.clear();
                for (var gabarito in simulacao.gabarito.entries) {
                  gabaritoTipoListAtual.add(gabarito.value.tipo);
                }
                gabaritoTipoListAtual.sort((a, b) => a.compareTo(b));
              }
              if (!listEquals(gabaritoList, gabaritoListAtual)) {
                print('${simulacao.nome}');
                print(gabaritoList);
                print(gabaritoListAtual);
                alerta = true;
                msg = msg +
                    '\n\nGABARITOS COM NOMES DIFERENTES. FAVOR CORRIGIR !';
              }
              if (!listEquals(gabaritoTipoList, gabaritoTipoListAtual)) {
                print('${simulacao.nome}');
                print(gabaritoList);
                print(gabaritoListAtual);
                alerta = true;
                msg = msg +
                    '\n\nGABARITOS COM TIPOS DIFERENTES. FAVOR CORRIGIR !';
              }

              listaWidget.add(
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        selected: alerta,
                        trailing: alerta ? Icon(Icons.alarm) : Text(''),
                        title: Text('${simulacao.nome}'),
                        subtitle: Text(
                          'Valores  : ${simulacao?.variavel?.length ?? 0}\nGabarito: ${simulacao?.gabarito?.length != null ? simulacao?.gabarito?.length : 0}$msg\nid:${simulacao.id}',
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
                            if (simulacao.url != null &&
                                simulacao.url.isNotEmpty)
                              IconButton(
                                tooltip: 'Ver arquivo da simulacao',
                                icon: Icon(Icons.local_library),
                                onPressed: () {
                                  launch(simulacao.url);
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
