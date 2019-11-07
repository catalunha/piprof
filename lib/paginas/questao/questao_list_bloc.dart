import 'package:piprof/modelos/questao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class QuestaoListBlocEvent {}

class UpdateQuestaoListEvent extends QuestaoListBlocEvent {
    final String avaliacaoID;

  UpdateQuestaoListEvent(this.avaliacaoID);

}
class OrdenarEvent extends QuestaoListBlocEvent {
  final QuestaoModel obj;
  final bool up;

  OrdenarEvent(this.obj, this.up);
}

class QuestaoListBlocState {
  bool isDataValid = false;
  List<QuestaoModel> questaoList = List<QuestaoModel>();
}

class QuestaoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<QuestaoListBlocEvent>();
  Stream<QuestaoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final QuestaoListBlocState _state = QuestaoListBlocState();
  final _stateController = BehaviorSubject<QuestaoListBlocState>();
  Stream<QuestaoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  QuestaoListBloc(this._firestore) {
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

  _mapEventToState(QuestaoListBlocEvent event) async {


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
                        if (questaoList.length > 1) {
          questaoList
              .sort((a, b) => a.numero.compareTo(b.numero));
        }
        _state.questaoList = questaoList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is OrdenarEvent) {
      final ordemOrigem = _state.questaoList.indexOf(event.obj);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;
      QuestaoModel docOrigem = _state.questaoList[ordemOrigem];
      QuestaoModel docDestino = _state.questaoList[ordemDestino];

      final collectionRef = _firestore.collection(QuestaoModel.collection);

      final colRefOrigem = collectionRef.document(docOrigem.id);
      final colRefDestino = collectionRef.document(docDestino.id);

      colRefOrigem.setData({"numero": docDestino.numero}, merge: true);
      colRefDestino.setData({"numero": docOrigem.numero}, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em QuestaoListBloc  = ${event.runtimeType}');
  }
}
