import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class TurmaAtivaListBlocEvent {}

class GetUsuarioAuthEvent extends TurmaAtivaListBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class UpdateTurmaAtivaListEvent extends TurmaAtivaListBlocEvent {}

class OrdenarEvent extends TurmaAtivaListBlocEvent {
  final TurmaModel obj;
  final bool up;

  OrdenarEvent(this.obj, this.up);
}

class TurmaAtivaListBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  List<TurmaModel> turmaList = List<TurmaModel>();
}

class TurmaAtivaListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TurmaAtivaListBlocEvent>();
  Stream<TurmaAtivaListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TurmaAtivaListBlocState _state = TurmaAtivaListBlocState();
  final _stateController = BehaviorSubject<TurmaAtivaListBlocState>();
  Stream<TurmaAtivaListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TurmaAtivaListBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
      eventSink(UpdateTurmaAtivaListEvent());
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

  _mapEventToState(TurmaAtivaListBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is UpdateTurmaAtivaListEvent) {
      _state.turmaList.clear();

      final streamDocsRemetente = _firestore
          .collection(TurmaModel.collection)
          .where("ativo", isEqualTo: true)
          .where("professor.id", isEqualTo: _state.usuarioAuth?.id)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => TurmaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<TurmaModel> turmaList) {
                if (turmaList.length > 1) {
          turmaList
              .sort((a, b) => a.numero.compareTo(b.numero));
        }

        _state.turmaList = turmaList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is OrdenarEvent) {
      final ordemOrigem = _state.turmaList.indexOf(event.obj);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;
      TurmaModel turmaOrigem = _state.turmaList[ordemOrigem];
      TurmaModel turmaDestino = _state.turmaList[ordemDestino];

      final collectionRef = _firestore.collection(TurmaModel.collection);

      final docOrigem = collectionRef.document(turmaOrigem.id);
      final docDestino = collectionRef.document(turmaDestino.id);

      docOrigem.setData({"numero": turmaDestino.numero}, merge: true);
      docDestino.setData({"numero": turmaOrigem.numero}, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TurmaAtivaListBloc  = ${event.runtimeType}');
  }
}
