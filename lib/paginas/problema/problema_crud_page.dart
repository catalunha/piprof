import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/paginas/problema/problema_crud_bloc.dart';

class ProblemaCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String pastaID;
  final String problemaID;

  const ProblemaCRUDPage({
    this.authBloc,
    this.pastaID,
    this.problemaID,
  });

  @override
  _ProblemaCRUDPageState createState() => _ProblemaCRUDPageState();
}

class _ProblemaCRUDPageState extends State<ProblemaCRUDPage> {
  ProblemaCRUDBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = ProblemaCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    if (widget.pastaID != null) bloc.eventSink(GetPastaEvent(widget.pastaID));
    if (widget.problemaID != null)
      bloc.eventSink(GetProblemaEvent(widget.problemaID));
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
        title: Text('Editar situação'),
      ),
      floatingActionButton: StreamBuilder<ProblemaCRUDBlocState>(
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
      body: StreamBuilder<ProblemaCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<ProblemaCRUDBlocState> snapshot) {
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
                      'Link para PDF da situação:',
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    )),
              if (snapshot.data?.precisaAlgoritmoPSimulacao != null &&
                  snapshot.data?.precisaAlgoritmoPSimulacao == false)
                Padding(
                    padding: EdgeInsets.all(5.0),
                    child:
                        _TextFieldMultiplo(bloc, 'urlPDFProblemaSemAlgoritmo')),
               Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Pasta desta situação:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
                  _pasta(context),
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

  _pasta(context) {
    return StreamBuilder<ProblemaCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('Sem produtos');
          }
          Widget texto;
          if (snapshot.data.pastaDestino == null) {
            texto = Text('Pasta não selecionado');
          } else {
            texto = Text('${snapshot.data?.pastaDestino?.nome}');
          }
          return ListTile(
            title: texto,
            leading: IconButton(
              icon: Icon(Icons.folder),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return UsuarioListaModalSelect(bloc);
                    });
              },
            ),
          );
        });
  }
}

class _TextFieldMultiplo extends StatefulWidget {
  final ProblemaCRUDBloc bloc;
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
  final ProblemaCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProblemaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<ProblemaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'nome') {
            _textFieldController.text = snapshot.data?.nome;
          } else if (campo == 'descricao') {
            _textFieldController.text = snapshot.data?.descricao;
          } else if (campo == 'urlPDFProblemaSemAlgoritmo') {
            _textFieldController.text =
                snapshot.data?.urlPDFProblemaSemAlgoritmo;
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

/// Selecao de usuario que vao receber alerta
class UsuarioListaModalSelect extends StatefulWidget {
  final ProblemaCRUDBloc bloc;

  const UsuarioListaModalSelect(this.bloc);

  @override
  _UsuarioListaModalSelectState createState() =>
      _UsuarioListaModalSelectState(this.bloc);
}

class _UsuarioListaModalSelectState extends State<UsuarioListaModalSelect> {
  final ProblemaCRUDBloc bloc;

  _UsuarioListaModalSelectState(this.bloc);

  Widget _listarPasta() {
    return StreamBuilder<ProblemaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<ProblemaCRUDBlocState> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text("Erro. Informe ao administrador do aplicativo"),
          );
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.pastaList == null) {
          return Center(
            child: Text("Nenhuma pasta encontrada"),
          );
        }
        if (snapshot.data.pastaList.isEmpty) {
          return Center(
            child: Text("Vazio."),
          );
        }

        var lista = List<Widget>();
        for (var usuario in snapshot.data.pastaList) {
          lista.add(_cardBuild(context, usuario));
        }

        return ListView(
          children: lista,
        );
      },
    );
  }

  Widget _cardBuild(BuildContext context, PastaModel pasta) {
    return ListTile(
      title: Text('${pasta.nome}'),
      leading: IconButton(
        icon: Icon(Icons.check),
        onPressed: () {
          bloc.eventSink(SelectPastaIDEvent(pasta));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escolha uma pasta"),
      ),
      body: _listarPasta(),
    );
  }
}
