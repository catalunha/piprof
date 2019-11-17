import 'package:piprof/modelos/encontro_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class EncontroAlunoListBlocEvent {}

class GetAlunoListEvent extends EncontroAlunoListBlocEvent {
  final String turmaID;
  final String encontroID;

  GetAlunoListEvent({this.turmaID, this.encontroID});
}

class MarcarAlunoEvent extends EncontroAlunoListBlocEvent {
  final String alunoID;

  MarcarAlunoEvent(this.alunoID);
}

class AlunoInfo {
  final UsuarioModel usuario;
  bool presente;
  AlunoInfo({this.usuario, this.presente});
}

class SaveEvent extends EncontroAlunoListBlocEvent {}

class EncontroAlunoListBlocState {
  bool isDataValid = false;
  EncontroModel encontro = EncontroModel();
  Map<String, AlunoInfo> alunoInfoMap = Map<String, AlunoInfo>();
}

class EncontroAlunoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<EncontroAlunoListBlocEvent>();
  Stream<EncontroAlunoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final EncontroAlunoListBlocState _state = EncontroAlunoListBlocState();
  final _stateController = BehaviorSubject<EncontroAlunoListBlocState>();
  Stream<EncontroAlunoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  EncontroAlunoListBloc(this._firestore) {
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

  _mapEventToState(EncontroAlunoListBlocEvent event) async {
    if (event is GetAlunoListEvent) {
      final encontroFutureDocSnapshot = await _firestore
          .collection(EncontroModel.collection)
          .document(event.encontroID)
          .get();

      EncontroModel encontro =
          EncontroModel(id: encontroFutureDocSnapshot.documentID)
              .fromMap(encontroFutureDocSnapshot.data);
      _state.encontro = encontro;
      _state.alunoInfoMap.clear();

      final futureQuerySnapshot = await _firestore
          .collection(UsuarioModel.collection)
          .where("turma", arrayContains: encontro.turma.id)
          .getDocuments();

      var usuarioList = futureQuerySnapshot.documents
          .map((doc) => UsuarioModel(id: doc.documentID).fromMap(doc.data))
          .toList();

      usuarioList.sort((a, b) => a.nome.compareTo(b.nome));

      bool presente;
      for (var usuario in usuarioList) {
        presente = false;
        if (encontro.aluno != null) {
          presente = encontro.aluno.contains(usuario.id);
        }
        _state.alunoInfoMap[usuario.id] =
            AlunoInfo(usuario: usuario, presente: presente);
      }
    }

    if (event is MarcarAlunoEvent) {
      _state.alunoInfoMap[event.alunoID].presente =
          !_state.alunoInfoMap[event.alunoID].presente;
    }

    if (event is SaveEvent) {
      var docRef = _firestore
          .collection(EncontroModel.collection)
          .document(_state.encontro.id);
      List<dynamic> aluno = List<dynamic>();
      for (var alunoMap in _state.alunoInfoMap.entries) {
        if (alunoMap.value.presente) {
          aluno.add(alunoMap.key);
        }
      }

      await docRef.setData({"aluno": aluno}, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em EncontroAlunoListBloc  = ${event.runtimeType}');
  }
}
