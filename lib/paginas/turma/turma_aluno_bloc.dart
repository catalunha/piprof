import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class TurmaAlunoBlocEvent {}

class GetTurmaEvent extends TurmaAlunoBlocEvent {
  final String turmaID;

  GetTurmaEvent(this.turmaID);
}

class GetCadastrarAlunoEvent extends TurmaAlunoBlocEvent {
  final String cadastro;

  GetCadastrarAlunoEvent(this.cadastro);
}

class NotaListEvent extends TurmaAlunoBlocEvent {
  final String turmaID;

  NotaListEvent(this.turmaID);
}

class SaveEvent extends TurmaAlunoBlocEvent {}

class TurmaAlunoBlocState {
  bool isDataValid = false;
  TurmaModel turma = TurmaModel();

  String cadastro;
}

class TurmaAlunoBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  // final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TurmaAlunoBlocEvent>();
  Stream<TurmaAlunoBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TurmaAlunoBlocState _state = TurmaAlunoBlocState();
  final _stateController = BehaviorSubject<TurmaAlunoBlocState>();
  Stream<TurmaAlunoBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TurmaAlunoBloc(this._firestore) {
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

  _mapEventToState(TurmaAlunoBlocEvent event) async {
    if (event is GetTurmaEvent) {
      final docRef = _firestore.collection(TurmaModel.collection).document(event.turmaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.turma = TurmaModel(id: snap.documentID).fromMap(snap.data);
      }
    }

    if (event is NotaListEvent) {
      print('Gerando csv com lista de alunos da turmaID: ${event.turmaID}');
    }
    if (event is GetCadastrarAlunoEvent) {}
    if (event is SaveEvent) {}

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TurmaAlunoBloc  = ${event.runtimeType}');
  }
}
