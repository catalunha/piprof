import 'package:piprof/modelos/encontro_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class EncontroListBlocEvent {}

class GetTurmaEncontroListEvent extends EncontroListBlocEvent {
  final String turmaID;

  GetTurmaEncontroListEvent(this.turmaID);
}

class CreateRelatorioEvent extends EncontroListBlocEvent {
  final String turmaId;

  CreateRelatorioEvent(this.turmaId);
}

class ResetCreateRelatorioEvent extends EncontroListBlocEvent {}

class EncontroListBlocState {
  bool isDataValid = false;
  List<EncontroModel> encontroList = List<EncontroModel>();
  String pedidoRelatorio;
}

class EncontroListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<EncontroListBlocEvent>();
  Stream<EncontroListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final EncontroListBlocState _state = EncontroListBlocState();
  final _stateController = BehaviorSubject<EncontroListBlocState>();
  Stream<EncontroListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  EncontroListBloc(this._firestore) {
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

  _mapEventToState(EncontroListBlocEvent event) async {
    if (event is GetTurmaEncontroListEvent) {
      final streamDocsRemetente = _firestore
          .collection(EncontroModel.collection)
          .where("turma.id", isEqualTo: event.turmaID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => EncontroModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<EncontroModel> encontroList) {
        encontroList.sort((a, b) => a.inicio.compareTo(b.inicio));
        _state.encontroList.clear();
        _state.encontroList = encontroList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is CreateRelatorioEvent) {
      final docRef = _firestore.collection('Relatorio').document();
      await docRef.setData({'turmaId': event.turmaId}, merge: true).then((_) {
        _state.pedidoRelatorio = docRef.documentID;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is ResetCreateRelatorioEvent) {
      _state.pedidoRelatorio = null;
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em EncontroListBloc  = ${event.runtimeType}');
  }
}
