import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/simulacao/simulacao_gabarito_crud_bloc.dart';

class GabaritoCRUDPage extends StatefulWidget {
  final String simulacaoID;
  final String gabaritoKey;

  const GabaritoCRUDPage({this.simulacaoID, this.gabaritoKey});

  @override
  PgabaritoCRUDPageState createState() => PgabaritoCRUDPageState();
}

class PgabaritoCRUDPageState extends State<GabaritoCRUDPage> {
  SimulacaoGabaritoCRUDBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoGabaritoCRUDBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetSimulacaoEvent(
      simulacaoID: widget.simulacaoID,
      gabaritoKey: widget.gabaritoKey,
    ));
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
        title: Text('Editar gabarito'),
      ),
      floatingActionButton: StreamBuilder<SimulacaoGabaritoCRUDBlocState>(
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
      body: StreamBuilder<SimulacaoGabaritoCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (context, snapshot) {
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
                    '* Letra ou Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'nome')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Tipo:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: PainelTipo(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Valor do gabarito:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'gabarito')),
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
  final SimulacaoGabaritoCRUDBloc bloc;
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
  final SimulacaoGabaritoCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoGabaritoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoGabaritoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'nome') {
            _textFieldController.text = snapshot.data?.nome;
          } else if (campo == 'gabarito') {
            _textFieldController.text = snapshot.data?.valor;
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

class PainelTipo extends StatefulWidget {
  final SimulacaoGabaritoCRUDBloc bloc;
  PainelTipo(this.bloc);
  @override
  PainelTipoState createState() {
    return PainelTipoState(bloc);
  }
}

class PainelTipoState extends State<PainelTipo> {
  final SimulacaoGabaritoCRUDBloc bloc;
  PainelTipoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoGabaritoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoGabaritoCRUDBlocState> snapshot) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'numero',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'Um número inteiro ou decimal',
                      icon: Icon(Icons.looks_one),
                      onPressed: () {},
                    ),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'palavra',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'Um palavra ou frase curta',
                      icon: Icon(Icons.text_format),
                      onPressed: () {},
                    ),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'texto',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'Um texto com várias linhas',
                      icon: Icon(Icons.text_fields),
                      onPressed: () {},
                    ),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'url',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'Um link ao um site ou arquivo',
                      icon: Icon(Icons.link),
                      onPressed: () {},
                    ),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'urlimagem',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'Um link a uma imagem',
                      icon: Icon(Icons.image),
                      onPressed: () {},
                    ),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'arquivo',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'O upload de um arquivo',
                      icon: Icon(Icons.description),
                      onPressed: () {},
                    ),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 'imagem',
                      groupValue: snapshot.data?.tipo,
                      onChanged: (radioValue) {
                        bloc.eventSink(UpdateTipoEvent(radioValue));
                      },
                    ),
                    IconButton(
                      tooltip: 'O upload de uma imagem',
                      icon: Icon(Icons.photo_camera),
                      onPressed: () {},
                    ),
                  ]),
            ]);
      },
    );
  }
}
