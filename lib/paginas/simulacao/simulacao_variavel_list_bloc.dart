import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:rxdart/rxdart.dart';

class SimulacaoVariavelListBlocEvent {}

class GetSimulacaoEvent extends SimulacaoVariavelListBlocEvent {
  final String simulacaoID;

  GetSimulacaoEvent(this.simulacaoID);
}

class SimulacaoVariavelListBlocState {
  bool isDataValid = false;
  SimulacaoModel simulacao = SimulacaoModel();
}

class SimulacaoVariavelListBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoVariavelListBlocEvent>();
  Stream<SimulacaoVariavelListBlocEvent> get eventStream =>
      _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoVariavelListBlocState _state =
      SimulacaoVariavelListBlocState();
  final _stateController = BehaviorSubject<SimulacaoVariavelListBlocState>();
  Stream<SimulacaoVariavelListBlocState> get stateStream =>
      _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoVariavelListBloc(
    this._firestore,
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

  _mapEventToState(SimulacaoVariavelListBlocEvent event) async {
    if (event is GetSimulacaoEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.simulacao =
            SimulacaoModel(id: snap.documentID).fromMap(snap.data);
      }
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoVariavelListBloc  = ${event.runtimeType}');
  }
}
