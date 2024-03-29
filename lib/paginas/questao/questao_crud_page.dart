import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/delete_documento.dart';
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/paginas/questao/questao_crud_bloc.dart';
import 'package:piprof/paginas/problema/problema_selecionar_page.dart';

class QuestaoCRUDPage extends StatefulWidget {
  final AuthBloc authBloc;
  final String avaliacaoID;
  final String questaoID;

  const QuestaoCRUDPage({
    this.authBloc,
    this.avaliacaoID,
    this.questaoID,
  });

  @override
  _QuestaoCRUDPageState createState() => _QuestaoCRUDPageState();
}

class _QuestaoCRUDPageState extends State<QuestaoCRUDPage> {
  QuestaoCRUDBloc bloc;
  DateTime _date = new DateTime.now();
  TimeOfDay _hora = new TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    bloc = QuestaoCRUDBloc(
      Bootstrap.instance.firestore,
      widget.authBloc,
    );
    bloc.eventSink(GetAvaliacaoEvent(widget.avaliacaoID));
    bloc.eventSink(GetQuestaoEvent(widget.questaoID));
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

  _inicioAvaliacao(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder<QuestaoCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuestaoCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data.inicioQuestao != null) {
                return Text('${snapshot.data.inicioQuestao}');
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

  _fimAvaliacao(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StreamBuilder<QuestaoCRUDBlocState>(
            stream: bloc.stateStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuestaoCRUDBlocState> snapshot) {
              if (snapshot.hasError) {
                return Text("Existe algo errado! Informe o suporte.");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data.fimQuestao != null) {
                return Text('${snapshot.data.fimQuestao}');
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
        title: Text('Editar Questão'),
      ),
      floatingActionButton: StreamBuilder<QuestaoCRUDBlocState>(
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
      body: StreamBuilder<QuestaoCRUDBlocState>(
        stream: bloc.stateStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuestaoCRUDBlocState> snapshot) {
          if (snapshot.hasError) {
            return Text("Existe algo errado! Informe o suporte.");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Widget msgData = Text('');
          if (snapshot.data.inicioQuestao != null &&
              snapshot.data.fimQuestao != null && snapshot.data.inicioQuestao
                .isAfter(snapshot.data.fimQuestao)) {
              msgData = Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    'Data e hora final deve ser após a inicial.',
                    style: TextStyle(fontSize: 15, color: Colors.red),
                  ),
                ),
              );
            
          }
          return ListView(
            padding: EdgeInsets.all(5),
            children: <Widget>[
              if (widget.avaliacaoID != null)
                Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Se necessário, altere o início e fim copiado da avaliação:',
                      style: TextStyle(fontSize: 15, color: Colors.greenAccent),
                    )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Data e hora do início:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(1.0),
                  child: _inicioAvaliacao(context)),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Data e hora do fim:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(1.0), child: _fimAvaliacao(context)),
              msgData,
              Divider(),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Horas para resolução (>=1):',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _NumberFieldMultiplo(bloc, 'tempo')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Tentativas de resposta ele pode usar (>=1):',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _NumberFieldMultiplo(bloc, 'tentativa')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Erro relativo na correção numérica. (>=1 a <100):',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _NumberFieldMultiplo(bloc, 'erroRelativo')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Nota ou peso:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: _TextFieldMultiplo(bloc, 'nota')),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '* Selectione um problema:',
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  )),
              snapshot.data?.questao?.aplicada != null &&
                      snapshot.data?.questao?.aplicada == true
                  ? Text('Questão já aplicada não pode alterar problema.')
                  : Padding(
                      padding: EdgeInsets.all(5.0),
                      child: ListTile(
                        title: snapshot.data.problemaFk == null
                            ? Text('Aguardado seleção')
                            : Text('${snapshot.data.problemaFk.nome}'),
                        trailing: Icon(Icons.search),
                        onTap: () async {
                          ProblemaFk problemaFk = await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ProblemaSelecionarPage(widget.authBloc);
                          }));
                          if (problemaFk != null) {
                            bloc.eventSink(SelecionarProblemaEvent(problemaFk));
                          }
                        },
                      ),
                    ),
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
  final QuestaoCRUDBloc bloc;
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
  final QuestaoCRUDBloc bloc;
  final String campo;
  _TextFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuestaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuestaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'nota') {
            _textFieldController.text = snapshot.data?.nota;
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


class _NumberFieldMultiplo extends StatefulWidget {
  final QuestaoCRUDBloc bloc;
  final String campo;
  _NumberFieldMultiplo(
    this.bloc,
    this.campo,
  );
  @override
  _NumberFieldMultiploState createState() {
    return _NumberFieldMultiploState(
      bloc,
      campo,
    );
  }
}

class _NumberFieldMultiploState extends State<_NumberFieldMultiplo> {
  final _textFieldController = TextEditingController();
  final QuestaoCRUDBloc bloc;
  final String campo;
  _NumberFieldMultiploState(
    this.bloc,
    this.campo,
  );
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuestaoCRUDBlocState>(
      stream: bloc.stateStream,
      builder:
          (BuildContext context, AsyncSnapshot<QuestaoCRUDBlocState> snapshot) {
        if (_textFieldController.text.isEmpty) {
          if (campo == 'tempo') {
            _textFieldController.text = snapshot.data?.tempo;
          } else if (campo == 'tentativa') {
            _textFieldController.text = snapshot.data?.tentativa;
          } else if (campo == 'erroRelativo') {
            _textFieldController.text = snapshot.data?.erroRelativo;
          }
        }
        return TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: false),
          // maxLines: null,
          // decoration: InputDecoration(
          //     // border: OutlineInputBorder(),
          //     ),
          controller: _textFieldController,
          onChanged: (texto) {
            bloc.eventSink(UpdateNumberFieldEvent(campo, texto));
          },
        );
      },
    );
  }
}
