import 'package:flutter/material.dart';
import 'package:piprof/modelos/encontro_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class EncontroCRUDBlocEvent {}

class GetEncontroEvent extends EncontroCRUDBlocEvent {
  final String encontroID;

  GetEncontroEvent(this.encontroID);
}

class GetTurmaEvent extends EncontroCRUDBlocEvent {
  final String turmaID;

  GetTurmaEvent(this.turmaID);
}

class UpdateDataInicioEvent extends EncontroCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataInicioEvent({this.data, this.hora});
}
class UpdateDataFimEvent extends EncontroCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataFimEvent({this.data, this.hora});
}
class UpdateNomeEvent extends EncontroCRUDBlocEvent {
  final String nome;
  UpdateNomeEvent(this.nome);
}

class UpdateDescricaoEvent extends EncontroCRUDBlocEvent {
  final String descricao;
  UpdateDescricaoEvent(this.descricao);
}

class SaveEvent extends EncontroCRUDBlocEvent {}

class DeleteDocumentEvent extends EncontroCRUDBlocEvent {}

class EncontroCRUDBlocState {
  bool isDataValid = false;
  String encontroID;
  EncontroModel encontro = EncontroModel();
  TurmaModel turma = TurmaModel();

  // dynamic data;
  String nome;
  String descricao;
  DateTime inicioEncontro;
  DateTime fimEncontro;
  DateTime dataInicio;
  TimeOfDay horaInicio;
    DateTime dataFim;
  TimeOfDay horaFim;
  void updateState() {
    inicioEncontro = encontro.inicio;
    fimEncontro = encontro.fim;
    nome = encontro.nome;
    descricao = encontro.descricao;
  }
}

class EncontroCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<EncontroCRUDBlocEvent>();
  Stream<EncontroCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final EncontroCRUDBlocState _state = EncontroCRUDBlocState();
  final _stateController = BehaviorSubject<EncontroCRUDBlocState>();
  Stream<EncontroCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  EncontroCRUDBloc(this._firestore) {
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
    if (_state.inicioEncontro == null) {
      _state.isDataValid = false;
    }    if (_state.fimEncontro == null) {
      _state.isDataValid = false;
    }
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
    if (_state.descricao == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(EncontroCRUDBlocEvent event) async {
    if (event is GetTurmaEvent) {
      final docRef = _firestore.collection(TurmaModel.collection).document(event.turmaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.turma = TurmaModel(id: snap.documentID).fromMap(snap.data);
      }
    }
    if (event is GetEncontroEvent) {
      final docRef = _firestore.collection(EncontroModel.collection).document(event.encontroID);
      _state.encontroID = event.encontroID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.encontro = EncontroModel(id: snap.documentID).fromMap(snap.data);
        _state.updateState();
      }
    }

    if (event is UpdateDataInicioEvent) {
      if (event.data != null) {
        _state.dataInicio = event.data;
      }
      if (event.hora != null) {
        _state.horaInicio = event.hora;
      }
      if (_state.inicioEncontro == null && event.data != null) {
        _state.horaInicio = TimeOfDay.now();
      }
      if (_state.inicioEncontro == null && event.hora != null) {
        _state.dataInicio = DateTime.now();
      }
      final newDate = DateTime(
          _state.dataInicio != null ? _state.dataInicio.year : _state.inicioEncontro.year,
          _state.dataInicio != null ? _state.dataInicio.month : _state.inicioEncontro.month,
          _state.dataInicio != null ? _state.dataInicio.day : _state.inicioEncontro.day,
          _state.horaInicio != null ? _state.horaInicio.hour : _state.inicioEncontro.hour,
          _state.horaInicio != null ? _state.horaInicio.minute : _state.inicioEncontro.minute);
      _state.inicioEncontro = newDate;
    }

    if (event is UpdateDataFimEvent) {
      if (event.data != null) {
        _state.dataFim = event.data;
      }
      if (event.hora != null) {
        _state.horaFim = event.hora;
      }
      if (_state.fimEncontro == null && event.data != null) {
        _state.horaFim = TimeOfDay.now();
      }
      if (_state.fimEncontro == null && event.hora != null) {
        _state.dataFim = DateTime.now();
      }
      final newDate = DateTime(
          _state.dataFim != null ? _state.dataFim.year : _state.fimEncontro.year,
          _state.dataFim != null ? _state.dataFim.month : _state.fimEncontro.month,
          _state.dataFim != null ? _state.dataFim.day : _state.fimEncontro.day,
          _state.horaFim != null ? _state.horaFim.hour : _state.fimEncontro.hour,
          _state.horaFim != null ? _state.horaFim.minute : _state.fimEncontro.minute);
      _state.fimEncontro = newDate;
    }
    
    if (event is UpdateNomeEvent) {
      _state.nome = event.nome;
    }
    if (event is UpdateDescricaoEvent) {
      _state.descricao = event.descricao;
    }
    if (event is SaveEvent) {
      final docRef = _firestore.collection(EncontroModel.collection).document(_state.encontroID);

      EncontroModel encontroUpdate = EncontroModel(
        inicio: _state.inicioEncontro,
        fim: _state.fimEncontro,
        nome: _state.nome,
        descricao: _state.descricao,
        modificado: DateTime.now(),
      );
      if (_state.encontroID == null) {
        encontroUpdate.turma = TurmaFk(id: _state.turma.id, nome: _state.turma.nome);
      }
      await docRef.setData(encontroUpdate.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore.collection(TurmaModel.collection).document(_state.encontro.id).delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em EncontroCRUDBloc  = ${event.runtimeType}');
  }
}
