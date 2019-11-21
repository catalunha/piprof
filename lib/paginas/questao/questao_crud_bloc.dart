import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/questao_model.dart';
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class QuestaoCRUDBlocEvent {}

class GetUsuarioAuthEvent extends QuestaoCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetTurmaEvent extends QuestaoCRUDBlocEvent {
  final String turmaID;

  GetTurmaEvent(this.turmaID);
}

class GetAvaliacaoEvent extends QuestaoCRUDBlocEvent {
  final String avaliacaoID;

  GetAvaliacaoEvent(this.avaliacaoID);
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

class UpdateTextFieldEvent extends QuestaoCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class UpdateNumberFieldEvent extends QuestaoCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateNumberFieldEvent(this.campo, this.texto);
}

class SelecionarProblemaEvent extends QuestaoCRUDBlocEvent {
  final ProblemaFk problemaFk;

  SelecionarProblemaEvent(this.problemaFk);
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
  ProblemaFk problemaFk;
  // ProblemaModel problema;
  // dynamic data;
  String tempo;
  String tentativa;
  String erroRelativo;
  String nota;
  DateTime inicioQuestao;
  DateTime fimQuestao;
  DateTime dataInicio;
  TimeOfDay horaInicio;
  DateTime dataFim;
  TimeOfDay horaFim;
  void updateState() {
    inicioQuestao = questao.inicio;
    fimQuestao = questao.fim;
    tempo = questao.tempo.toString();
    tentativa = questao.tentativa.toString();
    erroRelativo = questao.erroRelativo.toString();
    nota = questao.nota;
    problemaFk = questao.problema;
    questao.aplicada = questao.aplicada == null ? false : questao.aplicada;
  }

