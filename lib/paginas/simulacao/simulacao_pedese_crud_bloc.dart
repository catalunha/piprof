import 'package:piprof/bootstrap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:uuid/uuid.dart' as uuid;

class SimulacaoPedeseCRUDBlocEvent {}

class GetSimulacaoEvent extends SimulacaoPedeseCRUDBlocEvent {
  final String simulacaoID;
  final String pedeseKey;

  GetSimulacaoEvent({this.simulacaoID, this.pedeseKey});
}

class GetPedeseEvent extends SimulacaoPedeseCRUDBlocEvent {
  final String pedeseKey;

  GetPedeseEvent(this.pedeseKey);
}

class UpdateTextFieldEvent extends SimulacaoPedeseCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class UpdateTipoEvent extends SimulacaoPedeseCRUDBlocEvent {
  final String tipo;
  UpdateTipoEvent(this.tipo);
}

class SaveEvent extends SimulacaoPedeseCRUDBlocEvent {}

class DeleteDocumentEvent extends SimulacaoPedeseCRUDBlocEvent {}

class SimulacaoPedeseCRUDBlocState {
  bool isDataValid = false;
  String pedeseKey;
  SimulacaoModel simulacao = SimulacaoModel();
  Pedese pedese = Pedese();

  String nome;
  String gabarito;
  String tipo;

  void updateState() {
    nome = pedese.nome;
    gabarito = pedese.gabarito;
    tipo = pedese.tipo;
  }
}

class SimulacaoPedeseCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoPedeseCRUDBlocEvent>();
  Stream<SimulacaoPedeseCRUDBlocEvent> get eventStream =>
      _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoPedeseCRUDBlocState _state = SimulacaoPedeseCRUDBlocState();
  final _stateController = BehaviorSubject<SimulacaoPedeseCRUDBlocState>();
  Stream<SimulacaoPedeseCRUDBlocState> get stateStream =>
      _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoPedeseCRUDBloc(this._firestore) {
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
    if (_state.nome == null) {
      _state.isDataValid = false;
    }
    if (_state.tipo == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoPedeseCRUDBlocEvent event) async {
    if (event is GetSimulacaoEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.simulacao =
            SimulacaoModel(id: snap.documentID).fromMap(snap.data);
        if (event.pedeseKey != null) eventSink(GetPedeseEvent(event.pedeseKey));
      }
    }
    if (event is GetPedeseEvent) {
      _state.pedeseKey = event.pedeseKey;
      _state.pedese = _state.simulacao.pedese[event.pedeseKey];
      _state.updateState();
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'gabarito') {
        _state.gabarito = event.texto;
      }
    }
    if (event is UpdateTipoEvent) {
      _state.tipo = event.tipo;
    }
    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);

      Pedese pedeseUpdate = Pedese(
        nome: _state.nome,
        gabarito: _state.gabarito,
        tipo: _state.tipo,
      );
      if (_state.pedeseKey == null) {
        final uuidG = uuid.Uuid();
        pedeseUpdate.ordem = _state.simulacao.ordem ?? 1;
        print(uuidG.v4());
        _state.simulacao.pedese = {uuidG.v4(): pedeseUpdate};
        _state.simulacao.ordem = _state.simulacao.ordem + 1;
      } else {
        _state.simulacao.pedese[_state.pedeseKey] = pedeseUpdate;
      }
      await docRef.setData(_state.simulacao.toMap(), merge: true);
    }

    if (event is DeleteDocumentEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);
      await docRef.setData({
        "pedese": {
          "${_state.pedeseKey}": Bootstrap.instance.fieldValue.delete()
        }
      }, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoPedeseCRUDBloc  = ${event.runtimeType}');
  }
}
