import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/encontro/encontro_crud_bloc.dart';

class EncontroCRUDPage extends StatefulWidget {
  final String turmaID;
  final String encontroID;

  const EncontroCRUDPage({this.turmaID, this.encontroID});

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
    );
    bloc.eventSink(GetTurmaEvent(widget.turmaID));
    bloc.eventSink(GetEncontroEvent(widget.encontroID));
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2019),
      lastDate: DateTime(2022),
    );
    if (selectedDate != null) {
      bloc.eventSink(UpdateDataEvent(data: selectedDate));
      setState(() {
        _date = selectedDate;
      });
    }
  }

  Future<Null> _selectHorario(BuildContext context) async {
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
        bloc.eventSink(UpdateDataEvent(hora: selectedTime));
        _hora = selectedTime;
      });
    }
  }

  _dataHorarioNoticia(context) {
    return

        Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[

        StreamBuilder<EncontroCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data.dataEncontro != null) {
                return Text('${snapshot.data.dataEncontro}');
              } else {
                return Text('?');
              }
            }),
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () {
            _selectDate(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () {
            _selectHorario(context);
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
              backgroundColor: snapshot.data.isDataValid ? Colors.blue : Colors.grey,
            );
          }),
      body: StreamBuilder<EncontroCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return

              ListView(
            padding: EdgeInsets.all(5),
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Data:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(1.0), child: _dataHorarioNoticia(context)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Nome:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: EncontroNome(bloc)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(padding: EdgeInsets.all(5.0), child: EncontroDescricao(bloc)),
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

class EncontroNome extends StatefulWidget {
  final EncontroCRUDBloc bloc;
  EncontroNome(this.bloc);
  @override
  EncontroNomeState createState() {
    return EncontroNomeState(bloc);
  }
}

class EncontroNomeState extends State<EncontroNome> {
  final _textFieldController = TextEditingController();
  final EncontroCRUDBloc bloc;
  EncontroNomeState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EncontroCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
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

class EncontroDescricao extends StatefulWidget {
  final EncontroCRUDBloc bloc;
  EncontroDescricao(this.bloc);
  @override
  EncontroDescricaoState createState() {
    return EncontroDescricaoState(bloc);
  }
}

class EncontroDescricaoState extends State<EncontroDescricao> {
  final _textFieldController = TextEditingController();
  final EncontroCRUDBloc bloc;
  EncontroDescricaoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EncontroCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<EncontroCRUDBlocState> snapshot) {
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
