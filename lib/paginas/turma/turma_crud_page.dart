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
              backgroundColor: snapshot.data.isDataValid ? Colors.blue : Colors.grey,
            );
          }),
      body: StreamBuilder<TurmaCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
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
              Padding(padding: EdgeInsets.all(5.0), child: TurmaInstituicao(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Componente:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: TurmaComponente(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: TurmaNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: TurmaDescricao(bloc)),
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

class TurmaInstituicao extends StatefulWidget {
  final TurmaCRUDBloc bloc;
  TurmaInstituicao(this.bloc);
  @override
  TurmaInstituicaoState createState() {
    return TurmaInstituicaoState(bloc);
  }
}

class TurmaInstituicaoState extends State<TurmaInstituicao> {
  final _textFieldController = TextEditingController();
  final TurmaCRUDBloc bloc;
  TurmaInstituicaoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurmaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.instituicao;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateInstituicaoEvent(text));
          },
        );
      },
    );
  }
}

class TurmaComponente extends StatefulWidget {
  final TurmaCRUDBloc bloc;
  TurmaComponente(this.bloc);
  @override
  TurmaComponenteState createState() {
    return TurmaComponenteState(bloc);
  }
}

class TurmaComponenteState extends State<TurmaComponente> {
  final _textFieldController = TextEditingController();
  final TurmaCRUDBloc bloc;
  TurmaComponenteState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurmaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.componente;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateComponenteEvent(text));
          },
        );
      },
    );
  }
}

class TurmaNome extends StatefulWidget {
  final TurmaCRUDBloc bloc;
  TurmaNome(this.bloc);
  @override
  TurmaNomeState createState() {
    return TurmaNomeState(bloc);
  }
}

class TurmaNomeState extends State<TurmaNome> {
  final _textFieldController = TextEditingController();
  final TurmaCRUDBloc bloc;
  TurmaNomeState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurmaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
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

class TurmaDescricao extends StatefulWidget {
  final TurmaCRUDBloc bloc;
  TurmaDescricao(this.bloc);
  @override
  TurmaDescricaoState createState() {
    return TurmaDescricaoState(bloc);
  }
}

class TurmaDescricaoState extends State<TurmaDescricao> {
  final _textFieldController = TextEditingController();
  final TurmaCRUDBloc bloc;
  TurmaDescricaoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurmaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TurmaCRUDBlocState> snapshot) {
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
