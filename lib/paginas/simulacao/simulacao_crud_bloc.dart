import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class SimulacaoCRUDBlocEvent {}

class GetUsuarioAuthEvent extends SimulacaoCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetSimulacaoEvent extends SimulacaoCRUDBlocEvent {
  final String simulacaoID;

  GetSimulacaoEvent(this.simulacaoID);
}

class GetSituacaoEvent extends SimulacaoCRUDBlocEvent {
  final String situacaoID;

  GetSituacaoEvent(this.situacaoID);
}

class UpdateNomeEvent extends SimulacaoCRUDBlocEvent {
  final String nome;
  UpdateNomeEvent(this.nome);
}

class UpdateDescricaoEvent extends SimulacaoCRUDBlocEvent {
  final String descricao;
  UpdateDescricaoEvent(this.descricao);
}

class UpdateUrlEvent extends SimulacaoCRUDBlocEvent {
  final String url;
  UpdateUrlEvent(this.url);
}

class SaveEvent extends SimulacaoCRUDBlocEvent {}

class DeleteDocumentEvent extends SimulacaoCRUDBlocEvent {}

class SimulacaoCRUDBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  String simulacaoID;
  SimulacaoModel simulacao = SimulacaoModel();
  SituacaoModel situacao = SituacaoModel();

  String nome;
  String descricao;
  String url;

  void updateState() {
    nome = simulacao.nome;
    descricao = simulacao.descricao;
    url = simulacao.url;
  }
}

class SimulacaoCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoCRUDBlocEvent>();
  Stream<SimulacaoCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoCRUDBlocState _state = SimulacaoCRUDBlocState();
  final _stateController = BehaviorSubject<SimulacaoCRUDBlocState>();
  Stream<SimulacaoCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoCRUDBloc(this._firestore, this._authBloc) {
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
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoCRUDBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetSimulacaoEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID);
      _state.simulacaoID = event.simulacaoID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.simulacao =
            SimulacaoModel(id: snap.documentID).fromMap(snap.data);
        _state.updateState();
      }
    }
    if (event is GetSituacaoEvent) {
      final docRef = _firestore
          .collection(SituacaoModel.collection)
          .document(event.situacaoID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.situacao = SituacaoModel(id: snap.documentID).fromMap(snap.data);
      }
    }
    if (event is UpdateNomeEvent) {
      _state.nome = event.nome;
    }
    if (event is UpdateDescricaoEvent) {
      _state.descricao = event.descricao;
    }
    if (event is UpdateUrlEvent) {
      _state.url = event.url;
    }
    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacaoID);

      SimulacaoModel simulacaoModel = SimulacaoModel(
        nome: _state.nome,
        descricao: _state.descricao,
        url: _state.url,
      );
      if (_state.simulacaoID == null) {
        simulacaoModel.ordemAdicionada=0;
        simulacaoModel.algoritmoDoAdmin = false;
        simulacaoModel.algoritmoDoProfessor = false;
        simulacaoModel.professor =
            UsuarioFk(id: _state.usuarioAuth.id, nome: _state.usuarioAuth.nome);
        simulacaoModel.situacao =
            SituacaoFk(id: _state.situacao.id, nome: _state.situacao.nome);
      }
      await docRef.setData(simulacaoModel.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em SimulacaoCRUDBloc  = ${event.runtimeType}');
  }
}