import 'package:piprof/modelos/questao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class PastaSituacaoListBlocEvent {}
class GetUsuarioAuthEvent extends TarefaListBlocEvent {
  final UsuarioModel usuarioAuth;
  GetUsuarioAuthEvent(this.usuarioAuth);
}
class UpdatePastaListEvent extends PastaSituacaoListBlocEvent {
    final String avaliacaoID;

  UpdateQuestaoListEvent(this.avaliacaoID);

}
class UpdateSituacaoListEvent extends PastaSituacaoListBlocEvent {
    final String avaliacaoID;

  UpdateQuestaoListEvent(this.avaliacaoID);

}

class PastaSituacaoListBlocState {
  bool isDataValid = false;
  List<QuestaoModel> questaoList = List<QuestaoModel>();
}

class PastaSituacaoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<PastaSituacaoListBlocEvent>();
  Stream<PastaSituacaoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final PastaSituacaoListBlocState _state = PastaSituacaoListBlocState();
  final _stateController = BehaviorSubject<PastaSituacaoListBlocState>();
  Stream<PastaSituacaoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  PastaSituacaoListBloc(this._firestore) {
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

  _mapEventToState(PastaSituacaoListBlocEvent event) async {


    if (event is UpdateQuestaoListEvent) {
      _state.questaoList.clear();

      final streamDocsRemetente = _firestore
          .collection(QuestaoModel.collection)
          .where("ativo", isEqualTo: true)
          .where("avaliacao.id", isEqualTo: event.avaliacaoID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => QuestaoModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<QuestaoModel> questaoList) {
        _state.questaoList = questaoList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em PastaSituacaoListBloc  = ${event.runtimeType}');
  }
}
