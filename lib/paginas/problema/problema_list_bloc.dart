import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/problema_model.dart';
import 'package:rxdart/rxdart.dart';

class ProblemaListBlocEvent {}

class GetProblemaListEvent extends ProblemaListBlocEvent {
  final String pastaID;

  GetProblemaListEvent(this.pastaID);
}

class OrdenarEvent extends ProblemaListBlocEvent {
  final ProblemaModel obj;
  final bool up;

  OrdenarEvent(this.obj, this.up);
}
class CreateRelatorioEvent extends ProblemaListBlocEvent {
  final String problemaId;

  CreateRelatorioEvent(this.problemaId);
}

class ResetCreateRelatorioEvent extends ProblemaListBlocEvent {}

class ProblemaListBlocState {
  bool isDataValid = false;
    String pedidoRelatorio;

  List<ProblemaModel> problemaList = List<ProblemaModel>();
}

class ProblemaListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<ProblemaListBlocEvent>();
  Stream<ProblemaListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final ProblemaListBlocState _state = ProblemaListBlocState();
  final _stateController = BehaviorSubject<ProblemaListBlocState>();
  Stream<ProblemaListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  ProblemaListBloc(this._firestore) {
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

  _mapEventToState(ProblemaListBlocEvent event) async {
    if (event is GetProblemaListEvent) {
      final streamDocsRemetente = _firestore
          .collection(ProblemaModel.collection)
          .where("pasta.id", isEqualTo: event.pastaID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => ProblemaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<ProblemaModel> problemaList) {
        problemaList.sort((a, b) => a.numero.compareTo(b.numero));
        _state.problemaList.clear();
        _state.problemaList = problemaList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is OrdenarEvent) {
      final ordemOrigem = _state.problemaList.indexOf(event.obj);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;
      ProblemaModel docOrigem = _state.problemaList[ordemOrigem];
      ProblemaModel docDestino = _state.problemaList[ordemDestino];

      final collectionRef = _firestore.collection(ProblemaModel.collection);

      final colRefOrigem = collectionRef.document(docOrigem.id);
      final colRefDestino = collectionRef.document(docDestino.id);

      colRefOrigem.setData({"numero": docDestino.numero}, merge: true);
      colRefDestino.setData({"numero": docOrigem.numero}, merge: true);
    }
        if (event is CreateRelatorioEvent) {
      final docRef = _firestore.collection('Relatorio').document();
      await docRef.setData({'problemaId': event.problemaId}, merge: true).then((_) {
      _state.pedidoRelatorio = docRef.documentID;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is ResetCreateRelatorioEvent) {
      _state.pedidoRelatorio = null;
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em ProblemaListBloc  = ${event.runtimeType}');
  }
}
