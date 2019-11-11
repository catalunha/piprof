import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/pasta/pasta_crud_bloc.dart';

class PastaCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String pastaID;

  const PastaCRUDPage({this.authBloc, this.pastaID});

  @override
  _PastaCRUDPageState createState() => _PastaCRUDPageState();
}

class _PastaCRUDPageState extends State<PastaCRUDPage> {
  PastaCRUDBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = PastaCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(GetPastaEvent(widget.pastaID));
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
        title: Text('Criar ou Editar pasta'),
      ),
      floatingActionButton: StreamBuilder<PastaCRUDBlocState>(
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
      body: StreamBuilder<PastaCRUDBlocState>(
        stream: bloc.stateStream,
        builder:
            (BuildContext context, AsyncSnapshot<PastaCRUDBlocState> snapshot) {
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
                    'Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              // Padding(padding: EdgeInsets.all(5.0), child: PastaNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'nome')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'descricao')),

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
  final PastaCRUDBloc bloc;
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
  final PastaCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PastaCRUDBlocState>(
      stream: bloc.stateStream,
      builder:
          (BuildContext context, AsyncSnapshot<PastaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'nome') {
            _textFieldController.text = snapshot.data?.nome;
          } else if (campo == 'descricao') {
            _textFieldController.text = snapshot.data?.descricao;
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
