import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';
import 'package:piprof/paginas/situacao/situacao_selecionar_bloc.dart';

class SituacaoSelecionarPage extends StatefulWidget {
  final AuthBloc authBloc;

  const SituacaoSelecionarPage(this.authBloc);

  @override
  _SituacaoSelecionarPageState createState() => _SituacaoSelecionarPageState();
}

class _SituacaoSelecionarPageState extends State<SituacaoSelecionarPage> {
  SituacaoSelecionarBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SituacaoSelecionarBloc(
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
      body: StreamBuilder<SituacaoSelecionarBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SituacaoSelecionarBlocState> snapshot) {
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

          List<Widget> widgetSituacaoList = List<Widget>();

          for (var situacao in snapshot.data.situacaoList) {
            SituacaoFk situacaoFk = SituacaoFk(
                id: situacao.id, nome: situacao.nome, url: situacao.url);
            if (situacao.simulacaoNumero == null ||
                situacao.simulacaoNumero <= 0) {
              widgetSituacaoList.add(
                Card(
                  child: ListTile(
                    selected: true,
                    title: Text('${situacao.nome}'),
                    subtitle: Text('SITUAÇÃO SEM SIMULAÇÕES ! FAVOR CORRIGIR.'),
                    onLongPress: () {
                      launch(situacao.url);
                    },
                  ),
                ),
              );
            } else {
              widgetSituacaoList.add(
                Card(
                  child: ListTile(
                    title: Text('${situacao.nome}'),
                    trailing: Icon(Icons.question_answer),
                    leading: IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      onPressed: () {
                        launch(situacao.url);
                      },
                    ),
                    onLongPress: () {
                      launch(situacao.url);
                    },
                    onTap: () {
                      // bloc.eventSink(SelecionarSituacaoEvent(situacao));
                      Navigator.pop(context, situacaoFk);
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
              ...widgetSituacaoList,
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
