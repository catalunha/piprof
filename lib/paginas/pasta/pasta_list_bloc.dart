import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class PastaListBlocEvent {}

class GetUsuarioAuthEvent extends PastaListBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetPastaEvent extends PastaListBlocEvent {}

class OrdenarEvent extends PastaListBlocEvent {
  final PastaModel obj;
  final bool up;

  OrdenarEvent(this.obj, this.up);
}

class CreateRelatorioEvent extends PastaListBlocEvent {
  final String pastaId;

  CreateRelatorioEvent(this.pastaId);
}

class ResetCreateRelatorioEvent extends PastaListBlocEvent {}

class PastaListBlocState {
  bool isDataValid = false;
  List<PastaModel> pastaList = List<PastaModel>();
  UsuarioModel usuarioAuth;
  String pedidoRelatorio;
}

class PastaListBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<PastaListBlocEvent>();
  Stream<PastaListBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final PastaListBlocState _state = PastaListBlocState();
  final _stateController = BehaviorSubject<PastaListBlocState>();
  Stream<PastaListBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  PastaListBloc(
    this._firestore,
    this._authBloc,
  ) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
      eventSink(GetPastaEvent());
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

  _mapEventToState(PastaListBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetPastaEvent) {
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
        _state.pastaList.clear();
        _state.pastaList = pastaList;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is OrdenarEvent) {
      final ordemOrigem = _state.pastaList.indexOf(event.obj);
      final ordemDestino = event.up ? ordemOrigem - 1 : ordemOrigem + 1;
      PastaModel docOrigem = _state.pastaList[ordemOrigem];
      PastaModel docDestino = _state.pastaList[ordemDestino];

      final collectionRef = _firestore.collection(PastaModel.collection);

      final colRefOrigem = collectionRef.document(docOrigem.id);
      final colRefDestino = collectionRef.document(docDestino.id);

      colRefOrigem.setData({"numero": docDestino.numero}, merge: true);
      colRefDestino.setData({"numero": docOrigem.numero}, merge: true);
    }
    if (event is CreateRelatorioEvent) {
      final docRef = _firestore.collection('Relatorio').document();
      await docRef.setData({'pastaId': event.pastaId}, merge: true).then((_) {
        _state.pedidoRelatorio = docRef.documentID;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is ResetCreateRelatorioEvent) {
      _state.pedidoRelatorio = null;
    }
    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em PastaList  = ${event.runtimeType}');
  }
}
