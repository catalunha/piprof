import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class TurmaInativaListBlocEvent {}

class GetUsuarioAuthEvent extends TurmaInativaListBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class UpdateTurmaInativaListEvent extends TurmaInativaListBlocEvent {}

class AtivarTurmaEvent extends TurmaInativaListBlocEvent {
  final String turmaID;

  AtivarTurmaEvent(this.turmaID);
}

class TurmaInativaListBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  List<TurmaModel> turmaList = List<TurmaModel>();
}

class TurmaInativaListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TurmaInativaListBlocEvent>();
  Stream<TurmaInativaListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TurmaInativaListBlocState _state = TurmaInativaListBlocState();
  final _stateController = BehaviorSubject<TurmaInativaListBlocState>();
  Stream<TurmaInativaListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TurmaInativaListBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
      eventSink(UpdateTurmaInativaListEvent());
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
  }

  _mapEventToState(TurmaInativaListBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is UpdateTurmaInativaListEvent) {
      final streamDocsRemetente = _firestore
          .collection(TurmaModel.collection)
          .where("ativo", isEqualTo: false)
          .where("professor.id", isEqualTo: _state?.usuarioAuth?.id)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => TurmaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<TurmaModel> turmaList) {
        if (turmaList.length > 1) {
          turmaList.sort((a, b) => a.numero.compareTo(b.numero));
        }

        _state.turmaList.clear();
        _state.turmaList = turmaList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is AtivarTurmaEvent) {
      print(event.turmaID);
      final docRef =
          _firestore.collection(TurmaModel.collection).document(event.turmaID);
      await docRef.setData({"ativo": true}, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TurmaInativaListBloc  = ${event.runtimeType}');
  }
}
