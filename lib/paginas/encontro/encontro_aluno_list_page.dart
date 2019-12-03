import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/encontro/encontro_aluno_list_bloc.dart';

class EncontroAlunoListPage extends StatefulWidget {
  final String encontroID;

  const EncontroAlunoListPage({this.encontroID});
  @override
  _EncontroAlunoListPageState createState() => _EncontroAlunoListPageState();
}

class _EncontroAlunoListPageState extends State<EncontroAlunoListPage> {
  EncontroAlunoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = EncontroAlunoListBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetAlunoListEvent(
      encontroID: widget.encontroID,
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
          title: Text('Marcar aluno presente'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cloud_upload),
          onPressed: () async {
            await bloc.eventSink(SaveEvent());
            Navigator.pop(context);
          },
        ),
        body: StreamBuilder<EncontroAlunoListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<EncontroAlunoListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();

                for (var item in snapshot.data.alunoInfoMap.entries) {
                  var aluno = item.value.usuario;
                  listaWidget.add(InkWell(
                    child: card(
                        aluno?.foto?.url,
                        aluno.nome,
                        aluno.matricula,
                        aluno.celular,
                        aluno.cracha,
                        item.value.presente),
                        
                    onTap: () {
                      bloc.eventSink(MarcarAlunoEvent(aluno.id));
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
                      //                 backgroundImage:
                      //                     NetworkImage(aluno.foto.url),
                      //               ),
                      //       ),
                      //       Expanded(
                      //         flex: 8,
                      //         child: ListTile(
                      //           title: Text('${aluno.nome}'),
                      //           subtitle: Text(
                      //               'Crachá: ${aluno.cracha}\nMat.: ${aluno.matricula}\nCel.: ${aluno.celular}\nid: ${aluno.id.substring(0, 10)}'),
                      //           trailing: item.value.presente
                      //               ? Icon(Icons.check)
                      //               : Icon(
                      //                   Icons.flight_takeoff,
                      //                   color: Colors.red,
                      //                 ),
                      //           onTap: () {
                      //             bloc.eventSink(MarcarAlunoEvent(aluno.id));
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

  card(String url, String nome, String matricula, String celular, String cracha,
      bool marcar) {
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
                  color: marcar ? Colors.green[900] : Colors.black38,
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
                        Text("Matrícula: ${matricula}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Celular: ${celular}",
                            style: Theme.of(context).textTheme.subhead),
                        Text("Crachá: ${cracha}",
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
