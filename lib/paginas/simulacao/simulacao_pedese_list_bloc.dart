import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:queries/collections.dart';
import 'package:rxdart/rxdart.dart';

class SimulacaoPedeseListBlocEvent {}

class GetSimulacaoEvent extends SimulacaoPedeseListBlocEvent {
  final String simulacaoID;

  GetSimulacaoEvent(this.simulacaoID);
}

class OrdenarInMapEvent extends SimulacaoPedeseListBlocEvent {
  final String key;
  final bool up;

  OrdenarInMapEvent(this.key, this.up);
}

class SimulacaoPedeseListBlocState {
  bool isDataValid = false;
  SimulacaoModel simulacao = SimulacaoModel();
  Map<String, Pedese> pedeseMap = Map<String, Pedese>();
  void updateState() {
    if (simulacao.pedese != null) {
      pedeseMap.clear();
      var dic = Dictionary.fromMap(simulacao.pedese);
      var dicOrderBy = dic
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      pedeseMap = dicOrderBy.toMap();
    }
  }
}

class SimulacaoPedeseListBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoPedeseListBlocEvent>();
  Stream<SimulacaoPedeseListBlocEvent> get eventStream =>
      _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoPedeseListBlocState _state = SimulacaoPedeseListBlocState();
  final _stateController = BehaviorSubject<SimulacaoPedeseListBlocState>();
  Stream<SimulacaoPedeseListBlocState> get stateStream =>
      _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoPedeseListBloc(
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
    if (_state.simulacao.pedese == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoPedeseListBlocEvent event) async {
    if (event is GetSimulacaoEvent) {
      final streamDocsRemetente = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente
          .map((doc) => SimulacaoModel(id: doc.documentID).fromMap(doc.data));

      snapListRemetente.listen((SimulacaoModel simulacaoModel) {
        _state.simulacao = simulacaoModel;
        _state.updateState();
        if (!_stateController.isClosed) _stateController.add(_state);
        _validateData();
      });
    }
    if (event is OrdenarInMapEvent) {
      List<Pedese> valuesList = _state.pedeseMap.values.toList();
      List<String> keysList = _state.pedeseMap.keys.toList();
      final ordemOrigem = keysList.indexOf(event.key);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;

      Pedese objOrigem = valuesList[ordemOrigem];
      Pedese objDestino = valuesList[ordemDestino];
      String keyOrigem = keysList[ordemOrigem];
      String keyDestino = keysList[ordemDestino];

      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);

      docRef.setData({
        "pedese": {
          "$keyOrigem": {"ordem": objDestino.ordem}
        }
      }, merge: true);

      docRef.setData({
        "pedese": {
          "$keyDestino": {"ordem": objOrigem.ordem}
        }
      }, merge: true);
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoPedeseListBloc  = ${event.runtimeType}');
  }
}
