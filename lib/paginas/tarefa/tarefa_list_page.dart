import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/paginas/tarefa/tarefa_list_bloc.dart';
import 'package:queries/collections.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class TarefaListPage extends StatefulWidget {
  final String tarefaID;

  const TarefaListPage(this.tarefaID);
  @override
  _TarefaListPageState createState() => _TarefaListPageState();
}

class _TarefaListPageState extends State<TarefaListPage> {
  TarefaListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TarefaListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetTarefaListPorQuestaoEvent(widget.tarefaID));
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
          title: Text('Tarefa do aluno'),
        ),
        body: StreamBuilder<TarefaListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<TarefaListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                if (snapshot.data.pedidoRelatorio != null) {
                  launch(
                      'https://us-central1-pi-brintec.cloudfunctions.net/relatorioOnRequest/imprimirtarefa?pedido=${snapshot.data.pedidoRelatorio}');
                  bloc.eventSink(ResetCreateRelatorioEvent());
                }
                List<Widget> listaWidget = List<Widget>();
                String notas = '';
                Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();

                for (var tarefa in snapshot.data.tarefaList) {
                  gabaritoMap.clear();
                  var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
                  var gabaritoOrderBy = dicGabarito
                      .orderBy((kv) => kv.value.ordem)
                      .toDictionary$1((kv) => kv.key, (kv) => kv.value);
                  gabaritoMap = gabaritoOrderBy.toMap();
                  notas = '';
                  for (var gabarito in gabaritoMap.entries) {
                    notas +=
                        '${gabarito.value.nome}=${gabarito.value.nota ?? "?"} ';
                  }
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          card(
                        tarefa.aluno?.foto,
                        tarefa.aluno.nome,
                        notas,),
//                           ListTile(
//                             leading: tarefa.aluno?.foto == null
//                                 ? Text('')
//                                 : CircleAvatar(
//                                     minRadius: 25,
//                                     maxRadius: 25,
//                                     backgroundImage:
//                                         NetworkImage(tarefa.aluno.foto),
//                                   ),
//                             title: Text('${tarefa.aluno.nome}'),
//                             subtitle: Text('Sit.: $notas'),
//                           ),
                          ListTile(
                            title: Text('''Avaliação: ${tarefa.avaliacao.nome}
Questão: ${tarefa.questao.numero}. Prob.: ${tarefa.problema.nome}
Simulacao: ${tarefa.simulacao.nome}
Aberta: ${DateFormat('dd-MM HH:mm').format(tarefa.inicio)} até ${DateFormat('dd-MM HH:mm').format(tarefa.fim)}
Iniciou: ${tarefa.iniciou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.iniciou)} | Enviou ${tarefa.enviou == null ? '?' : DateFormat('dd-MM HH:mm').format(tarefa.enviou)}
Tempo: ${tarefa.tempo} h | Usou: ${tarefa.tentou ?? 0} das ${tarefa.tentativa} tentativas.'''),
                            subtitle: Text('id: ${tarefa.id}'),
                          ),
                          Wrap(
                            children: <Widget>[
                              IconButton(
                                tooltip: 'Editar tarefa para este aluno',
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/tarefa/crud",
                                    arguments: tarefa.id,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Reset tempo e tentativa',
                                icon: Icon(Icons.child_care),
                                onPressed: () {
                                  bloc.eventSink(ResetTempoTentativaTarefaEvent(
                                      tarefa.id));
                                },
                              ),
                              IconButton(
                                tooltip: 'Ver problema da questão',
                                icon: Icon(Icons.local_library),
                                onPressed: tarefa.problema.url != null &&
                                        tarefa.problema.url.isNotEmpty
                                    ? () {
                                        launch(tarefa.problema.url);
                                      }
                                    : null,
                              ),
                              IconButton(
                                tooltip: 'Versão impressa da tarefa',
                                icon: Icon(Icons.picture_as_pdf),
                                onPressed: () {
                                  bloc.eventSink(
                                      CreateRelatorioEvent(tarefa.id));
                                },
                              ),
                              IconButton(
                                tooltip: 'Corrigir tarefa',
                                icon: Icon(Icons.playlist_add_check),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/tarefa/corrigir",
                                    arguments: tarefa.id,
                                  );
                                },
                              ),
                            ],
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
            }));
  }

  card(String url, String nome,String nota) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: Container(
        height: 80.0,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 50.0,
              right: 5,
              child: Container(
                width: 290.0,
                height: 90.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.green[900],
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 30.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Nome: ${nome}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Sit.: ${nota}",
                            style: Theme.of(context).textTheme.subhead),
                        // Text("Celular: ${celular}",
                        //     style: Theme.of(context).textTheme.subhead),
                        // Text("Crachá: ${cracha}",
                        //     style: Theme.of(context).textTheme.subhead),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: 7,
                child: Container(
                  width: 70.0,
                  height: 70.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: url != null
                          ? NetworkImage(url)
                          : NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/PIBrintec_512x512px_Aluno.png?alt=media&token=3890ede1-b09f-48da-a07a-2eea315503fd"),
                    ),
                  ),
                )

                // Image.network("https://image.freepik.com/vetores-gratis/perfil-de-avatar-de-mulher-no-icone-redondo_24640-14042.jpg",height: 100,)
                ),
          ],
        ),
      ),
    );
  }
}
