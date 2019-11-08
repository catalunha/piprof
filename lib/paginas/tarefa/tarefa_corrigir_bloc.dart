import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:queries/collections.dart';
import 'package:rxdart/rxdart.dart';

class TarefaCorrigirBlocEvent {}

class GetTarefaEvent extends TarefaCorrigirBlocEvent {
  final String tarefaID;

  GetTarefaEvent(this.tarefaID);
}

class UpdatePedeseNotaEvent extends TarefaCorrigirBlocEvent {
  final String key;

  UpdatePedeseNotaEvent(this.key);
}

class SaveEvent extends TarefaCorrigirBlocEvent {}

class PedeseInfo {
  final Pedese pedese;
  bool nota;
  PedeseInfo({this.pedese, this.nota});
}

class TarefaCorrigirBlocState {
  bool isDataValid = false;
  TarefaModel tarefa = TarefaModel();
  Map<String, PedeseInfo> pedeseInfoMap = Map<String, PedeseInfo>();
  void updateState() {
    // bool nota;
    for (var pedese in tarefa.pedese.entries) {
      // nota = false;
      pedeseInfoMap[pedese.key] = PedeseInfo(
        pedese: pedese.value,
        nota: pedese.value.nota == null || pedese.value.nota == 0 ? false : true,
      );
    }
    Map<String, Variavel> variavelMap;
    var dic = Dictionary.fromMap(pedeseInfoMap);
    var dicOrderBy = dic.orderBy((kv) => kv.value.pedese.ordem).toDictionary$1((kv) => kv.key, (kv) => kv.value);
    pedeseInfoMap = dicOrderBy.toMap();
  }
}

class TarefaCorrigirBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TarefaCorrigirBlocEvent>();
  Stream<TarefaCorrigirBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TarefaCorrigirBlocState _state = TarefaCorrigirBlocState();
  final _stateController = BehaviorSubject<TarefaCorrigirBlocState>();
  Stream<TarefaCorrigirBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TarefaCorrigirBloc(this._firestore) {
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

  _mapEventToState(TarefaCorrigirBlocEvent event) async {
    if (event is GetTarefaEvent) {
      if (event.tarefaID != null) {
        final docRef = _firestore.collection(TarefaModel.collection).document(event.tarefaID);
        final snap = await docRef.get();
        if (snap.exists) {
          _state.tarefa = TarefaModel(id: snap.documentID).fromMap(snap.data);
          _state.updateState();
        }
      }
    }
    if (event is UpdatePedeseNotaEvent) {
      _state.pedeseInfoMap[event.key].nota = !_state.pedeseInfoMap[event.key].nota;
      if (_state.pedeseInfoMap[event.key].nota) {
        _state.pedeseInfoMap[event.key].pedese.nota = 1;
      } else {
        _state.pedeseInfoMap[event.key].pedese.nota = 0;
      }
    }

    if (event is SaveEvent) {}

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TarefaAlunoList  = ${event.runtimeType}');
  }
}
