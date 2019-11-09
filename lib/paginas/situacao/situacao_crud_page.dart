import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/situacao/situacao_crud_bloc.dart';

class SituacaoCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String pastaID;
  final String situacaoID;

  const SituacaoCRUDPage({
    this.authBloc,
    this.pastaID,
    this.situacaoID,
  });

  @override
  _SituacaoCRUDPageState createState() => _SituacaoCRUDPageState();
}

class _SituacaoCRUDPageState extends State<SituacaoCRUDPage> {
  SituacaoCRUDBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SituacaoCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    if (widget.pastaID != null) bloc.eventSink(GetPastaEvent(widget.pastaID));
    if (widget.situacaoID != null)
      bloc.eventSink(GetSituacaoEvent(widget.situacaoID));
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
        title: Text('Criar ou Editar situação'),
      ),
      floatingActionButton: StreamBuilder<SituacaoCRUDBlocState>(
          stream: bloc.stateStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return FloatingActionButton(
              onPressed: snapshot.data.isDataValid
                  ? () {
                      bloc.eventSink(SaveEvent());
                      Navigator.pop(context);
                    }
                  : null,
              child: Icon(Icons.cloud_upload),
              backgroundColor:
                  snapshot.data.isDataValid ? Colors.blue : Colors.grey,
            );
          }),
      body: StreamBuilder<SituacaoCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SituacaoCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.all(5),
            children: <Widget>[
              if (snapshot.data?.liberaAtivo())
                SwitchListTile(
                  title: Text(
                    'Situação ativa ? ',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  ),
                  value: snapshot.data?.ativo,
                  onChanged: (bool value) {
                    bloc.eventSink(UpdateAtivoEvent(value));
                  },
                  // secondary: Icon(Icons.thumbs_up_down),
                ),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: SituacaoNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0), child: SituacaoDescricao(bloc)),
              SwitchListTile(
                title: Text(
                  'Precisa de algoritmo para simulação ? ',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
                value: snapshot.data?.precisaAlgoritmoPSimulacao ?? false,
                onChanged: (bool value) {
                  bloc.eventSink(UpdatePrecisaAlgoritmoPSimulacaoEvent(value));
                },
              ),
              if (snapshot.data?.precisaAlgoritmoPSimulacao != null &&
                  snapshot.data?.precisaAlgoritmoPSimulacao == false)
                Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Url para PDF da situação:',
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    )),
              if (snapshot.data?.precisaAlgoritmoPSimulacao != null &&
                  snapshot.data?.precisaAlgoritmoPSimulacao == false)
                Padding(padding: EdgeInsets.all(5.0), child: SituacaoPdf(bloc)),
              Divider(),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: DeleteDocument(
                  onDelete: () {
                    bloc.eventSink(DeleteDocumentEvent());
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 100)),
            ],
            // ),
          );
        },
      ),
    );
  }
}

class SituacaoNome extends StatefulWidget {
  final SituacaoCRUDBloc bloc;
  SituacaoNome(this.bloc);
  @override
  SituacaoNomeState createState() {
    return SituacaoNomeState(bloc);
  }
}

class SituacaoNomeState extends State<SituacaoNome> {
  final _textFieldController = TextEditingController();
  final SituacaoCRUDBloc bloc;
  SituacaoNomeState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SituacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SituacaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.nome;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateNomeEvent(text));
          },
        );
      },
    );
  }
}

class SituacaoDescricao extends StatefulWidget {
  final SituacaoCRUDBloc bloc;
  SituacaoDescricao(this.bloc);
  @override
  SituacaoDescricaoState createState() {
    return SituacaoDescricaoState(bloc);
  }
}

class SituacaoDescricaoState extends State<SituacaoDescricao> {
  final _textFieldController = TextEditingController();
  final SituacaoCRUDBloc bloc;
  SituacaoDescricaoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SituacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SituacaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.descricao;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateDescricaoEvent(text));
          },
        );
      },
    );
  }
}

class SituacaoPdf extends StatefulWidget {
  final SituacaoCRUDBloc bloc;
  SituacaoPdf(this.bloc);
  @override
  SituacaoPdfState createState() {
    return SituacaoPdfState(bloc);
  }
}

class SituacaoPdfState extends State<SituacaoPdf> {
  final _textFieldController = TextEditingController();
  final SituacaoCRUDBloc bloc;
  SituacaoPdfState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SituacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SituacaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.urlPDFSituacaoSemAlgoritmo;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateUrlPDFSituacaoSemAlgoritmoEvent(text));
          },
        );
      },
    );
  }
}
