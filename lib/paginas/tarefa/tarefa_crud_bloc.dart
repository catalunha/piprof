import 'package:flutter/material.dart';
import 'package:piprof/modelos/questao_model.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class TarefaCRUDBlocEvent {}

class GetTarefaEvent extends TarefaCRUDBlocEvent {
  final String tarefaID;

  GetTarefaEvent(this.tarefaID);
}

class UpdateDataInicioEvent extends TarefaCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataInicioEvent({this.data, this.hora});
}

class UpdateDataFimEvent extends TarefaCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataFimEvent({this.data, this.hora});
}

class UpdateNumberFieldEvent extends TarefaCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateNumberFieldEvent(this.campo, this.texto);
}

class SaveEvent extends TarefaCRUDBlocEvent {}

class DeleteDocumentEvent extends TarefaCRUDBlocEvent {}

class TarefaCRUDBlocState {
  bool isDataValid = false;
  TarefaModel tarefa = TarefaModel();
  String tempo;
  String tentativa;
  String erroRelativo;
  String avaliacaoNota;
  String questaoNota;
  DateTime inicioAvaliacao;
  DateTime fimAvaliacao;
  DateTime dataInicio;
  TimeOfDay horaInicio;
  DateTime dataFim;
  TimeOfDay horaFim;
  void updateState() {
    inicioAvaliacao = tarefa.inicio;
    fimAvaliacao = tarefa.fim;
    tempo = tarefa.tempo.toString();
    tentativa = tarefa.tentativa.toString();
    erroRelativo = tarefa.erroRelativo.toString();
    avaliacaoNota = tarefa.avaliacaoNota.toString();
    questaoNota = tarefa.questaoNota.toString();
  }
}

class TarefaCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<TarefaCRUDBlocEvent>();
  Stream<TarefaCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TarefaCRUDBlocState _state = TarefaCRUDBlocState();
  final _stateController = BehaviorSubject<TarefaCRUDBlocState>();
  Stream<TarefaCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TarefaCRUDBloc(
    this._firestore,
  ) {
    eventStream.listen(_mapEventToState);
  }

  void dispose() async {
    await _stateController.drain();
    _stateController.close();
    await _eventController.drain();
    _eventController.close();
  }

  _validateData() {
    _state.isDataValid = true;
    if (_state.inicioAvaliacao == null) {
      _state.isDataValid = false;
    }
    if (_state.fimAvaliacao == null) {
      _state.isDataValid = false;
    }
    if (_state.tempo == null || _state.tempo.isEmpty) {
      _state.isDataValid = false;
    }
    if (_state.tentativa == null || _state.tentativa.isEmpty) {
      _state.isDataValid = false;
    }
    if (_state.erroRelativo == null || _state.erroRelativo.isEmpty) {
      _state.isDataValid = false;
    }
    if (_state.avaliacaoNota == null || _state.avaliacaoNota.isEmpty) {
      _state.isDataValid = false;
    }
    if (_state.questaoNota == null || _state.questaoNota.isEmpty) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(TarefaCRUDBlocEvent event) async {
    if (event is GetTarefaEvent) {
      if (event.tarefaID != null) {
        final docRef = _firestore
            .collection(TarefaModel.collection)
            .document(event.tarefaID);
        final snap = await docRef.get();
        if (snap.exists) {
          _state.tarefa = TarefaModel(id: snap.documentID).fromMap(snap.data);
          _state.updateState();
        }
      }
    }

    if (event is UpdateDataInicioEvent) {
      if (event.data != null) {
        _state.dataInicio = event.data;
      }
      if (event.hora != null) {
        _state.horaInicio = event.hora;
      }
      if (_state.inicioAvaliacao == null && event.data != null) {
        _state.horaInicio = TimeOfDay.now();
      }
      if (_state.inicioAvaliacao == null && event.hora != null) {
        _state.dataInicio = DateTime.now();
      }
      final newDate = DateTime(
          _state.dataInicio != null
              ? _state.dataInicio.year
              : _state.inicioAvaliacao.year,
          _state.dataInicio != null
              ? _state.dataInicio.month
              : _state.inicioAvaliacao.month,
          _state.dataInicio != null
              ? _state.dataInicio.day
              : _state.inicioAvaliacao.day,
          _state.horaInicio != null
              ? _state.horaInicio.hour
              : _state.inicioAvaliacao.hour,
          _state.horaInicio != null
              ? _state.horaInicio.minute
              : _state.inicioAvaliacao.minute);
      _state.inicioAvaliacao = newDate;
    }

    if (event is UpdateDataFimEvent) {
      if (event.data != null) {
        _state.dataFim = event.data;
      }
      if (event.hora != null) {
        _state.horaFim = event.hora;
      }
      if (_state.fimAvaliacao == null && event.data != null) {
        _state.horaFim = TimeOfDay.now();
      }
      if (_state.fimAvaliacao == null && event.hora != null) {
        _state.dataFim = DateTime.now();
      }
      final newDate = DateTime(
          _state.dataFim != null
              ? _state.dataFim.year
              : _state.fimAvaliacao.year,
          _state.dataFim != null
              ? _state.dataFim.month
              : _state.fimAvaliacao.month,
          _state.dataFim != null ? _state.dataFim.day : _state.fimAvaliacao.day,
          _state.horaFim != null
              ? _state.horaFim.hour
              : _state.fimAvaliacao.hour,
          _state.horaFim != null
              ? _state.horaFim.minute
              : _state.fimAvaliacao.minute);
      _state.fimAvaliacao = newDate;
    }

    if (event is UpdateNumberFieldEvent) {
      if (event.campo == 'tempo') {
        _state.tempo = event.texto;
        int a;
        try {
          a = int.parse(_state.tempo);
        } catch (e) {
          _state.tempo = '2';
          a = 2;
        }
        if (a <= 0) {
          _state.tempo = '2';
        }
      } else if (event.campo == 'tentativa') {
        _state.tentativa = event.texto;
        int a;
        try {
          a = int.parse(_state.tentativa);
        } catch (e) {
          _state.tentativa = '3';
          a = 3;
        }
        if (a <= 0) {
          _state.tentativa = '3';
        }
      } else if (event.campo == 'erroRelativo') {
        _state.erroRelativo = event.texto;
        int a;
        try {
          a = int.parse(_state.erroRelativo);
        } catch (e) {
          _state.erroRelativo = '10';
          a = 10;
        }
        if (a <= 0) {
          _state.erroRelativo = '10';
        }
      } else if (event.campo == 'avaliacaoNota') {
        _state.avaliacaoNota = event.texto;
      } else if (event.campo == 'questaoNota') {
        _state.questaoNota = event.texto;
      }
    }

    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(TarefaModel.collection)
          .document(_state.tarefa.id);

      TarefaModel tarefaUpdate = TarefaModel(
        inicio: _state.inicioAvaliacao,
        fim: _state.fimAvaliacao,
        tempo: int.parse(_state.tempo),
        tentativa: int.parse(_state.tentativa),
        erroRelativo: int.parse(_state.erroRelativo),
        avaliacaoNota: _state.avaliacaoNota,
        questaoNota: _state.questaoNota,
        modificado: DateTime.now(),
      );

      await docRef.setData(tarefaUpdate.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(QuestaoModel.collection)
          .document(_state.tarefa.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TarefaCRUDBloc  = ${event.runtimeType}');
  }
}
