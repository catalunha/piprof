import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/encontro/encontro_crud_bloc.dart';

class EncontroCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String turmaID;
  final String encontroID;

  const EncontroCRUDPage({
    this.authBloc,
    this.turmaID,
    this.encontroID,
  });

  @override
  _EncontroCRUDPageState createState() => _EncontroCRUDPageState();
}

class _EncontroCRUDPageState extends State<EncontroCRUDPage> {
  EncontroCRUDBloc bloc;
  DateTime _date = new DateTime.now();
  TimeOfDay _hora = new TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    bloc = EncontroCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(GetTurmaEvent(widget.turmaID));
    bloc.eventSink(GetEncontroEvent(widget.encontroID));
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  Future<Null> _selectDateInicio(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2022),
    );
    if (selectedDate != null) {
      bloc.eventSink(UpdateDataInicioEvent(data: selectedDate));
      setState(() {
        _date = selectedDate;
      });
    }
  }

  Future<Null> _selectHorarioInicio(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      initialTime: _hora,
      context: context,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (selectedTime != null) {
      setState(() {
        bloc.eventSink(UpdateDataInicioEvent(hora: selectedTime));
        _hora = selectedTime;
      });
    }
  }

  _inicioEncontro(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder<EncontroCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data.inicioEncontro != null) {
                return Text('${snapshot.data.inicioEncontro}');
              } else {
                return Text('?');
              }
            }),
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () {
            _selectDateInicio(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () {
            _selectHorarioInicio(context);
          },
        ),
      ],
      // ),
    );
  }

  Future<Null> _selectDateFim(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2022),
    );
    if (selectedDate != null) {
      bloc.eventSink(UpdateDataFimEvent(data: selectedDate));
      setState(() {
        _date = selectedDate;
      });
    }
  }

  Future<Null> _selectHorarioFim(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      initialTime: _hora,
      context: context,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (selectedTime != null) {
      setState(() {
        bloc.eventSink(UpdateDataFimEvent(hora: selectedTime));
        _hora = selectedTime;
      });
    }
  }

  _fimEncontro(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder<EncontroCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data.fimEncontro != null) {
                return Text('${snapshot.data.fimEncontro}');
              } else {
                return Text('?');
              }
            }),
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () {
            _selectDateFim(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () {
            _selectHorarioFim(context);
          },
        ),
      ],
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar encontro'),
      ),
      floatingActionButton: StreamBuilder<EncontroCRUDBlocState>(
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
      body: StreamBuilder<EncontroCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.all(5),
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Data e hora do início:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(1.0),
                  child: _inicioEncontro(context)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Data e hora do fim:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(1.0), child: _fimEncontro(context)),
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
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Link para arquivo:',
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
            // ),
          );
        },
      ),
    );
  }
}

class _TextFieldMultiplo extends StatefulWidget {
  final EncontroCRUDBloc bloc;
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
  final EncontroCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EncontroCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
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
