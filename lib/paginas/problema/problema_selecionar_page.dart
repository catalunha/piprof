import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/paginas/problema/problema_selecionar_bloc.dart';

class ProblemaSelecionarPage extends StatefulWidget {
  final AuthBloc authBloc;

  const ProblemaSelecionarPage(this.authBloc);

  @override
  _ProblemaSelecionarPageState createState() => _ProblemaSelecionarPageState();
}

class _ProblemaSelecionarPageState extends State<ProblemaSelecionarPage> {
  ProblemaSelecionarBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = ProblemaSelecionarBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
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
        title: Text('Selecione um problema'),
      ),
      body: StreamBuilder<ProblemaSelecionarBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<ProblemaSelecionarBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.pasta == null) {
            final widgetPastaList = snapshot.data.pastaList
                .map(
                  (pasta) => Pasta(
                    pasta: pasta,
                    onSelecionar: () {
                      bloc.eventSink(SelecionarPastaEvent(pasta));
                    },
                  ),
                )
                .toList();
            return ListView(children: [
              ...widgetPastaList,
              Container(
                padding: EdgeInsets.only(top: 80),
              )
            ]);
          }

          List<Widget> widgetProblemaList = List<Widget>();

          for (var problema in snapshot.data.problemaList) {
            ProblemaFk problemaFk = ProblemaFk(
                id: problema.id, nome: problema.nome, url: problema.url);
            if (problema.simulacaoNumero == null ||
                problema.simulacaoNumero <= 0) {
              widgetProblemaList.add(
                Card(
                  child: ListTile(
                    selected: true,
                    title: Text('${problema.nome}'),
                    subtitle: Text('SITUAÇÃO SEM SIMULAÇÕES ! FAVOR CORRIGIR.'),
                  ),
                ),
              );
            } else {
              widgetProblemaList.add(
                Card(
                  child: ListTile(
                    title: Text('${problema.nome}'),
                    subtitle: Text(
                        'Fonte: ${problema.descricao}\nSimulações: ${problema.simulacaoNumero}'),
                    trailing: Icon(Icons.check),
                    leading: problema.url != null && problema.url.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.local_library),
                            onPressed: () {
                              launch(problema.url);
                            },
                          )
                        : null,
                    onTap: () {
                      // bloc.eventSink(SelecionarProblemaEvent(problema));
                      Navigator.pop(context, problemaFk);
                    },
                  ),
                ),
              );
            }
          }
          return ListView(
            children: [
              Pasta(
                pasta: snapshot.data.pasta,
                onRemover: () {
                  bloc.eventSink(RemoverPastaEvent());
                },
              ),
              ...widgetProblemaList,
              Container(
                padding: EdgeInsets.only(top: 80),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Pasta extends StatelessWidget {
  final PastaModel pasta;
  final Function onSelecionar;
  final Function onRemover;

  const Pasta({Key key, this.pasta, this.onSelecionar, this.onRemover})
      : assert(onSelecionar == null && onRemover != null ||
            onSelecionar != null && onRemover == null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${pasta.nome}"),
      trailing: InkWell(
        child:
            onSelecionar == null ? Icon(Icons.folder_open) : Icon(Icons.folder),
        onTap: onSelecionar == null ? onRemover : onSelecionar,
      ),
    );
  }
}
