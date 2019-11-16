import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class AvaliacaoListBlocEvent {}

// class GetUsuarioAuthEvent extends AvaliacaoListBlocEvent {
//   final UsuarioModel usuarioAuth;
//   GetUsuarioAuthEvent(this.usuarioAuth);
// }

// class GetTurmaIDEvent extends AvaliacaoListBlocEvent {
//   final String turmaID;
//   GetTurmaIDEvent(this.turmaID);
// }

class UpdateAvaliacaoListEvent extends AvaliacaoListBlocEvent {
  final String turmaID;

  UpdateAvaliacaoListEvent(this.turmaID);
}

class AvaliacaoListBlocState {
  bool isDataValid = false;
  // UsuarioModel usuarioAuth;
  String turmaID;
  List<AvaliacaoModel> avaliacaoList = List<AvaliacaoModel>();
}

class AvaliacaoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<AvaliacaoListBlocEvent>();
  Stream<AvaliacaoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final AvaliacaoListBlocState _state = AvaliacaoListBlocState();
  final _stateController = BehaviorSubject<AvaliacaoListBlocState>();
  Stream<AvaliacaoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  AvaliacaoListBloc(
    this._firestore,
    // this._authBloc,
  ) {
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

  _mapEventToState(AvaliacaoListBlocEvent event) async {
    if (event is UpdateAvaliacaoListEvent) {
      final streamDocsRemetente = _firestore
          .collection(AvaliacaoModel.collection)
          .where("turma.id", isEqualTo: event.turmaID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => AvaliacaoModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<AvaliacaoModel> avaliacaoList) {
        avaliacaoList.sort((a, b) => a.inicio.compareTo(b.inicio));

        _state.avaliacaoList.clear();
        _state.avaliacaoList = avaliacaoList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em AvaliacaoListBloc  = ${event.runtimeType}');
  }
}
