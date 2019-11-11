import 'package:piprof/modelos/pasta_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class SituacaoSelecionarBlocEvent {}

class GetUsuarioAuthEvent extends SituacaoSelecionarBlocEvent {
  final UsuarioModel usuarioAuth;
  GetUsuarioAuthEvent(this.usuarioAuth);
}

class UpdatePastaListEvent extends SituacaoSelecionarBlocEvent {}

class UpdateSituacaoListEvent extends SituacaoSelecionarBlocEvent {
  final String pastaID;

  UpdateSituacaoListEvent(this.pastaID);
}
class SelecionarPastaEvent extends SituacaoSelecionarBlocEvent {
  final PastaModel pasta;

  SelecionarPastaEvent(this.pasta);
}
class SelecionarSituacaoEvent extends SituacaoSelecionarBlocEvent {
  final SituacaoModel situacao;

  SelecionarSituacaoEvent(this.situacao);
}
class RemoverPastaEvent extends SituacaoSelecionarBlocEvent {}

class SituacaoSelecionarBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;

PastaModel pasta;
SituacaoModel situacao;
  List<PastaModel> pastaList = List<PastaModel>();
  List<SituacaoModel> situacaoList = List<SituacaoModel>();
}

class SituacaoSelecionarBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<SituacaoSelecionarBlocEvent>();
  Stream<SituacaoSelecionarBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SituacaoSelecionarBlocState _state = SituacaoSelecionarBlocState();
  final _stateController = BehaviorSubject<SituacaoSelecionarBlocState>();
  Stream<SituacaoSelecionarBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SituacaoSelecionarBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
      eventSink(UpdatePastaListEvent());
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
  }

  _mapEventToState(SituacaoSelecionarBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is UpdatePastaListEvent) {
      _state.pastaList.clear();

      final streamDocsRemetente = _firestore
          .collection(PastaModel.collection)
          .where("professor.id", isEqualTo: _state.usuarioAuth.id)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => PastaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<PastaModel> pastaList) {
        pastaList.sort((a, b) => a.numero.compareTo(b.numero));

        _state.pastaList = pastaList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is UpdateSituacaoListEvent) {
      _state.situacaoList.clear();

      final streamDocsRemetente = _firestore
          .collection(SituacaoModel.collection)
          .where("ativo", isEqualTo: true)
          .where("pasta.id", isEqualTo: event.pastaID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => SituacaoModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<SituacaoModel> situacaoList) {
        situacaoList.sort((a, b) => a.numero.compareTo(b.numero));

        _state.situacaoList = situacaoList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is SelecionarPastaEvent) {
      _state.pasta = event.pasta;
      eventSink(UpdateSituacaoListEvent(_state.pasta.id));
    }
    if (event is RemoverPastaEvent) {
      _state.pasta = null;
    }
    if (event is SelecionarSituacaoEvent) {
      _state.situacao = event.situacao;
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em SituacaoSelecionarBloc  = ${event.runtimeType}');
  }
}
