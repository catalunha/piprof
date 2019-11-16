import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class SimulacaoListBlocEvent {}

class GetSimulacaoEvent extends SimulacaoListBlocEvent {
  final String problemaID;

  GetSimulacaoEvent(this.problemaID);
}

class SimulacaoListBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  List<SimulacaoModel> simulacaoList = List<SimulacaoModel>();
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
      final streamDocsRemetente = _firestore
          .collection(SimulacaoModel.collection)
          .where("problema.id", isEqualTo: event.problemaID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => SimulacaoModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<SimulacaoModel> simulacaoList) {
        _state.simulacaoList.clear();
        _state.simulacaoList = simulacaoList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em SimulacaoListBloc  = ${event.runtimeType}');
  }
}
