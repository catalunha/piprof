import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class AvaliacaoAplicarBlocEvent {}

class GetAlunoListEvent extends AvaliacaoAplicarBlocEvent {
  final String avaliacaoID;

  GetAlunoListEvent(this.avaliacaoID);
}

class MarcarAlunoEvent extends AvaliacaoAplicarBlocEvent {
  final String alunoID;

  MarcarAlunoEvent(this.alunoID);
}

class AlunoInfo {
  final UsuarioModel usuario;
  bool aplicar;
  bool aplicada;
  AlunoInfo({
    this.usuario,
    this.aplicar,
    this.aplicada,
  });
}

class MarcarTodosEvent extends AvaliacaoAplicarBlocEvent {}

class DesmarcarTodosEvent extends AvaliacaoAplicarBlocEvent {}

class SaveEvent extends AvaliacaoAplicarBlocEvent {}

class AvaliacaoAplicarBlocState {
  bool isDataValid = false;
  AvaliacaoModel avaliacao = AvaliacaoModel();
  Map<String, AlunoInfo> alunoInfoMap = Map<String, AlunoInfo>();
}

class AvaliacaoAplicarBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<AvaliacaoAplicarBlocEvent>();
  Stream<AvaliacaoAplicarBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final AvaliacaoAplicarBlocState _state = AvaliacaoAplicarBlocState();
  final _stateController = BehaviorSubject<AvaliacaoAplicarBlocState>();
  Stream<AvaliacaoAplicarBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  AvaliacaoAplicarBloc(this._firestore) {
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
  }

  _mapEventToState(AvaliacaoAplicarBlocEvent event) async {
    if (event is GetAlunoListEvent) {
      final avaliacaoFutureDocSnapshot = await _firestore
          .collection(AvaliacaoModel.collection)
          .document(event.avaliacaoID)
          .get();

      AvaliacaoModel avaliacao =
          AvaliacaoModel(id: avaliacaoFutureDocSnapshot.documentID)
              .fromMap(avaliacaoFutureDocSnapshot.data);
      _state.avaliacao = avaliacao;
      _state.alunoInfoMap.clear();

      final futureQuerySnapshot = await _firestore
          .collection(UsuarioModel.collection)
          // .where("ativo", isEqualTo: true)
          .where("turma", arrayContains: avaliacao.turma.id)
          .getDocuments();

      var usuarioList = futureQuerySnapshot.documents
          .map((doc) => UsuarioModel(id: doc.documentID).fromMap(doc.data))
          .toList();

      usuarioList.sort((a, b) => a.nome.compareTo(b.nome));

      bool aplicada = false;
      if (_state.avaliacao.aplicadaPAluno != null) {
        for (var usuario in usuarioList) {
          aplicada = avaliacao.aplicadaPAluno.contains(usuario.id);
          _state.alunoInfoMap[usuario.id] =
              AlunoInfo(usuario: usuario, aplicar: false, aplicada: aplicada);
        }
      } else {
        for (var usuario in usuarioList) {
          _state.alunoInfoMap[usuario.id] =
              AlunoInfo(usuario: usuario, aplicar: false, aplicada: aplicada);
        }
      }
    }

    if (event is MarcarAlunoEvent) {
      _state.alunoInfoMap[event.alunoID].aplicar =
          !_state.alunoInfoMap[event.alunoID].aplicar;
    }

    if (event is MarcarTodosEvent) {
      for (var alunoInfo in _state.alunoInfoMap.entries) {
        _state.alunoInfoMap[alunoInfo.key].aplicar = true;
      }
    }
    if (event is DesmarcarTodosEvent) {
      for (var alunoInfo in _state.alunoInfoMap.entries) {
        _state.alunoInfoMap[alunoInfo.key].aplicar = false;
      }
    }
    if (event is SaveEvent) {
      List<dynamic> aplicadaPAluno = List<dynamic>();
      for (var alunoMap in _state.alunoInfoMap.entries) {
        if (alunoMap.value.aplicar || alunoMap.value.aplicada) {
          aplicadaPAluno.add(alunoMap.key);
          _state.alunoInfoMap[alunoMap.key].aplicada = true;
        }
      }

        var docRef = _firestore
            .collection(AvaliacaoModel.collection)
            .document(_state.avaliacao.id);
        await docRef.setData({
          "aplicadaPAluno": Bootstrap.instance.fieldValue.arrayUnion(aplicadaPAluno),
          "aplicar": false,
          "aplicada": false,
        }, merge: true);
      
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em AvaliacaoAplicarBloc  = ${event.runtimeType}');
  }
}
