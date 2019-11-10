import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/simulacao/simulacao_variavel_crud_bloc.dart';

class VariavelCRUDPage extends StatefulWidget {
  final String simulacaoID;
  final String variavelKey;

  const VariavelCRUDPage({this.simulacaoID, this.variavelKey});

  @override
  _VariavelCRUDPageState createState() => _VariavelCRUDPageState();
}

class _VariavelCRUDPageState extends State<VariavelCRUDPage> {
  SimulacaoVariavelCRUDBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = SimulacaoVariavelCRUDBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(GetSimulacaoEvent(
      simulacaoID: widget.simulacaoID,
      variavelKey: widget.variavelKey,
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
        title: Text('Criar ou Editar variável'),
      ),
      floatingActionButton: StreamBuilder<SimulacaoVariavelCRUDBlocState>(
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
      body: StreamBuilder<SimulacaoVariavelCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<SimulacaoVariavelCRUDBlocState> snapshot) {
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
              Padding(padding: EdgeInsets.all(5.0), child: VariavelNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Valor:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0), child: VariavelValor(bloc)),
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

class VariavelNome extends StatefulWidget {
  final SimulacaoVariavelCRUDBloc bloc;
  VariavelNome(this.bloc);
  @override
  VariavelNomeState createState() {
    return VariavelNomeState(bloc);
  }
}

class VariavelNomeState extends State<VariavelNome> {
  final _textFieldController = TextEditingController();
  final SimulacaoVariavelCRUDBloc bloc;
  VariavelNomeState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoVariavelCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoVariavelCRUDBlocState> snapshot) {
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

class VariavelValor extends StatefulWidget {
  final SimulacaoVariavelCRUDBloc bloc;
  VariavelValor(this.bloc);
  @override
  VariavelValorState createState() {
    return VariavelValorState(bloc);
  }
}

class VariavelValorState extends State<VariavelValor> {
  final _textFieldController = TextEditingController();
  final SimulacaoVariavelCRUDBloc bloc;
  VariavelValorState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoVariavelCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoVariavelCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.valor;
        }
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(UpdateValorEvent(text));
          },
        );
      },
    );
  }
}

class PainelTipo extends StatefulWidget {
  final SimulacaoVariavelCRUDBloc bloc;
  PainelTipo(this.bloc);
  @override
  PainelTipoState createState() {
    return PainelTipoState(bloc);
  }
}

class PainelTipoState extends State<PainelTipo> {
  final SimulacaoVariavelCRUDBloc bloc;
  PainelTipoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SimulacaoVariavelCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<SimulacaoVariavelCRUDBlocState> snapshot) {
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
              // Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Radio(
              //         value: 'arquivo',
              //         groupValue: snapshot.data?.tipo,
              //         onChanged: (radioValue) {
              //           bloc.eventSink(UpdateTipoEvent(radioValue));
              //         },
              //       ),
              //       IconButton(
              //         tooltip: 'Um link a um arquivo',
              //         icon: Icon(Icons.description),
              //         onPressed: () {},
              //       ),
              //     ]),
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
