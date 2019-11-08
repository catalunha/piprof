import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/paginas/tarefa/tarefa_crud_bloc.dart';

class TarefaCRUDPage extends StatefulWidget {
  final String tarefaID;

  const TarefaCRUDPage(
    this.tarefaID,
  );

  @override
  _TarefaCRUDPageState createState() => _TarefaCRUDPageState();
}

class _TarefaCRUDPageState extends State<TarefaCRUDPage> {
  TarefaCRUDBloc bloc;
  DateTime _date = new DateTime.now();
  TimeOfDay _hora = new TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    bloc = TarefaCRUDBloc(
      Bootstrap.instance.firestore,
    );
    bloc.eventSink(
      GetTarefaEvent(widget.tarefaID),
    );
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
      bloc.eventSink(
        UpdateDataInicioEvent(data: selectedDate),
      );
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
        bloc.eventSink(
          UpdateDataInicioEvent(hora: selectedTime),
        );
        _hora = selectedTime;
      });
    }
  }

  _inicioAvaliacao(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder<TarefaCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data.inicioAvaliacao != null) {
                return Text('${snapshot.data.inicioAvaliacao}');
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
      bloc.eventSink(
        UpdateDataFimEvent(data: selectedDate),
      );
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
        bloc.eventSink(
          UpdateDataFimEvent(hora: selectedTime),
        );
        _hora = selectedTime;
      });
    }
  }

  _fimAvaliacao(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder<TarefaCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data.fimAvaliacao != null) {
                return Text('${snapshot.data.fimAvaliacao}');
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
        title: Text('Editar Tarefa'),
      ),
      floatingActionButton: StreamBuilder<TarefaCRUDBlocState>(
          stream: bloc.stateStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return FloatingActionButton(
              onPressed: snapshot.data.isDataValid
                  ? () {
                      bloc.eventSink(
                        SaveEvent(),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: Icon(Icons.cloud_upload),
              backgroundColor: snapshot.data.isDataValid ? Colors.blue : Colors.grey,
            );
          }),
      body: StreamBuilder<TarefaCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            padding: EdgeInsets.all(5),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Se necessário, altere valores copiados da avaliação e questão.',
                  style: TextStyle(fontSize: 15, color: Colors.greenAccent),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Data e hora do início:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: _inicioAvaliacao(context),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Data e hora do fim:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: _fimAvaliacao(context),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Quanto tempo para resolução em horas:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: AvaliacaoTempo(bloc),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Quantas tentativas/erros ele pode usar/ter:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: AvalicaoTentativa(bloc),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Qual o erro relativo na correção:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: ErroRelativo(bloc),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Qual a nota desta avaliação:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: AvaliacaoNota(bloc),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Qual a nota desta questão:',
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: QuestaoNota(bloc),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: DeleteDocument(
                  onDelete: () {
                    bloc.eventSink(
                      DeleteDocumentEvent(),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 100),
              ),
            ],
            // ),
          );
        },
      ),
    );
  }
}

class AvaliacaoTempo extends StatefulWidget {
  final TarefaCRUDBloc bloc;
  AvaliacaoTempo(this.bloc);
  @override
  AvaliacaoTempoState createState() {
    return AvaliacaoTempoState(bloc);
  }
}

class AvaliacaoTempoState extends State<AvaliacaoTempo> {
  final _textFieldController = TextEditingController();
  final TarefaCRUDBloc bloc;
  AvaliacaoTempoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TarefaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.tempo;
        }
        return TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(
              UpdateTempoEvent(text),
            );
          },
        );
      },
    );
  }
}

class AvalicaoTentativa extends StatefulWidget {
  final TarefaCRUDBloc bloc;
  AvalicaoTentativa(this.bloc);
  @override
  AvalicaoTentativaState createState() {
    return AvalicaoTentativaState(bloc);
  }
}

class AvalicaoTentativaState extends State<AvalicaoTentativa> {
  final _textFieldController = TextEditingController();
  final TarefaCRUDBloc bloc;
  AvalicaoTentativaState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TarefaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.tentativa;
        }
        return TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(
              UpdateTentativaEvent(text),
            );
          },
        );
      },
    );
  }
}

class ErroRelativo extends StatefulWidget {
  final TarefaCRUDBloc bloc;
  ErroRelativo(this.bloc);
  @override
  ErroRelativoState createState() {
    return ErroRelativoState(bloc);
  }
}

class ErroRelativoState extends State<ErroRelativo> {
  final _textFieldController = TextEditingController();
  final TarefaCRUDBloc bloc;
  ErroRelativoState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TarefaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.erroRelativo;
        }
        return TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(
              UpdateErroRelativoEvent(text),
            );
          },
        );
      },
    );
  }
}

class AvaliacaoNota extends StatefulWidget {
  final TarefaCRUDBloc bloc;
  AvaliacaoNota(this.bloc);
  @override
  AvaliacaoNotaState createState() {
    return AvaliacaoNotaState(bloc);
  }
}

class AvaliacaoNotaState extends State<AvaliacaoNota> {
  final _textFieldController = TextEditingController();
  final TarefaCRUDBloc bloc;
  AvaliacaoNotaState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TarefaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.avaliacaoNota;
        }
        return TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(
              UpdateAvaliacaoNotaEvent(text),
            );
          },
        );
      },
    );
  }
}

class QuestaoNota extends StatefulWidget {
  final TarefaCRUDBloc bloc;
  QuestaoNota(this.bloc);
  @override
  QuestaoNotaState createState() {
    return QuestaoNotaState(bloc);
  }
}

class QuestaoNotaState extends State<QuestaoNota> {
  final _textFieldController = TextEditingController();
  final TarefaCRUDBloc bloc;
  QuestaoNotaState(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TarefaCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context, AsyncSnapshot<TarefaCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          _textFieldController.text = snapshot.data?.questaoNota;
        }
        return TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          controller: _textFieldController,
          onChanged: (text) {
            bloc.eventSink(
              UpdateQuestaoNotaEvent(text),
            );
          },
        );
      },
    );
  }
}
