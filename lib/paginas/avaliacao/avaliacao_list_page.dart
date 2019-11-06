import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';

class AvaliacaoListPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String turmaID;

  const AvaliacaoListPage(this.authBloc, this.turmaID);

  @override
  _AvaliacaoListPageState createState() => _AvaliacaoListPageState();
}

class _AvaliacaoListPageState extends State<AvaliacaoListPage> {
  AvaliacaoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = AvaliacaoListBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(GetTurmaIDEvent(widget.turmaID));
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
          title: Text('Suas Avaliações nesta turma'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/avaliacao/crud",
              arguments: AvaliacaoCRUDPageArguments(
                turmaID: widget.turmaID,
              ),
            );
          },
        ),
        body: StreamBuilder<AvaliacaoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<AvaliacaoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                for (var avaliacao in snapshot.data.avaliacaoList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            // leading: avaliacao.ativo ? Text('') : Icon(Icons.lock),
                            title: Text('''
Turma: ${avaliacao.turma.nome}
Avaliacao: ${avaliacao.nome}
Nota da avaliação: ${avaliacao.nota}'''),
                            trailing: Text(
                                '${DateFormat('dd-MM HH:mm').format(avaliacao.inicio)}\n${DateFormat('dd-MM HH:mm').format(avaliacao.fim)}'),
                          ),
                          Center(
                            child: Wrap(
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Editar esta avaliacao',
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/avaliacao/crud",
                                      arguments: AvaliacaoCRUDPageArguments(
                                          avaliacaoID: avaliacao.id),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Inserir questões',
                                  icon: Icon(Icons.format_list_numbered),
                                  onPressed: () {
                                    // Navigator.pushNamed(
                                    //   context,
                                    //   "/turma/encontro/crud",
                                    //   arguments: EncontroCRUDPageArguments(
                                    //       encontroID: encontro.id),
                                    // );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Aplicar esta avaliacao',
                                  icon: Icon(Icons.people),
                                  onPressed: () {
                                    // Navigator.pushNamed(
                                    //   context,
                                    //   "/turma/encontro/crud",
                                    //   arguments: EncontroCRUDPageArguments(
                                    //       encontroID: encontro.id),
                                    // );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Relatorio desta avaliação',
                                  icon: Icon(Icons.recent_actors),
                                  onPressed: () {
                                    // GenerateCsvService.generateCsvFromEncontro(
                                    //     widget.turmaID);
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
                return ListView(
                  children: listaWidget,
                );
              } else {
                return Text('Existem dados inválidos. Informe o suporte.');
              }
            }));
  }
}
