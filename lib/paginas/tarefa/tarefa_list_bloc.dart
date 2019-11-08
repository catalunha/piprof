import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:rxdart/rxdart.dart';

class TarefaListBlocEvent {}

class GetTarefaListPorQuestaoEvent extends TarefaListBlocEvent {
  final String questaoID;

  GetTarefaListPorQuestaoEvent(this.questaoID);
}

class TarefaListBlocState {
  bool isDataValid = false;
  List<TarefaModel> tarefaList = List<TarefaModel>();
}

class TarefaListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TarefaListBlocEvent>();
  Stream<TarefaListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TarefaListBlocState _state = TarefaListBlocState();
  final _stateController = BehaviorSubject<TarefaListBlocState>();
  Stream<TarefaListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TarefaListBloc(this._firestore) {
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

  _mapEventToState(TarefaListBlocEvent event) async {
    if (event is GetTarefaListPorQuestaoEvent) {
        _state.tarefaList.clear();

        final streamDocsRemetente = _firestore
            .collection(TarefaModel.collection)
            .where("questao.id", isEqualTo: event.questaoID)
            .snapshots();

        final snapListRemetente = streamDocsRemetente.map(
            (snapDocs) => snapDocs.documents.map((doc) => TarefaModel(id: doc.documentID).fromMap(doc.data)).toList());

        snapListRemetente.listen((List<TarefaModel> tarefaList) {
          tarefaList.sort((a, b) => a.aluno.nome.compareTo(b.aluno.nome));
          _state.tarefaList = tarefaList;
          if (!_stateController.isClosed) _stateController.add(_state);
        });
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TarefaAlunoList  = ${event.runtimeType}');
  }
}
