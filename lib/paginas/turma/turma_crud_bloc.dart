import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class TurmaCRUDBlocEvent {}

class GetUsuarioAuthEvent extends TurmaCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetTurmaEvent extends TurmaCRUDBlocEvent {
  final String turmaID;

  GetTurmaEvent(this.turmaID);
}

class UpdateAtivoEvent extends TurmaCRUDBlocEvent {
  final bool ativo;
  UpdateAtivoEvent(this.ativo);
}

class UpdateTextFieldEvent extends TurmaCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class SaveEvent extends TurmaCRUDBlocEvent {}

class DeleteDocumentEvent extends TurmaCRUDBlocEvent {}

class TurmaCRUDBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  String turmaID;
  TurmaModel turma = TurmaModel();

  bool ativo = true;
  String instituicao;
  String componente;
  String nome;
  String descricao;
  String programa;

  void updateState() {
    ativo = turma.ativo;
    instituicao = turma.instituicao;
    componente = turma.componente;
    nome = turma.nome;
    descricao = turma.descricao;
    programa = turma.programa;
  }
}

class TurmaCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<TurmaCRUDBlocEvent>();
  Stream<TurmaCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TurmaCRUDBlocState _state = TurmaCRUDBlocState();
  final _stateController = BehaviorSubject<TurmaCRUDBlocState>();
  Stream<TurmaCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TurmaCRUDBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
    });
  }

  void dispose() async {
    await _stateController.drain();
    _stateController.close();
    await _eventController.drain();
    _eventController.close();
  }

  _validateData() {
    _state.isDataValid = true;
    if (_state.instituicao == null) {
      _state.isDataValid = false;
    }
    if (_state.componente == null) {
      _state.isDataValid = false;
    }
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(TurmaCRUDBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetTurmaEvent) {
      final docRef =
          _firestore.collection(TurmaModel.collection).document(event.turmaID);
      _state.turmaID = event.turmaID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.turma = TurmaModel(id: snap.documentID).fromMap(snap.data);
        _state.updateState();
      }
    }

    if (event is UpdateAtivoEvent) {
      _state.ativo = event.ativo;
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'instituicao') {
        _state.instituicao = event.texto;
      } else if (event.campo == 'componente') {
        _state.componente = event.texto;
      } else if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'descricao') {
        _state.descricao = event.texto;
      } else if (event.campo == 'programa') {
        _state.programa = event.texto;
      }
    }
    if (event is SaveEvent) {
      final docRef =
          _firestore.collection(TurmaModel.collection).document(_state.turmaID);

      TurmaModel turmaModel = TurmaModel(
        ativo: _state.ativo,
        instituicao: _state.instituicao,
        componente: _state.componente,
        nome: _state.nome,
        descricao: _state.descricao,
        programa: _state.programa,
      );
      if (_state.turmaID == null) {
        turmaModel.questaoNumero = 0;
        turmaModel.numero = (_state.usuarioAuth.turmaNumero ?? 0) + 1;
        turmaModel.professor =
            UsuarioFk(id: _state.usuarioAuth.id, nome: _state.usuarioAuth.nome);
      }
      await docRef.setData(turmaModel.toMap(), merge: true).then((_) async {
        if (_state.turmaID == null) {
          //+++ Atualizar usuario com mais uma turma em seu cadastro
          final usuarioDocRef = _firestore
              .collection(UsuarioModel.collection)
              .document(_state.usuarioAuth.id);
          await usuarioDocRef.setData({
            'turmaNumero': Bootstrap.instance.fieldValue.increment(1),
          }, merge: true);
          //---

        }
      });
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(TurmaModel.collection)
          .document(_state.turma.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TurmaCRUDBloc  = ${event.runtimeType}');
  }
}
