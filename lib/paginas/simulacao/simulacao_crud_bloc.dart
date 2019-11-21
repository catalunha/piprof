import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/problema_model.dart';
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

class GetProblemaEvent extends SimulacaoCRUDBlocEvent {
  final String problemaID;

  GetProblemaEvent(this.problemaID);
}

class UpdateTextFieldEvent extends SimulacaoCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class SaveEvent extends SimulacaoCRUDBlocEvent {}

class DeleteDocumentEvent extends SimulacaoCRUDBlocEvent {}

class SimulacaoCRUDBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  String simulacaoID;
  SimulacaoModel simulacao = SimulacaoModel();
  ProblemaModel problema = ProblemaModel();

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
    if (event is GetProblemaEvent) {
      final docRef = _firestore
          .collection(ProblemaModel.collection)
          .document(event.problemaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.problema = ProblemaModel(id: snap.documentID).fromMap(snap.data);
      }
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'descricao') {
        _state.descricao = event.texto;
      } else if (event.campo == 'url') {
        _state.url = event.texto;
      }
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
        simulacaoModel.numero = (_state.problema.simulacaoNumero ?? 0) + 1;

        simulacaoModel.ordem = 0;
        simulacaoModel.algoritmoDoAdmin = false;
        simulacaoModel.algoritmoDoProfessor = false;
        simulacaoModel.professor =
            UsuarioFk(id: _state.usuarioAuth.id, nome: _state.usuarioAuth.nome);
        simulacaoModel.problema =
            ProblemaFk(id: _state.problema.id, nome: _state.problema.nome);
      }
      await docRef.setData(simulacaoModel.toMap(), merge: true).then((_) async {
        if (_state.simulacaoID == null) {
          //+++ Atualizar problema com mais uma em seu cadastro
          final usuarioDocRef = _firestore
              .collection(ProblemaModel.collection)
              .document(_state.problema.id);
          await usuarioDocRef.setData({
            'simulacaoNumero': Bootstrap.instance.fieldValue.increment(1),
          }, merge: true);
          //---
        }
      });
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id)
          .delete();
      //+++ Atualizar problema com menos uma em seu cadastro
      final docRef = _firestore
          .collection(ProblemaModel.collection)
          .document(_state.problema.id);
      await docRef.setData({
        'simulacaoNumero': Bootstrap.instance.fieldValue.increment(-1),
      }, merge: true);
      //---
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em SimulacaoCRUDBloc  = ${event.runtimeType}');
  }
}
