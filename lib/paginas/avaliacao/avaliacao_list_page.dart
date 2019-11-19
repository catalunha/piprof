import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_list_bloc.dart';
import 'package:piprof/servicos/gerar_csv_service.dart';

class AvaliacaoListPage extends StatefulWidget {
  final String turmaID;

  const AvaliacaoListPage(this.turmaID);

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
    );
    bloc.eventSink(UpdateAvaliacaoListEvent(widget.turmaID));
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
          title: Text('Avaliações'),
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
// Widget alertaNovoAlunoQuestao
                for (var avaliacao in snapshot.data.avaliacaoList) {

                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            selected: !avaliacao.aplicada,
                            title: Text('''
Turma: ${avaliacao.turma.nome}
Avaliação: ${avaliacao.nome}
Alunos: ${avaliacao.aplicadaPAluno?.length ?? 0} | Questões: ${avaliacao.questaoAplicada?.length ?? 0}
Nota/Peso: ${avaliacao.nota}'''),
                            subtitle: Text('''
id: ${avaliacao.id}'''),
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
                                    Navigator.pushNamed(
                                      context,
                                      "/questao/list",
                                      arguments: avaliacao.id,
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Acrescentar aluno',
                                  icon: Icon(Icons.group_add),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/avaliacao/marcar",
                                      arguments: avaliacao.id,
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Notas desta avaliação',
                                  icon: Icon(Icons.grid_on),
                                  onPressed: () {
                                    GenerateCsvService.csvAvaliacaoListaNota(
                                        avaliacao);
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
