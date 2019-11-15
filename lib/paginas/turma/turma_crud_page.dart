import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/turma/turma_crud_bloc.dart';

class TurmaCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String turmaID;

  const TurmaCRUDPage(this.authBloc, this.turmaID);

  @override
  _TurmaCRUDPageState createState() => _TurmaCRUDPageState();
}

class _TurmaCRUDPageState extends State<TurmaCRUDPage> {
  TurmaCRUDBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = TurmaCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(GetTurmaEvent(widget.turmaID));
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
        title: Text('Editar turma'),
      ),
      floatingActionButton: StreamBuilder<TurmaCRUDBlocState>(
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
      body: StreamBuilder<TurmaCRUDBlocState>(
        stream: bloc.stateStream,
        builder:
            (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          // if (snapshot.data.isDataValid) {
          return ListView(
            children: <Widget>[
              SwitchListTile(
                title: Text(
                  'Turma ativa ? ',
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
                    'Instituição:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'instituicao')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Componente curricular ou disciplina:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'componente')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Nome:',
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
              Divider(),
              // Padding(
              //   padding: EdgeInsets.all(5.0),
              //   child: _DeleteDocumentOrField(bloc),
              // ),
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
          // } else {
          //   return Text('Existem dados inválidos. Informe o suporte.');
          // }
        },
      ),
    );
  }
}

class _TextFieldMultiplo extends StatefulWidget {
  final TurmaCRUDBloc bloc;
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
  final TurmaCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurmaCRUDBlocState>(
      stream: bloc.stateStream,
      builder:
          (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'instituicao') {
            _textFieldController.text = snapshot.data?.instituicao;
          } else if (campo == 'componente') {
            _textFieldController.text = snapshot.data?.componente;
          } else if (campo == 'nome') {
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
