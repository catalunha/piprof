import 'package:flutter/material.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class SituacaoCRUDBlocEvent {}

class GetUsuarioAuthEvent extends SituacaoCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetPastaEvent extends SituacaoCRUDBlocEvent {
  final String pastaID;

  GetPastaEvent(this.pastaID);
}

class GetPastaListEvent extends SituacaoCRUDBlocEvent {}

class GetSituacaoEvent extends SituacaoCRUDBlocEvent {
  final String situacaoID;

  GetSituacaoEvent(this.situacaoID);
}

class UpdateAtivoEvent extends SituacaoCRUDBlocEvent {
  final bool ativo;
  UpdateAtivoEvent(this.ativo);
}

class UpdateTextFieldEvent extends SituacaoCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class UpdatePrecisaAlgoritmoPSimulacaoEvent extends SituacaoCRUDBlocEvent {
  final bool precisa;
  UpdatePrecisaAlgoritmoPSimulacaoEvent(this.precisa);
}

class SelectPastaIDEvent extends SituacaoCRUDBlocEvent {
  final PastaModel pasta;

  SelectPastaIDEvent(this.pasta);
}

class SaveEvent extends SituacaoCRUDBlocEvent {}

class DeleteDocumentEvent extends SituacaoCRUDBlocEvent {}

class SituacaoCRUDBlocState {
  bool isDataValid = false;
  String situacaoID;
  UsuarioModel usuarioAuth;

  PastaModel pasta = PastaModel();
  List<PastaModel> pastaList = List<PastaModel>();

  SituacaoModel situacao = SituacaoModel();

  // dynamic data;
  String nome;
  String descricao;
  bool ativo = true;
  bool precisaAlgoritmoPSimulacao = false;
  String urlPDFSituacaoSemAlgoritmo;
  bool ativadoAlgoritmoPSimulacao;
  PastaFk pastaDestino;

  void updateState() {
    ativo = situacao.ativo;
    nome = situacao.nome;
    descricao = situacao.descricao;
    precisaAlgoritmoPSimulacao = situacao.precisaAlgoritmoPSimulacao;
    urlPDFSituacaoSemAlgoritmo = situacao.urlPDFSituacaoSemAlgoritmo;
    ativadoAlgoritmoPSimulacao = situacao.ativadoAlgoritmoPSimulacao;
    pastaDestino = situacao?.pasta;
  }

  bool liberaAtivo() {
    if (precisaAlgoritmoPSimulacao == true &&
        situacao.ativadoAlgoritmoPSimulacao == false) {
      return false;
    } else {
      return true;
    }
  }
}

class SituacaoCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<SituacaoCRUDBlocEvent>();
  Stream<SituacaoCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SituacaoCRUDBlocState _state = SituacaoCRUDBlocState();
  final _stateController = BehaviorSubject<SituacaoCRUDBlocState>();
  Stream<SituacaoCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SituacaoCRUDBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
      eventSink(GetPastaListEvent());
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
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
    if (_state.precisaAlgoritmoPSimulacao == false &&
        _state.urlPDFSituacaoSemAlgoritmo == null) {
      _state.isDataValid = false;
    }
    if (_state.urlPDFSituacaoSemAlgoritmo != null &&
        _state.urlPDFSituacaoSemAlgoritmo.isEmpty) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SituacaoCRUDBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetPastaEvent) {
      final docRef =
          _firestore.collection(PastaModel.collection).document(event.pastaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.pasta = PastaModel(id: snap.documentID).fromMap(snap.data);
        _state.pastaDestino =
            PastaFk(id: _state.pasta.id, nome: _state.pasta.nome);
      }
    }

    if (event is GetPastaListEvent) {
      _state.pastaList.clear();

      final streamDocsRemetente = _firestore
          .collection(PastaModel.collection)
          .where("professor.id", isEqualTo: _state.usuarioAuth.id)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => PastaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<PastaModel> pastaList) {
        pastaList.sort((a, b) => a.numero.compareTo(b.numero));
        _state.pastaList = pastaList;
        // print(_state.pastaList);
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is GetSituacaoEvent) {
      final docRef = _firestore
          .collection(SituacaoModel.collection)
          .document(event.situacaoID);
      _state.situacaoID = event.situacaoID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.situacao = SituacaoModel(id: snap.documentID).fromMap(snap.data);
        _state.updateState();
      }
    }
    if (event is UpdateAtivoEvent) {
      _state.ativo = event.ativo;
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'descricao') {
        _state.descricao = event.texto;
      } else if (event.campo == 'urlPDFSituacaoSemAlgoritmo') {
        _state.urlPDFSituacaoSemAlgoritmo = event.texto;
      }
    }

    if (event is UpdatePrecisaAlgoritmoPSimulacaoEvent) {
      _state.precisaAlgoritmoPSimulacao = event.precisa;
      _state.ativadoAlgoritmoPSimulacao = false;
    }

    if (event is SelectPastaIDEvent) {
      _state.pastaDestino = PastaFk(id: event.pasta.id, nome: event.pasta.nome);
    }

    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(SituacaoModel.collection)
          .document(_state.situacaoID);

      SituacaoModel situacaoUpdate = SituacaoModel(
        ativo: _state.precisaAlgoritmoPSimulacao &&
                _state.situacao.ativadoAlgoritmoPSimulacao == false
            ? false
            : _state.ativo,
        nome: _state.nome,
        descricao: _state.descricao,
        precisaAlgoritmoPSimulacao: _state.precisaAlgoritmoPSimulacao,
        urlPDFSituacaoSemAlgoritmo: _state.urlPDFSituacaoSemAlgoritmo,
        ativadoAlgoritmoPSimulacao: _state.ativadoAlgoritmoPSimulacao,
        modificado: DateTime.now(),
        pasta: _state.pastaDestino,
      );
      if (_state.precisaAlgoritmoPSimulacao) {
        situacaoUpdate.url = null;
      } else {
        situacaoUpdate.url = _state.urlPDFSituacaoSemAlgoritmo;
      }
      situacaoUpdate.url = _state.situacao.url;

      if (_state.situacaoID == null) {
        situacaoUpdate.numero =
            (_state.usuarioAuth.situacaoNumeroAdicionado ?? 0) + 1;
        //+++ Atualizar usuario com mais uma pasta em seu cadastro
        final usuarioDocRef = _firestore
            .collection(UsuarioModel.collection)
            .document(_state.usuarioAuth.id);
        await usuarioDocRef.setData({
          'situacaoNumeroAdicionado':
              Bootstrap.instance.fieldValue.increment(1),
        }, merge: true);
        //---
        situacaoUpdate.professor = UsuarioFk(
          id: _state.usuarioAuth.id,
          nome: _state.usuarioAuth.nome,
        );
      }

      await docRef.setData(situacaoUpdate.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(SituacaoModel.collection)
          .document(_state.situacao.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em SituacaoCRUDBloc  = ${event.runtimeType}');
  }
}
