import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/questao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:rxdart/rxdart.dart';

class QuestaoListBlocEvent {}

class GetAvaliacaoEvent extends QuestaoListBlocEvent {
  final String avaliacaoID;

  GetAvaliacaoEvent(this.avaliacaoID);
}

class UpdateQuestaoListEvent extends QuestaoListBlocEvent {
  final String avaliacaoID;

  UpdateQuestaoListEvent(this.avaliacaoID);
}

class OrdenarEvent extends QuestaoListBlocEvent {
  final QuestaoModel obj;
  final bool up;

  OrdenarEvent(this.obj, this.up);
}

class ResetTempoTentativaQuestaEvent extends QuestaoListBlocEvent {
  final String questaoID;
  final bool aplicada;

  ResetTempoTentativaQuestaEvent(this.questaoID, this.aplicada);
}

class QuestaoListBlocState {
  bool isDataValid = false;
  AvaliacaoModel avaliacao = AvaliacaoModel();

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
    if (event is GetAvaliacaoEvent) {
      final docRef = _firestore
          .collection(AvaliacaoModel.collection)
          .document(event.avaliacaoID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.avaliacao =
            AvaliacaoModel(id: snap.documentID).fromMap(snap.data);
      }
    }
    if (event is UpdateQuestaoListEvent) {
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
          questaoList.sort((a, b) => a.numero.compareTo(b.numero));
        }
        _state.questaoList.clear();
        _state.questaoList = questaoList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is ResetTempoTentativaQuestaEvent) {
      if (event.aplicada) {
        //+++ Atualizar tarefa resetando tempo e tentativa desta questao
        final futureQuerySnapshot = await _firestore
            .collection(TarefaModel.collection)
            .where("questao.id", isEqualTo: event.questaoID)
            .getDocuments();
        var tarefaList = futureQuerySnapshot.documents
            .map((doc) => TarefaModel(id: doc.documentID).fromMap(doc.data))
            .toList();
        for (var tarefa in tarefaList) {
          //+++ Atualizar turma com mais uma questao
          final tarefaDocRef =
              _firestore.collection(TarefaModel.collection).document(tarefa.id);
          await tarefaDocRef.setData({
            'tentou': 0,
            'iniciou': null,
            'enviou': null,
          }, merge: true);
          //---
        }
      }
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
