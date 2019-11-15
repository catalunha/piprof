import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:queries/collections.dart';
import 'package:rxdart/rxdart.dart';

class SimulacaoGabaritoListBlocEvent {}

class GetSimulacaoEvent extends SimulacaoGabaritoListBlocEvent {
  final String simulacaoID;

  GetSimulacaoEvent(this.simulacaoID);
}

class OrdenarInMapEvent extends SimulacaoGabaritoListBlocEvent {
  final String key;
  final bool up;

  OrdenarInMapEvent(this.key, this.up);
}

class SimulacaoGabaritoListBlocState {
  bool isDataValid = false;
  SimulacaoModel simulacao = SimulacaoModel();
  Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();
  void updateState() {
    if (simulacao.gabarito != null) {
      gabaritoMap.clear();
      var dic = Dictionary.fromMap(simulacao.gabarito);
      var dicOrderBy = dic
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      gabaritoMap = dicOrderBy.toMap();
    }
  }
}

class SimulacaoGabaritoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoGabaritoListBlocEvent>();
  Stream<SimulacaoGabaritoListBlocEvent> get eventStream =>
      _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoGabaritoListBlocState _state = SimulacaoGabaritoListBlocState();
  final _stateController = BehaviorSubject<SimulacaoGabaritoListBlocState>();
  Stream<SimulacaoGabaritoListBlocState> get stateStream =>
      _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoGabaritoListBloc(
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
    if (_state.simulacao.gabarito == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoGabaritoListBlocEvent event) async {
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
      List<Gabarito> valuesList = _state.gabaritoMap.values.toList();
      List<String> keysList = _state.gabaritoMap.keys.toList();
      final ordemOrigem = keysList.indexOf(event.key);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;

      Gabarito objOrigem = valuesList[ordemOrigem];
      Gabarito objDestino = valuesList[ordemDestino];
      String keyOrigem = keysList[ordemOrigem];
      String keyDestino = keysList[ordemDestino];

      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);

      docRef.setData({
        "gabarito": {
          "$keyOrigem": {"ordem": objDestino.ordem}
        }
      }, merge: true);

      docRef.setData({
        "gabarito": {
          "$keyDestino": {"ordem": objOrigem.ordem}
        }
      }, merge: true);
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoGabaritoListBloc  = ${event.runtimeType}');
  }
}
