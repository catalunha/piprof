import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/situacao_model.dart';
import 'package:rxdart/rxdart.dart';

class SituacaoListBlocEvent {}

class GetSituacaoListEvent extends SituacaoListBlocEvent {
  final String pastaID;

  GetSituacaoListEvent(this.pastaID);
}
class OrdenarEvent extends SituacaoListBlocEvent {
  final SituacaoModel obj;
  final bool up;

  OrdenarEvent(this.obj, this.up);
}

class SituacaoListBlocState {
  bool isDataValid = false;
  List<SituacaoModel> situacaoList = List<SituacaoModel>();
}

class SituacaoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<SituacaoListBlocEvent>();
  Stream<SituacaoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SituacaoListBlocState _state = SituacaoListBlocState();
  final _stateController = BehaviorSubject<SituacaoListBlocState>();
  Stream<SituacaoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SituacaoListBloc(this._firestore) {
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

  _mapEventToState(SituacaoListBlocEvent event) async {
    if (event is GetSituacaoListEvent) {
        _state.situacaoList.clear();

        final streamDocsRemetente = _firestore
            .collection(SituacaoModel.collection)
            .where("pasta.id", isEqualTo: event.pastaID)
            .snapshots();

        final snapListRemetente = streamDocsRemetente.map(
            (snapDocs) => snapDocs.documents.map((doc) => SituacaoModel(id: doc.documentID).fromMap(doc.data)).toList());

        snapListRemetente.listen((List<SituacaoModel> situacaoList) {
          situacaoList.sort((a, b) => a.numero.compareTo(b.numero));
          _state.situacaoList = situacaoList;
          if (!_stateController.isClosed) _stateController.add(_state);
        });
    }
        if (event is OrdenarEvent) {
      final ordemOrigem = _state.situacaoList.indexOf(event.obj);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;
      SituacaoModel docOrigem = _state.situacaoList[ordemOrigem];
      SituacaoModel docDestino = _state.situacaoList[ordemDestino];

      final collectionRef = _firestore.collection(SituacaoModel.collection);

      final colRefOrigem = collectionRef.document(docOrigem.id);
      final colRefDestino = collectionRef.document(docDestino.id);

      colRefOrigem.setData({"numero": docDestino.numero}, merge: true);
      colRefDestino.setData({"numero": docOrigem.numero}, merge: true);
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em SituacaoListBloc  = ${event.runtimeType}');
  }
}
