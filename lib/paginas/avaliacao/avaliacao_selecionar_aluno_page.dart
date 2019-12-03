import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_selecionar_aluno_bloc.dart';

class AvaliacaoSelecionarAlunoPage extends StatefulWidget {
  final String avaliacaoID;

  const AvaliacaoSelecionarAlunoPage({this.avaliacaoID});
  @override
  _AvaliacaoSelecionarAlunoPageState createState() =>
      _AvaliacaoSelecionarAlunoPageState();
}

class _AvaliacaoSelecionarAlunoPageState
    extends State<AvaliacaoSelecionarAlunoPage> {
  AvaliacaoSelecionarAlunoBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = AvaliacaoSelecionarAlunoBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetAlunoListEvent(
      widget.avaliacaoID,
    ));
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
          title: Text('Selecionar aluno'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cloud_upload),
          onPressed: () async {
            await bloc.eventSink(SaveEvent());
            showDialog(
              context: context,
              builder: (context) => Dialog(
                elevation: 5,
                child: ListTile(
                  selected: true,
                  title: Text("Lista salva com sucesso."),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        ),
        body: StreamBuilder<AvaliacaoSelecionarAlunoBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<AvaliacaoSelecionarAlunoBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                listaWidget.add(
                  Card(
                    child: Row(
                      children: <Widget>[
                        Text('Alternar marcações:'),
                        IconButton(
                          tooltip: 'Selecionar todos',
                          icon: Icon(Icons.check_box),
                          onPressed: () {
                            bloc.eventSink(MarcarTodosEvent());
                          },
                        ),
                        IconButton(
                          tooltip: 'Desmarcar todos',
                          icon: Icon(Icons.check_box_outline_blank),
                          onPressed: () {
                            bloc.eventSink(DesmarcarTodosEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                );
                for (var item in snapshot.data.alunoInfoMap.entries) {
                  var aluno = item.value.usuario;
                  var aplicar = item.value.aplicar;
                  var aplicada = item.value.aplicada;
                  listaWidget.add(InkWell(
                    child: card(
                      aluno?.foto?.url,
                      aluno.nome,
                      aluno.matricula,
                      aluno.celular,
                      aluno.cracha,
                      aplicada,
                      aplicar
                    ),
                    onTap: aplicada
                        ? null
                        : () {
                            bloc.eventSink(MarcarAlunoEvent(aluno.id));
                          },
                  )
                      // Card(
                      //   color: aplicada ? Colors.green[900] : null,
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
                      //           subtitle: Text('${aluno.matricula}'),
                      //           trailing: aplicada
                      //               ? Text('')
                      //               : aplicar
                      //                   ? Icon(Icons.check)
                      //                   : Icon(
                      //                       Icons.flight_takeoff,
                      //                       color: Colors.red,
                      //                     ),
                      //           onTap: aplicada
                      //               ? null
                      //               : () {
                      //                   bloc.eventSink(MarcarAlunoEvent(aluno.id));
                      //                 },
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

  card(String url, String nome, String matricula, String celular, String cracha,
      bool aplicada,bool aplicar) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: Container(
        height: 120.0,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 50.0,
              right: 5,
              child: Container(
                width: 290.0,
                height: 120.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: aplicada ? Colors.green[900] : aplicar ? Colors.blue[700] : Colors.black38,
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
                        Text("Nome: $nome",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Matrícula: $matricula",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Celular: $celular",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Crachá: $cracha",
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
