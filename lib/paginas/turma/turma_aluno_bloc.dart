import 'package:piprof/modelos/turma_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class TurmaAlunoBlocEvent {}

class GetTurmaEvent extends TurmaAlunoBlocEvent {
  final String turmaID;

  GetTurmaEvent(this.turmaID);
}

class UpdateCadastroAlunoEvent extends TurmaAlunoBlocEvent {
  final String cadastro;

  UpdateCadastroAlunoEvent(this.cadastro);
}

class NotaListEvent extends TurmaAlunoBlocEvent {
  final String turmaID;

  NotaListEvent(this.turmaID);
}

class SaveEvent extends TurmaAlunoBlocEvent {}

class CadastrarAlunoEvent extends TurmaAlunoBlocEvent {}

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
    if (event is UpdateCadastroAlunoEvent) {
      _state.cadastro = event.cadastro.trim();
    }
    if (event is CadastrarAlunoEvent) {
      String cadastro = _state.cadastro;
      String matricula;
      String email;
      String nome;

      if (cadastro != null) {
        // print('::cadastro::');
        // print(cadastro);
        List<String> linhas = cadastro.split('\n');
        // print('::linhas::');
        // print(linhas);
        for (var linha in linhas) {
          // print('::linha::');
          // print(linha);
          if (linha != null) {
            List<String> campos = linha.trim().split(';');
            // print('::campos::');
            // print(campos);
            if (campos != null &&
                campos.length == 3 &&
                campos[0] != null &&
                campos[0].length >= 3 &&
                campos[1] != null &&
                campos[1].length >= 10 &&
                campos[1].contains('@') &&
                campos[2] != null &&
                campos[2].length >= 10) {
              matricula = campos[0].trim();
              email = campos[1].trim();
              nome = campos[2].trim();
              print('::matricula::$matricula');
              print('::email::$email');
              print('::nome::$nome');
              UsuarioModel usuarioModel = UsuarioModel(
                  professor: false,
                  ativo: true,
                  email: email,
                  matricula: matricula,
                  nome: nome,
                  rota: ['/', '/perfil', '/upload', '/versao', '/turma/list'],
                  turmaList: [_state.turma.id]
                  );

              final docRef = _firestore.collection('UsuarioNovo').document();
              await docRef.setData(usuarioModel.toMap(), merge: true);
            }
          }
        }
      }
    }
    if (event is SaveEvent) {}

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TurmaAlunoBloc  = ${event.runtimeType}');
  }
}
