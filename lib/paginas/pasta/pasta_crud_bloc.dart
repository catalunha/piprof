import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:rxdart/rxdart.dart';

class PastaCRUDBlocEvent {}

class GetUsuarioAuthEvent extends PastaCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetPastaEvent extends PastaCRUDBlocEvent {
  final String pastaID;

  GetPastaEvent(this.pastaID);
}

class UpdateTextFieldEvent extends PastaCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class SaveEvent extends PastaCRUDBlocEvent {}

class DeleteDocumentEvent extends PastaCRUDBlocEvent {}

class PastaCRUDBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;
  String pastaID;
  PastaModel pasta = PastaModel();

  String nome;
  String descricao;

  void updateState() {
    nome = pasta.nome;
    descricao = pasta.descricao;
  }
}

class PastaCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<PastaCRUDBlocEvent>();
  Stream<PastaCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final PastaCRUDBlocState _state = PastaCRUDBlocState();
  final _stateController = BehaviorSubject<PastaCRUDBlocState>();
  Stream<PastaCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  PastaCRUDBloc(this._firestore, this._authBloc) {
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
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(PastaCRUDBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetPastaEvent) {
      final docRef =
          _firestore.collection(PastaModel.collection).document(event.pastaID);
      _state.pastaID = event.pastaID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.pasta = PastaModel(id: snap.documentID).fromMap(snap.data);
        _state.updateState();
      }
    }

    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'descricao') {
        _state.descricao = event.texto;
      }
    }

    if (event is SaveEvent) {
      final docRef =
          _firestore.collection(PastaModel.collection).document(_state.pastaID);

      PastaModel pastaModel = PastaModel(
        nome: _state.nome,
        descricao: _state.descricao,
      );
      if (_state.pastaID == null) {
        pastaModel.numero = _state.usuarioAuth.pastaNumeroAdicionado ?? 0 + 1;
        // +++ Atualizar usuario com mais uma pasta em seu cadastro
        final usuarioDocRef = _firestore
            .collection(UsuarioModel.collection)
            .document(_state.usuarioAuth.id);
        await usuarioDocRef.setData({
          'pastaNumeroAdicionado': Bootstrap.instance.fieldValue.increment(1),
        }, merge: true);
        // ---
        pastaModel.professor =
            UsuarioFk(id: _state.usuarioAuth.id, nome: _state.usuarioAuth.nome);
      }
      await docRef.setData(pastaModel.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(PastaModel.collection)
          .document(_state.pasta.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em PastaCRUDBloc  = ${event.runtimeType}');
  }
}
