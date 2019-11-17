import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:queries/collections.dart';
import 'package:rxdart/rxdart.dart';

class TarefaCorrigirBlocEvent {}

class GetTarefaEvent extends TarefaCorrigirBlocEvent {
  final String tarefaID;

  GetTarefaEvent(this.tarefaID);
}

class UpdateGabaritoNotaEvent extends TarefaCorrigirBlocEvent {
  final String key;

  UpdateGabaritoNotaEvent(this.key);
}

class SaveEvent extends TarefaCorrigirBlocEvent {}

//TODO: retirar esta estrutura de GabaritoInfo e usar o padrao gabarito verificando o null e 0 no page
class GabaritoInfo {
  final Gabarito gabarito;
  bool nota;
  GabaritoInfo({this.gabarito, this.nota});
}

class TarefaCorrigirBlocState {
  bool isDataValid = false;
  TarefaModel tarefa = TarefaModel();
  Map<String, GabaritoInfo> gabaritoInfoMap = Map<String, GabaritoInfo>();
  void updateState() {
    // bool nota;
    for (var gabarito in tarefa.gabarito.entries) {
      // nota = false;
      gabaritoInfoMap[gabarito.key] = GabaritoInfo(
        gabarito: gabarito.value,
        nota: gabarito.value.nota == null || gabarito.value.nota == 0
            ? false
            : true,
      );
    }
    var dic = Dictionary.fromMap(gabaritoInfoMap);
    var dicOrderBy = dic
        .orderBy((kv) => kv.value.gabarito.ordem)
        .toDictionary$1((kv) => kv.key, (kv) => kv.value);
    gabaritoInfoMap = dicOrderBy.toMap();
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
        // final docRef = _firestore
        //     .collection(TarefaModel.collection)
        //     .document(event.tarefaID);
        // final snap = await docRef.get();
        // if (snap.exists) {
        //   _state.tarefa = TarefaModel(id: snap.documentID).fromMap(snap.data);
        //   _state.updateState();
        // }

        final streamDocsRemetente = _firestore
            .collection(TarefaModel.collection)
            .document(event.tarefaID)
            .snapshots();

        final snapListRemetente = streamDocsRemetente
            .map((doc) => TarefaModel(id: doc.documentID).fromMap(doc.data));

        snapListRemetente.listen((TarefaModel tarefa) {
          _state.tarefa = tarefa;
          if (!_stateController.isClosed) _stateController.add(_state);
          _state.updateState();
        });
      }
    }
    if (event is UpdateGabaritoNotaEvent) {
      _state.gabaritoInfoMap[event.key].nota =
          !_state.gabaritoInfoMap[event.key].nota;
      if (_state.gabaritoInfoMap[event.key].nota) {
        _state.gabaritoInfoMap[event.key].gabarito.nota = 1;
      } else {
        _state.gabaritoInfoMap[event.key].gabarito.nota = 0;
      }
    }

    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(TarefaModel.collection)
          .document(_state.tarefa.id);
      Map<String, Gabarito> gabarito = Map<String, Gabarito>();
      for (var gabaritoInfoMap in _state.gabaritoInfoMap.entries) {
        gabarito[gabaritoInfoMap.key] = gabaritoInfoMap.value.gabarito;
      }
      TarefaModel tarefaUpdate = TarefaModel(
        gabarito: gabarito,
      );
      await docRef.setData(tarefaUpdate.toMap(), merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TarefaAlunoList  = ${event.runtimeType}');
  }
}
