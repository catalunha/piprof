import 'package:piprof/modelos/pasta_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class ProblemaSelecionarBlocEvent {}

class GetUsuarioAuthEvent extends ProblemaSelecionarBlocEvent {
  final UsuarioModel usuarioAuth;
  GetUsuarioAuthEvent(this.usuarioAuth);
}

class UpdatePastaListEvent extends ProblemaSelecionarBlocEvent {}

class UpdateProblemaListEvent extends ProblemaSelecionarBlocEvent {
  final String pastaID;

  UpdateProblemaListEvent(this.pastaID);
}
class SelecionarPastaEvent extends ProblemaSelecionarBlocEvent {
  final PastaModel pasta;

  SelecionarPastaEvent(this.pasta);
}
class SelecionarProblemaEvent extends ProblemaSelecionarBlocEvent {
  final ProblemaModel problema;

  SelecionarProblemaEvent(this.problema);
}
class RemoverPastaEvent extends ProblemaSelecionarBlocEvent {}

class ProblemaSelecionarBlocState {
  bool isDataValid = false;
  UsuarioModel usuarioAuth;

PastaModel pasta;
ProblemaModel problema;
  List<PastaModel> pastaList = List<PastaModel>();
  List<ProblemaModel> problemaList = List<ProblemaModel>();
}

class ProblemaSelecionarBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<ProblemaSelecionarBlocEvent>();
  Stream<ProblemaSelecionarBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final ProblemaSelecionarBlocState _state = ProblemaSelecionarBlocState();
  final _stateController = BehaviorSubject<ProblemaSelecionarBlocState>();
  Stream<ProblemaSelecionarBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  ProblemaSelecionarBloc(this._firestore, this._authBloc) {
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

  _mapEventToState(ProblemaSelecionarBlocEvent event) async {
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

    if (event is UpdateProblemaListEvent) {
      _state.problemaList.clear();

      final streamDocsRemetente = _firestore
          .collection(ProblemaModel.collection)
          .where("ativo", isEqualTo: true)
          .where("pasta.id", isEqualTo: event.pastaID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente.map((snapDocs) => snapDocs
          .documents
          .map((doc) => ProblemaModel(id: doc.documentID).fromMap(doc.data))
          .toList());

      snapListRemetente.listen((List<ProblemaModel> problemaList) {
        problemaList.sort((a, b) => a.numero.compareTo(b.numero));

        _state.problemaList = problemaList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }

    if (event is SelecionarPastaEvent) {
      _state.pasta = event.pasta;
      eventSink(UpdateProblemaListEvent(_state.pasta.id));
    }
    if (event is RemoverPastaEvent) {
      _state.pasta = null;
    }
    if (event is SelecionarProblemaEvent) {
      _state.problema = event.problema;
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em ProblemaSelecionarBloc  = ${event.runtimeType}');
  }
}
