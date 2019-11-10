import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:queries/collections.dart';
import 'package:rxdart/rxdart.dart';

class SimulacaoVariavelListBlocEvent {}

class GetSimulacaoEvent extends SimulacaoVariavelListBlocEvent {
  final String simulacaoID;

  GetSimulacaoEvent(this.simulacaoID);
}

class OrdenarInMapEvent extends SimulacaoVariavelListBlocEvent {
  final String key;
  final bool up;

  OrdenarInMapEvent(this.key, this.up);
}

class SimulacaoVariavelListBlocState {
  bool isDataValid = false;
  SimulacaoModel simulacao = SimulacaoModel();
  Map<String, Variavel> variavelMap = Map<String, Variavel>();
  void updateState() {
    variavelMap.clear();
    var dic = Dictionary.fromMap(simulacao.variavel);
    var dicOrderBy = dic
        .orderBy((kv) => kv.value.ordem)
        .toDictionary$1((kv) => kv.key, (kv) => kv.value);
    variavelMap = dicOrderBy.toMap();
  }
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
    if (_state.simulacao.variavel == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoVariavelListBlocEvent event) async {
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
      // final docRef = _firestore
      //     .collection(SimulacaoModel.collection)
      //     .document(event.simulacaoID);

      // final snap = await docRef.get();
      // if (snap.exists) {
      //   _state.simulacao =
      //       SimulacaoModel(id: snap.documentID).fromMap(snap.data);
      // }
    }
    if (event is OrdenarInMapEvent) {
  
      List<Variavel> valuesList = _state.variavelMap.values.toList();
      List<String> keysList = _state.variavelMap.keys.toList();
      final ordemOrigem = keysList.indexOf(event.key);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;

      Variavel objOrigem = valuesList[ordemOrigem];
      Variavel objDestino = valuesList[ordemDestino];
      String keyOrigem = keysList[ordemOrigem];
      String keyDestino = keysList[ordemDestino];

      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);

      docRef.setData({
        "variavel": {
          "$keyOrigem": {"ordem": objDestino.ordem}
        }
      }, merge: true);

      docRef.setData({
        "variavel": {
          "$keyDestino": {"ordem": objOrigem.ordem}
        }
      }, merge: true);

    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoVariavelListBloc  = ${event.runtimeType}');
  }
}
