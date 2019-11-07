import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/paginas/pasta/pasta_situacao_list_bloc.dart';
import 'package:piprof/naosuportato/url_launcher.dart'
    if (dart.library.io) 'package:url_launcher/url_launcher.dart';

class PastaSituacaoListPage extends StatefulWidget {
  final AuthBloc authBloc;

  const PastaSituacaoListPage(this.authBloc);

  @override
  _PastaSituacaoListPageState createState() => _PastaSituacaoListPageState();
}

class _PastaSituacaoListPageState extends State<PastaSituacaoListPage> {
  PastaSituacaoListBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = PastaSituacaoListBloc(
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
        title: Text('Pastas e Situações'),
      ),
      body: StreamBuilder<PastaSituacaoListBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<PastaSituacaoListBlocState> snapshot) {
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
            SituacaoFk situacaoFk = SituacaoFk(id:situacao.id,nome: situacao.nome,url: situacao.url);
            widgetSituacaoList.add(ListTile(
              title: Text('${situacao.nome}'),
              trailing: Icon(Icons.check),
              onLongPress: (){
                launch(situacao.url);
              },
              onTap: () {
                // bloc.eventSink(SelecionarSituacaoEvent(situacao));
                Navigator.pop(context, situacaoFk);
              },
            ));
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
