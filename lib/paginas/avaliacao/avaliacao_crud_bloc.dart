import 'package:flutter/material.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class AvaliacaoCRUDBlocEvent {}

class GetUsuarioAuthEvent extends AvaliacaoCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetAvalicaoEvent extends AvaliacaoCRUDBlocEvent {
  final String avaliacaoID;

  GetAvalicaoEvent(this.avaliacaoID);
}

class GetTurmaEvent extends AvaliacaoCRUDBlocEvent {
  final String turmaID;

  GetTurmaEvent(this.turmaID);
}

class UpdateDataInicioEvent extends AvaliacaoCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataInicioEvent({this.data, this.hora});
}

class UpdateDataFimEvent extends AvaliacaoCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataFimEvent({this.data, this.hora});
}

class UpdateNomeEvent extends AvaliacaoCRUDBlocEvent {
  final String nome;
  UpdateNomeEvent(this.nome);
}

class UpdateDescricaoEvent extends AvaliacaoCRUDBlocEvent {
  final String descricao;
  UpdateDescricaoEvent(this.descricao);
}

class UpdateNotaEvent extends AvaliacaoCRUDBlocEvent {
  final String nota;
  UpdateNotaEvent(this.nota);
}

class SaveEvent extends AvaliacaoCRUDBlocEvent {}

class DeleteDocumentEvent extends AvaliacaoCRUDBlocEvent {}

class AvaliacaoCRUDBlocState {
  bool isDataValid = false;
  String avaliacaoID;
  AvaliacaoModel avaliacao = AvaliacaoModel();
  TurmaModel turma = TurmaModel();
  UsuarioModel usuarioAuth;

  // dynamic data;
  String nome;
  String descricao;
  String nota;
  DateTime inicioEncontro;
  DateTime fimEncontro;
  DateTime dataInicio;
  TimeOfDay horaInicio;
  DateTime dataFim;
  TimeOfDay horaFim;
  void updateState() {
    inicioEncontro = avaliacao.inicio;
    fimEncontro = avaliacao.fim;
    nome = avaliacao.nome;
    descricao = avaliacao.descricao;
    nota = avaliacao.nota;
  }
}

class AvaliacaoCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<AvaliacaoCRUDBlocEvent>();
  Stream<AvaliacaoCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final AvaliacaoCRUDBlocState _state = AvaliacaoCRUDBlocState();
  final _stateController = BehaviorSubject<AvaliacaoCRUDBlocState>();
  Stream<AvaliacaoCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  AvaliacaoCRUDBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
    });
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
    }
    if (_state.fimEncontro == null) {
      _state.isDataValid = false;
    }
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
    if (_state.nota == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(AvaliacaoCRUDBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetTurmaEvent) {
      final docRef =
          _firestore.collection(TurmaModel.collection).document(event.turmaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.turma = TurmaModel(id: snap.documentID).fromMap(snap.data);
      }
    }
    if (event is GetAvalicaoEvent) {
      final docRef = _firestore
          .collection(AvaliacaoModel.collection)
          .document(event.avaliacaoID);
      _state.avaliacaoID = event.avaliacaoID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.avaliacao =
            AvaliacaoModel(id: snap.documentID).fromMap(snap.data);
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
          _state.dataInicio != null
              ? _state.dataInicio.year
              : _state.inicioEncontro.year,
          _state.dataInicio != null
              ? _state.dataInicio.month
              : _state.inicioEncontro.month,
          _state.dataInicio != null
              ? _state.dataInicio.day
              : _state.inicioEncontro.day,
          _state.horaInicio != null
              ? _state.horaInicio.hour
              : _state.inicioEncontro.hour,
          _state.horaInicio != null
              ? _state.horaInicio.minute
              : _state.inicioEncontro.minute);
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
          _state.dataFim != null
              ? _state.dataFim.year
              : _state.fimEncontro.year,
          _state.dataFim != null
              ? _state.dataFim.month
              : _state.fimEncontro.month,
          _state.dataFim != null ? _state.dataFim.day : _state.fimEncontro.day,
          _state.horaFim != null
              ? _state.horaFim.hour
              : _state.fimEncontro.hour,
          _state.horaFim != null
              ? _state.horaFim.minute
              : _state.fimEncontro.minute);
      _state.fimEncontro = newDate;
    }

    if (event is UpdateNomeEvent) {
      _state.nome = event.nome;
    }
    if (event is UpdateDescricaoEvent) {
      _state.descricao = event.descricao;
    }
    if (event is UpdateNotaEvent) {
      _state.nota = event.nota;
    }
    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(AvaliacaoModel.collection)
          .document(_state.avaliacaoID);

      AvaliacaoModel avaliacaoUpdate = AvaliacaoModel(
        inicio: _state.inicioEncontro,
        fim: _state.fimEncontro,
        nome: _state.nome,
        descricao: _state.descricao,
        nota: _state.nota,
        modificado: DateTime.now(),
      );
      if (_state.avaliacaoID == null) {
        avaliacaoUpdate.ativo = true;
        avaliacaoUpdate.aplicar = false;
        avaliacaoUpdate.aplicada = false;
        avaliacaoUpdate.professor = UsuarioFk(
          id: _state.usuarioAuth.id,
          nome: _state.usuarioAuth.nome,
        );
        avaliacaoUpdate.turma =
            TurmaFk(id: _state.turma.id, nome: _state.turma.nome);
      }
      await docRef.setData(avaliacaoUpdate.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(AvaliacaoModel.collection)
          .document(_state.avaliacao.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em AvaliacaoCRUDBloc  = ${event.runtimeType}');
  }
}
