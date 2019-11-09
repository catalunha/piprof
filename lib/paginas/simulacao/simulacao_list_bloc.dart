import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class SimulacaoListBlocEvent {}


class GetSimulacaoEvent extends SimulacaoListBlocEvent {
  final String situacaoID;

  GetSimulacaoEvent(this.situacaoID);

}

class SimulacaoListBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  List<SimulacaoModel> pastaList = List<PastaModel>();
}

class SimulacaoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoListBlocEvent>();
  Stream<SimulacaoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoListBlocState _state = SimulacaoListBlocState();
  final _stateController = BehaviorSubject<SimulacaoListBlocState>();
  Stream<SimulacaoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoListBloc(
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

  _mapEventToState(SimulacaoListBlocEvent event) async {

    if (event is GetSimulacaoEvent) {
      _state.pastaList.clear();

      final streamDocsRemetente = _firestore
          .collection(PastaModel.collection)
          .where("situacao.id", isEqualTo: event.situacaoID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => PastaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<PastaModel> pastaList) {
        pastaList.sort((a, b) => a.numero.compareTo(b.numero));
        _state.pastaList = pastaList;
        // print(_state.pastaList);
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em PastaList  = ${event.runtimeType}');
  }
}