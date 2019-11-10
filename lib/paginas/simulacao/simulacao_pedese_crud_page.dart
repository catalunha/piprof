import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/simulacao/simulacao_pedese_crud_bloc.dart';

class PedeseCRUDPage extends StatefulWidget {
  final String simulacaoID;
  final String pedeseKey;

  const PedeseCRUDPage({this.simulacaoID, this.pedeseKey});

  @override
  PpedeseCRUDPageState createState() => PpedeseCRUDPageState();
}

class PpedeseCRUDPageState extends State<PedeseCRUDPage> {
  SimulacaoPedeseCRUDBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoPedeseCRUDBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetSimulacaoEvent(
      simulacaoID: widget.simulacaoID,
      pedeseKey: widget.pedeseKey,
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
        title: Text('Criar ou Editar Pede-se'),
      ),
      floatingActionButton: StreamBuilder<SimulacaoPedeseCRUDBlocState>(
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
      body: StreamBuilder<SimulacaoPedeseCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoPedeseCRUDBlocState> snapshot) {
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
                    'Tipo:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: PainelTipo(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: PedeseNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Gabarito:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0), child: PedeseGabarito(bloc)),
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

class PedeseNome extends StatefulWidget {
  final SimulacaoPedeseCRUDBloc bloc;
  PedeseNome(this.bloc);
  @override
  PedeseNomeState createState() {
    return PedeseNomeState(bloc);
  }
}

class PedeseNomeState extends State<PedeseNome> {
  final _textFieldController = TextEditingController();
  final SimulacaoPedeseCRUDBloc bloc;
  PedeseNomeState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoPedeseCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoPedeseCRUDBlocState> snapshot) {
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

class PedeseGabarito extends StatefulWidget {
  final SimulacaoPedeseCRUDBloc bloc;
  PedeseGabarito(this.bloc);
  @override
  PedeseGabaritoState createState() {
    return PedeseGabaritoState(bloc);
  }
}

class PedeseGabaritoState extends State<PedeseGabarito> {
  final _textFieldController = TextEditingController();
  final SimulacaoPedeseCRUDBloc bloc;
  PedeseGabaritoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoPedeseCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoPedeseCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.gabarito;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateGabaritoEvent(text));
          },
        );
      },
    );
  }
}

class PainelTipo extends StatefulWidget {
  final SimulacaoPedeseCRUDBloc bloc;
  PainelTipo(this.bloc);
  @override
  PainelTipoState createState() {
    return PainelTipoState(bloc);
  }
}

class PainelTipoState extends State<PainelTipo> {
  final SimulacaoPedeseCRUDBloc bloc;
  PainelTipoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoPedeseCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoPedeseCRUDBlocState> snapshot) {
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
                      tooltip: 'Um link ao um site',
                      icon: Icon(Icons.link),
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
                      tooltip: 'Um link a um arquivo',
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
                      tooltip: 'Um link a uma imagem',
                      icon: Icon(Icons.image),
                      onPressed: () {},
                    ),
                  ]),
            ]);
      },
    );
  }
}
