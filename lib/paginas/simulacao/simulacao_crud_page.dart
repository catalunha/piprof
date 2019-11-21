import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/simulacao/simulacao_crud_bloc.dart';

class SimulacaoCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String problemaID;
  final String simulacaoID;

  const SimulacaoCRUDPage({this.authBloc, this.problemaID, this.simulacaoID});

  @override
  _SimulacaoCRUDPageState createState() => _SimulacaoCRUDPageState();
}

class _SimulacaoCRUDPageState extends State<SimulacaoCRUDPage> {
  SimulacaoCRUDBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    if (widget.problemaID != null)
      bloc.eventSink(GetProblemaEvent(widget.problemaID));
    if (widget.simulacaoID != null)
      bloc.eventSink(GetSimulacaoEvent(widget.simulacaoID));
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
        title: Text('Editar simulação'),
      ),
      floatingActionButton: StreamBuilder<SimulacaoCRUDBlocState>(
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
      body: StreamBuilder<SimulacaoCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          // if (snapshot.data.isDataValid) {
          return ListView(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'nome')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Detalhes:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'descricao')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Link para o arquivo detalhando a simulação:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'url')),
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
          );
        },
      ),
    );
  }
}

class _TextFieldMultiplo extends StatefulWidget {
  final SimulacaoCRUDBloc bloc;
  final String campo;
  _TextFieldMultiplo(
    this.bloc,
    this.campo,
  );
  @override
  _TextFieldMultiploState createState() {
    return _TextFieldMultiploState(
      bloc,
      campo,
    );
  }
}

class _TextFieldMultiploState extends State<_TextFieldMultiplo> {
  final _textFieldController = TextEditingController();
  final SimulacaoCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'nome') {
            _textFieldController.text = snapshot.data?.nome;
          } else if (campo == 'descricao') {
            _textFieldController.text = snapshot.data?.descricao;
          } else if (campo == 'url') {
            _textFieldController.text = snapshot.data?.url;
          }
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (texto) {
            bloc.eventSink(UpdateTextFieldEvent(campo, texto));
          },
        );
      },
    );
  }
}
