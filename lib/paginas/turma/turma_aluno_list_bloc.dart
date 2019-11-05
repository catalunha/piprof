import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class TurmaAlunoListBlocEvent {}

class GetTurmaAlunoListEvent extends TurmaAlunoListBlocEvent {
  final String turmaID;

  GetTurmaAlunoListEvent(this.turmaID);
}

class DesativarAlunoEvent extends TurmaAlunoListBlocEvent {
  final String alunoID;

  DesativarAlunoEvent(this.alunoID);
}

class DeleteAlunoEvent extends TurmaAlunoListBlocEvent {
  final String alunoID;

  DeleteAlunoEvent(this.alunoID);
}

class AlunoNotaListEvent extends TurmaAlunoListBlocEvent {
  final String alunoID;

  AlunoNotaListEvent(this.alunoID);
}

class SaveEvent extends TurmaAlunoListBlocEvent {}

class TurmaAlunoListBlocState {
  bool isDataValid = false;
  TurmaModel turma = TurmaModel();
  List<UsuarioModel> turmaAlunoList = List<UsuarioModel>();
}

class TurmaAlunoListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TurmaAlunoListBlocEvent>();
  Stream<TurmaAlunoListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TurmaAlunoListBlocState _state = TurmaAlunoListBlocState();
  final _stateController = BehaviorSubject<TurmaAlunoListBlocState>();
  Stream<TurmaAlunoListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TurmaAlunoListBloc(this._firestore) {
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

  _mapEventToState(TurmaAlunoListBlocEvent event) async {
    if (event is GetTurmaAlunoListEvent) {
      final docRef = _firestore.collection(TurmaModel.collection).document(event.turmaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.turma = TurmaModel(id: snap.documentID).fromMap(snap.data);

        _state.turmaAlunoList.clear();

        final streamDocsRemetente = _firestore
            .collection(UsuarioModel.collection)
            // .where("ativo", isEqualTo: true)
            .where("turmaList", arrayContains: _state.turma.id)
            .where("aluno", isEqualTo: true)
            .snapshots();

        final snapListRemetente = streamDocsRemetente.map(
            (snapDocs) => snapDocs.documents.map((doc) => UsuarioModel(id: doc.documentID).fromMap(doc.data)).toList());

        snapListRemetente.listen((List<UsuarioModel> usuarioList) {
          usuarioList.sort((a, b) => a.nome.compareTo(b.nome));
          _state.turmaAlunoList = usuarioList;
          if (!_stateController.isClosed) _stateController.add(_state);
        });
      }
    }

    if (event is AlunoNotaListEvent) {
      print('Gerando csv com notas deste alunoID: ${event.alunoID}');
    }
    if (event is DesativarAlunoEvent) {
      bool statusAtual;
      for (var aluno in _state.turmaAlunoList) {
        if (aluno.id == event.alunoID) {
          statusAtual = aluno.ativo;
        }
      }
      final docRef = _firestore.collection(UsuarioModel.collection).document(event.alunoID);
      await docRef.setData({'ativo': !statusAtual}, merge: true);
    }
    if (event is DeleteAlunoEvent) {
      bool statusAtual;
      for (var aluno in _state.turmaAlunoList) {
        if (aluno.id == event.alunoID) {
          statusAtual = aluno.ativo;
        }
      }
      final docRef = _firestore.collection(UsuarioModel.collection).document(event.alunoID);
      await docRef.delete();
    }
    if (event is SaveEvent) {}

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TurmaAlunoListBloc  = ${event.runtimeType}');
  }
}
