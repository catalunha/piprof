import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/naosuportato/naosuportado.dart';
import 'package:piprof/paginas/situacao/situacao_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';

class SituacaoListPage extends StatefulWidget {
  final String pastaID;

  const SituacaoListPage(this.pastaID);
  @override
  _SituacaoListPageState createState() => _SituacaoListPageState();
}

class _SituacaoListPageState extends State<SituacaoListPage> {
  SituacaoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SituacaoListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetSituacaoListEvent(widget.pastaID));
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
          title: Text('Lista de situações'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/situacao/crud",
              arguments: SituacaoCRUDPageArguments(
                pastaID: widget.pastaID,
              ),
            );
          },
        ),
        body: StreamBuilder<SituacaoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<SituacaoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                int lengthTurma = snapshot.data.situacaoList.length;
                int ordemLocal = 1;
                for (var situacao in snapshot.data.situacaoList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: situacao.ativo
                                ? null
                                : Icon(Icons.airplanemode_inactive),
                            trailing: situacao.precisaAlgoritmoPSimulacao ==
                                        true
                                ? Icon(Icons.code)
                                : null,
                            title: Text('${situacao.nome}'),
                            subtitle:
                                Text('${situacao.descricao}\n${situacao.id}'),
                          ),
                          Center(
                            child: Wrap(
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Editar esta situação',
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/situacao/crud",
                                      arguments: SituacaoCRUDPageArguments(
                                          situacaoID: situacao.id),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Descer ordem da turma',
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: (ordemLocal) < lengthTurma
                                      ? () {
                                          bloc.eventSink(
                                              OrdenarEvent(situacao, false));
                                        }
                                      : null,
                                ),
                                IconButton(
                                  tooltip: 'Subir ordem da turma',
                                  icon: Icon(Icons.arrow_upward),
                                  onPressed: ordemLocal > 1
                                      ? () {
                                          bloc.eventSink(
                                              OrdenarEvent(situacao, true));
                                        }
                                      : null,
                                ),
                                if (situacao.url != null)
                                  IconButton(
                                    tooltip: 'Ver pdf da situação',
                                    icon: Icon(Icons.picture_as_pdf),
                                    onPressed: () {
                                      launch(situacao.url);
                                    },
                                  ),
                                IconButton(
                                  tooltip: 'Lista de situações em planilha',
                                  icon: Icon(Icons.recent_actors),
                                  onPressed: () {
                                    // GenerateCsvService.generateCsvFromEncontro(
                                    //     widget.pastaID);
                                  },
                                ),
                                IconButton(
                                    tooltip: 'Lista de simulações',
                                    icon: Icon(Icons.bug_report),
                                    onPressed: () {
                                      // GenerateCsvService.generateCsvFromEncontro(
                                      //     widget.pastaID);
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
