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

class UpdateDataEvent extends EncontroCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataEvent({this.data, this.hora});
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
  DateTime dataEncontro;
  DateTime data;
  TimeOfDay hora;
  void updateState() {
    dataEncontro = encontro.data;
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
    if (_state.dataEncontro == null) {
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

    if (event is UpdateDataEvent) {
      if (event.data != null) {
        _state.data = event.data;
      }
      if (event.hora != null) {
        _state.hora = event.hora;
      }
      if (_state.dataEncontro == null && event.data != null) {
        _state.hora = TimeOfDay.now();
      }
      if (_state.dataEncontro == null && event.hora != null) {
        _state.data = DateTime.now();
      }
      final newDate = DateTime(
          _state.data != null ? _state.data.year : _state.dataEncontro.year,
          _state.data != null ? _state.data.month : _state.dataEncontro.month,
          _state.data != null ? _state.data.day : _state.dataEncontro.day,
          _state.hora != null ? _state.hora.hour : _state.dataEncontro.hour,
          _state.hora != null ? _state.hora.minute : _state.dataEncontro.minute);
      _state.dataEncontro = newDate;
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
        data: _state.dataEncontro,
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
