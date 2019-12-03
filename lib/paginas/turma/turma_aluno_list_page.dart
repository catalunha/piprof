import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/turma/turma_aluno_list_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class TurmaAlunoListPage extends StatefulWidget {
  final String turmaID;

  const TurmaAlunoListPage(this.turmaID);
  @override
  _TurmaAlunoListPageState createState() => _TurmaAlunoListPageState();
}

class _TurmaAlunoListPageState extends State<TurmaAlunoListPage> {
  TurmaAlunoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TurmaAlunoListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetTurmaAlunoListEvent(widget.turmaID));
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
          title: Text('Lista de alunos'),
        ),
        body: StreamBuilder<TurmaAlunoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<TurmaAlunoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                if (snapshot.data.pedidoRelatorio != null) {
                  launch(
                      'https://us-central1-pi-brintec.cloudfunctions.net/relatorioOnRequest/listadetarefasdoaluno?pedido=${snapshot.data.pedidoRelatorio}');
                  bloc.eventSink(ResetCreateRelatorioEvent());
                }
                for (var aluno in snapshot.data.turmaAlunoList) {
                  listaWidget.add(InkWell(
                    child: card(
                      aluno?.foto?.url,
                      aluno.nome,
                      aluno.matricula,
                      aluno.email,
                      aluno.celular,
                      aluno.cracha,
                      aluno.id.substring(0, 10),
                    ),
                    onTap: () {
                      bloc.eventSink(CreateRelatorioEvent(aluno.id));
                    },
                    onLongPress: () {
                      bloc.eventSink(DeleteAlunoEvent(aluno.id));
                    },
                  )

                      // Card(
                      //   child: Row(
                      //     children: <Widget>[
                      //       Expanded(
                      //         flex: 2,
                      //         child: aluno?.foto?.url == null
                      //             ? Text('')
                      //             : CircleAvatar(
                      //                 radius: 50,
                      //                 backgroundImage: NetworkImage(aluno.foto.url),
                      //               ),
                      //       ),
                      //       Expanded(
                      //         flex: 8,
                      //         child: ListTile(
                      //           title: Text('${aluno.nome}'),
                      //           subtitle: Text(
                      //               'Crachá: ${aluno.cracha ?? '?'}\nmatricula: ${aluno.matricula}\nemail: ${aluno.email}\nCelular: ${aluno.celular ?? '?'}\nid: ${aluno.id.substring(0, 10)}'),
                      //           trailing: IconButton(
                      //             tooltip: 'Gerar notas deste aluno',
                      //             icon: Icon(Icons.grid_on),
                      //             onPressed: () {
                      //               bloc.eventSink(CreateRelatorioEvent(aluno.id));
                      //             },
                      //           ),
                      //           onLongPress: () {
                      //             bloc.eventSink(DeleteAlunoEvent(aluno.id));
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

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

  card(
    String url,
    String nome,
    String matricula,
    String email,
    String celular,
    String cracha,
    String id,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: Container(
        height: 160.0,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 50.0,
              right: 5,
              child: Container(
                width: 290.0,
                height: 160.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.green[900],
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 44.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Nome: ${nome}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("matricula: ${matricula}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("E-mail: ${email}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Celular: ${celular}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Cracha: ${cracha}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Id: ${id}",
                            style: Theme.of(context).textTheme.subhead),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: 10,
                child: Container(
                  width: 80.0,
                  height: 80.0,
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
