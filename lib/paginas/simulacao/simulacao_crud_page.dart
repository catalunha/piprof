import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/simulacao/simulacao_crud_bloc.dart';

class SimulacaoCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String situacaoID;
  final String simulacaoID;

  const SimulacaoCRUDPage({this.authBloc, this.situacaoID, this.simulacaoID});

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
    if (widget.situacaoID != null)
      bloc.eventSink(GetSituacaoEvent(widget.situacaoID));
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
        title: Text('Criar ou Editar simulação'),
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
                    'Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: SimulacaoNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0), child: SimulacaoDescricao(bloc)),
                  Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Url:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0), child: SimulacaoUrl(bloc)),
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

class SimulacaoNome extends StatefulWidget {
  final SimulacaoCRUDBloc bloc;
  SimulacaoNome(this.bloc);
  @override
  SimulacaoNomeState createState() {
    return SimulacaoNomeState(bloc);
  }
}

class SimulacaoNomeState extends State<SimulacaoNome> {
  final _textFieldController = TextEditingController();
  final SimulacaoCRUDBloc bloc;
  SimulacaoNomeState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoCRUDBlocState> snapshot) {
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

class SimulacaoDescricao extends StatefulWidget {
  final SimulacaoCRUDBloc bloc;
  SimulacaoDescricao(this.bloc);
  @override
  SimulacaoDescricaoState createState() {
    return SimulacaoDescricaoState(bloc);
  }
}

class SimulacaoDescricaoState extends State<SimulacaoDescricao> {
  final _textFieldController = TextEditingController();
  final SimulacaoCRUDBloc bloc;
  SimulacaoDescricaoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoCRUDBlocState> snapshot) {
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

class SimulacaoUrl extends StatefulWidget {
  final SimulacaoCRUDBloc bloc;
  SimulacaoUrl(this.bloc);
  @override
  SimulacaoDescrUrl createState() {
    return SimulacaoDescrUrl(bloc);
  }
}

class SimulacaoDescrUrl extends State<SimulacaoUrl> {
  final _textFieldController = TextEditingController();
  final SimulacaoCRUDBloc bloc;
  SimulacaoDescrUrl(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.url;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateUrlEvent(text));
          },
        );
      },
    );
  }
}
