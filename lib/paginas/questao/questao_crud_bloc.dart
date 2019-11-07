import 'package:flutter/material.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/questao_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class QuestaoCRUDBlocEvent {}

// class GetUsuarioAuthEvent extends QuestaoCRUDBlocEvent {
//   final UsuarioModel usuarioAuth;

//   GetUsuarioAuthEvent(this.usuarioAuth);
// }

// class GetTurmaEvent extends QuestaoCRUDBlocEvent {
//   final String turmaID;

//   GetTurmaEvent(this.turmaID);
// }

class GetAvalicaoEvent extends QuestaoCRUDBlocEvent {
  final String avaliacaoID;

  GetAvalicaoEvent(this.avaliacaoID);
}

class GetQuestaoEvent extends QuestaoCRUDBlocEvent {
  final String questaoID;

  GetQuestaoEvent(this.questaoID);
}

class UpdateDataInicioEvent extends QuestaoCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataInicioEvent({this.data, this.hora});
}

class UpdateDataFimEvent extends QuestaoCRUDBlocEvent {
  final DateTime data;
  final TimeOfDay hora;

  UpdateDataFimEvent({this.data, this.hora});
}

class UpdateTempoEvent extends QuestaoCRUDBlocEvent {
  final String tempo;
  UpdateTempoEvent(this.tempo);
}

class UpdateTentativaEvent extends QuestaoCRUDBlocEvent {
  final String tentativa;
  UpdateTentativaEvent(this.tentativa);
}

class UpdateErroRelativoEvent extends QuestaoCRUDBlocEvent {
  final String erroRelativo;
  UpdateErroRelativoEvent(this.erroRelativo);
}

class UpdateNotaEvent extends QuestaoCRUDBlocEvent {
  final String nota;
  UpdateNotaEvent(this.nota);
}

class SelecionarSituacaoEvent extends QuestaoCRUDBlocEvent {
  final SituacaoFk situacaoFk;

  SelecionarSituacaoEvent(this.situacaoFk);
}

class SaveEvent extends QuestaoCRUDBlocEvent {}

class DeleteDocumentEvent extends QuestaoCRUDBlocEvent {}

class QuestaoCRUDBlocState {
  bool isDataValid = false;
  String questaoID;
  UsuarioModel usuarioAuth;
  TurmaModel turma = TurmaModel();
  AvaliacaoModel avaliacao = AvaliacaoModel();
  QuestaoModel questao = QuestaoModel();
  SituacaoFk situacaoFk;
  // SituacaoModel situacao;
  // dynamic data;
  String tempo = '2';
  String tentativa = '3';
  String erroRelativo = '10';
  String nota = '1';
  DateTime inicioAvaliacao;
  DateTime fimAvaliacao;
  DateTime dataInicio;
  TimeOfDay horaInicio;
  DateTime dataFim;
  TimeOfDay horaFim;
  void updateState() {
    inicioAvaliacao = questao.inicio;
    fimAvaliacao = questao.fim;
    tempo = questao.tempo.toString();
    tentativa = questao.tentativa.toString();
    nota = questao.nota;
    situacaoFk = questao.situacao;
  }
}

class QuestaoCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<QuestaoCRUDBlocEvent>();
  Stream<QuestaoCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final QuestaoCRUDBlocState _state = QuestaoCRUDBlocState();
  final _stateController = BehaviorSubject<QuestaoCRUDBlocState>();
  Stream<QuestaoCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  QuestaoCRUDBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    // _authBloc.perfil.listen((usuarioAuth) {
    //   eventSink(GetUsuarioAuthEvent(usuarioAuth));
    //   if (!_stateController.isClosed) _stateController.add(_state);
    // });
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
    if (_state.tempo == null) {
      _state.isDataValid = false;
    }
    if (_state.tentativa == null) {
      _state.isDataValid = false;
    }
    if (_state.erroRelativo == null) {
      _state.isDataValid = false;
    }
    if (_state.nota == null) {
      _state.isDataValid = false;
    }
    if (_state.situacaoFk == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(QuestaoCRUDBlocEvent event) async {
    // if (event is GetUsuarioAuthEvent) {
    //   _state.usuarioAuth = event.usuarioAuth;
    // }

    // if (event is GetTurmaEvent) {
    //   final docRef =
    //       _firestore.collection(TurmaModel.collection).document(event.turmaID);
    //   final snap = await docRef.get();
    //   if (snap.exists) {
    //     _state.turma = TurmaModel(id: snap.documentID).fromMap(snap.data);
    //   }
    // }
    if (event is GetAvalicaoEvent) {
      if (event.avaliacaoID != null) {
        final docRef = _firestore
            .collection(AvaliacaoModel.collection)
            .document(event.avaliacaoID);
        final snap = await docRef.get();
        if (snap.exists) {
          _state.avaliacao =
              AvaliacaoModel(id: snap.documentID).fromMap(snap.data);
        }
      }
    }
    if (event is GetQuestaoEvent) {
      if (event.questaoID != null) {
        final docRef = _firestore
            .collection(QuestaoModel.collection)
            .document(event.questaoID);
        _state.questaoID = event.questaoID;
        final snap = await docRef.get();
        if (snap.exists) {
          _state.questao = QuestaoModel(id: snap.documentID).fromMap(snap.data);
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

    if (event is UpdateTempoEvent) {
      _state.tempo = event.tempo;
    }
    if (event is UpdateTentativaEvent) {
      _state.tentativa = event.tentativa;
    }
    if (event is UpdateErroRelativoEvent) {
      _state.erroRelativo = event.erroRelativo;
    }
    if (event is UpdateNotaEvent) {
      _state.nota = event.nota;
    }

    if (event is SelecionarSituacaoEvent) {
      _state.situacaoFk = event.situacaoFk;
    }
    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(QuestaoModel.collection)
          .document(_state.questaoID);

      QuestaoModel questaoUpdate = QuestaoModel(
        inicio: _state.inicioAvaliacao,
        fim: _state.fimAvaliacao,
        tempo: int.parse(_state.tempo),
        tentativa: int.parse(_state.tentativa),
        erroRelativo: int.parse(_state.erroRelativo),
        nota: _state.nota,
        modificado: DateTime.now(),
        situacao: SituacaoFk(
          id: _state.situacaoFk.id,
          nome: _state.situacaoFk.nome,
          url: _state.situacaoFk.url,
        ),
      );
      if (_state.questaoID == null) {
        questaoUpdate.ativo = true;
        questaoUpdate.professor = UsuarioFk(
          id: _state.avaliacao.professor.id,
          nome: _state.avaliacao.professor.nome,
        );
        questaoUpdate.turma = TurmaFk(
          id: _state.avaliacao.turma.id,
          nome: _state.avaliacao.turma.nome,
        );
        questaoUpdate.avaliacao = AvaliacaoFk(
          id: _state.avaliacao.id,
          nome: _state.avaliacao.nome,
        );
      }
      await docRef.setData(questaoUpdate.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      if (_state.questaoID != null) {
        _firestore
            .collection(QuestaoModel.collection)
            .document(_state.questao.id)
            .delete();
      }
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em QuestaoCRUDBloc  = ${event.runtimeType}');
  }
}