  void updateStateComAvaliacao() {
    inicioQuestao = avaliacao.inicio;
    fimQuestao = avaliacao.fim;
    tempo = '2';
    tentativa = '3';
    erroRelativo = '10';
    nota = '1';
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
    if (_state.inicioQuestao == null) {
      _state.isDataValid = false;
    }
    if (_state.fimQuestao == null) {
      _state.isDataValid = false;
    }
    if (_state.inicioQuestao != null &&
        _state.fimQuestao != null &&
        _state.inicioQuestao.isAfter(_state.fimQuestao)) {
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
    if (_state.nota == null || _state.nota.isEmpty) {
      _state.isDataValid = false;
    }
    if (_state.problemaFk == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(QuestaoCRUDBlocEvent event) async {
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
    if (event is GetAvaliacaoEvent) {
      if (event.avaliacaoID != null) {
        final docRef = _firestore
            .collection(AvaliacaoModel.collection)
            .document(event.avaliacaoID);
        final snap = await docRef.get();
        if (snap.exists) {
          _state.avaliacao =
              AvaliacaoModel(id: snap.documentID).fromMap(snap.data);
          _state.updateStateComAvaliacao();

          eventSink(GetTurmaEvent(_state.avaliacao.turma.id));
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
      if (_state.inicioQuestao == null && event.data != null) {
        _state.horaInicio = TimeOfDay.now();
      }
      if (_state.inicioQuestao == null && event.hora != null) {
        _state.dataInicio = DateTime.now();
      }
      final newDate = DateTime(
          _state.dataInicio != null
              ? _state.dataInicio.year
              : _state.inicioQuestao.year,
          _state.dataInicio != null
              ? _state.dataInicio.month
              : _state.inicioQuestao.month,
          _state.dataInicio != null
              ? _state.dataInicio.day
              : _state.inicioQuestao.day,
          _state.horaInicio != null
              ? _state.horaInicio.hour
              : _state.inicioQuestao.hour,
          _state.horaInicio != null
              ? _state.horaInicio.minute
              : _state.inicioQuestao.minute);
      _state.inicioQuestao = newDate;
    }

    if (event is UpdateDataFimEvent) {
      if (event.data != null) {
        _state.dataFim = event.data;
      }
      if (event.hora != null) {
        _state.horaFim = event.hora;
      }
      if (_state.fimQuestao == null && event.data != null) {
        _state.horaFim = TimeOfDay.now();
      }
      if (_state.fimQuestao == null && event.hora != null) {
        _state.dataFim = DateTime.now();
      }
      final newDate = DateTime(
          _state.dataFim != null ? _state.dataFim.year : _state.fimQuestao.year,
          _state.dataFim != null
              ? _state.dataFim.month
              : _state.fimQuestao.month,
          _state.dataFim != null ? _state.dataFim.day : _state.fimQuestao.day,
          _state.horaFim != null ? _state.horaFim.hour : _state.fimQuestao.hour,
          _state.horaFim != null
              ? _state.horaFim.minute
              : _state.fimQuestao.minute);
      _state.fimQuestao = newDate;
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
        if (a <= 0 || a > 100) {
          _state.erroRelativo = '10';
        }
      }
    }

    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nota') {
        _state.nota = event.texto;
      }
    }

    if (event is SelecionarProblemaEvent) {
      _state.problemaFk = event.problemaFk;
    }
    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(QuestaoModel.collection)
          .document(_state.questaoID);

      QuestaoModel questaoUpdate = QuestaoModel(
        inicio: _state.inicioQuestao,
        fim: _state.fimQuestao,
        tempo: int.parse(_state.tempo),
        tentativa: int.parse(_state.tentativa),
        erroRelativo: int.parse(_state.erroRelativo),
        nota: _state.nota,
        modificado: DateTime.now(),
        problema: ProblemaFk(
          id: _state.problemaFk.id,
          nome: _state.problemaFk.nome,
          url: _state.problemaFk.url,
        ),
      );
      if (_state.questaoID == null) {
        questaoUpdate.ativo = true;
        questaoUpdate.aplicada = false;
        questaoUpdate.numero = (_state.turma.questaoNumero ?? 0) + 1;
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
      await docRef
          .setData(questaoUpdate.toMap(), merge: true)
          .then((_) async {
        if (_state.questaoID == null) {
          //+++ Atualizar turma com mais uma questao
          final turmaDocRef = _firestore
              .collection(TurmaModel.collection)
              .document(_state.turma.id);
          await turmaDocRef.setData({
            'questaoNumero':
                Bootstrap.instance.fieldValue.increment(1),
          }, merge: true);
          //---
          //+++ Atualizando avaliacao acrescentando esta questao da lista questaoAplicada
          var avaliacaoDocRef = _firestore
              .collection(AvaliacaoModel.collection)
              .document(_state.avaliacao.id);
          await avaliacaoDocRef.setData({
            "questaoAplicada":
                Bootstrap.instance.fieldValue.arrayUnion([docRef.documentID]),
            "aplicar": false,
            "aplicada": false,
          }, merge: true);
          //---
        }
      });
      // if (_state.questaoID == null) {
      //   //+++ Atualizando avaliacao acrescentando esta questao da lista questaoAplicada
      //   var avaliacaoDocRef = _firestore
      //       .collection(AvaliacaoModel.collection)
      //       .document(_state.avaliacao.id);
      //   await avaliacaoDocRef.setData({
      //     "questaoAplicada":
      //         Bootstrap.instance.fieldValue.arrayUnion([docRef.documentID]),
      //     "aplicar": false,
      //     "aplicada": false,
      //   }, merge: true);
      //   //---
      // }
    }
    if (event is DeleteDocumentEvent) {
      if (_state.questaoID != null) {
        _firestore
            .collection(QuestaoModel.collection)
            .document(_state.questao.id)
            .delete();
        //Function atualiza Avaliacao.questaoAplicada e Avaliacao.questaoAplicadaFunction
      }
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em QuestaoCRUDBloc  = ${event.runtimeType}');
  }
}
