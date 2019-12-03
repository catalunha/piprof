import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/paginas/turma/turma_inativa_list_bloc.dart';

class TurmaInativaListPage extends StatefulWidget {
  final AuthBloc authBloc;

  const TurmaInativaListPage(this.authBloc);

  @override
  _TurmaInativaListPageState createState() => _TurmaInativaListPageState();
}

class _TurmaInativaListPageState extends State<TurmaInativaListPage> {
  TurmaInativaListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TurmaInativaListBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(UpdateTurmaInativaListEvent());
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
        title: Text('Turmas inativas'),
        body: StreamBuilder<TurmaInativaListBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<TurmaInativaListBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data.isDataValid) {
                List<Widget> listaWidget = List<Widget>();
                for (var turma in snapshot.data.turmaList) {
                  listaWidget.add(
                    Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text('''
Instit.: ${turma.instituicao}
Comp.: ${turma.componente}
Turma: ${turma.nome}'''),
                            subtitle: Text('${turma?.id}'),
                            onTap: () {
                              bloc.eventSink(AtivarTurmaEvent(turma.id));
                            },
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
}
