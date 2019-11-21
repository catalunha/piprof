import 'package:piprof/bootstrap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:uuid/uuid.dart' as uuid;

class SimulacaoGabaritoCRUDBlocEvent {}

class GetSimulacaoEvent extends SimulacaoGabaritoCRUDBlocEvent {
  final String simulacaoID;
  final String gabaritoKey;

  GetSimulacaoEvent({this.simulacaoID, this.gabaritoKey});
}

class GetGabaritoEvent extends SimulacaoGabaritoCRUDBlocEvent {
  final String gabaritoKey;

  GetGabaritoEvent(this.gabaritoKey);
}

class UpdateTextFieldEvent extends SimulacaoGabaritoCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class UpdateTipoEvent extends SimulacaoGabaritoCRUDBlocEvent {
  final String tipo;
  UpdateTipoEvent(this.tipo);
}

class SaveEvent extends SimulacaoGabaritoCRUDBlocEvent {}

class DeleteDocumentEvent extends SimulacaoGabaritoCRUDBlocEvent {}

class SimulacaoGabaritoCRUDBlocState {
  bool isDataValid = false;
  String gabaritoKey;
  SimulacaoModel simulacao = SimulacaoModel();
  Gabarito gabarito = Gabarito();

  String nome;
  String tipo;
  String valor;

  void updateState() {
    nome = gabarito.nome;
    tipo = gabarito.tipo;
    valor = gabarito.valor;
  }
}

class SimulacaoGabaritoCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoGabaritoCRUDBlocEvent>();
  Stream<SimulacaoGabaritoCRUDBlocEvent> get eventStream =>
      _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoGabaritoCRUDBlocState _state = SimulacaoGabaritoCRUDBlocState();
  final _stateController = BehaviorSubject<SimulacaoGabaritoCRUDBlocState>();
  Stream<SimulacaoGabaritoCRUDBlocState> get stateStream =>
      _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoGabaritoCRUDBloc(this._firestore) {
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
    if (_state.nome == null || _state.nome.trim().isEmpty) {
      _state.isDataValid = false;
    }
    if (_state.tipo == null) {
      _state.isDataValid = false;
    }
    if (_state.valor == null || _state.valor.trim().isEmpty) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoGabaritoCRUDBlocEvent event) async {
    if (event is GetSimulacaoEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.simulacao =
            SimulacaoModel(id: snap.documentID).fromMap(snap.data);
        if (event.gabaritoKey != null) eventSink(GetGabaritoEvent(event.gabaritoKey));
      }
    }
    if (event is GetGabaritoEvent) {
      _state.gabaritoKey = event.gabaritoKey;
      _state.gabarito = _state.simulacao.gabarito[event.gabaritoKey];
      _state.updateState();
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'gabarito') {
        _state.valor = event.texto;
      }
    }
    if (event is UpdateTipoEvent) {
      _state.tipo = event.tipo;
    }
    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);

      Gabarito gabaritoUpdate = Gabarito(
        nome: _state.nome.trim(),
        valor: _state.valor.trim(),
        tipo: _state.tipo,
      );
      if (_state.gabaritoKey == null) {
        final uuidG = uuid.Uuid();
        gabaritoUpdate.ordem = _state.simulacao.ordem ?? 1;
        print(uuidG.v4());
        _state.simulacao.gabarito = {uuidG.v4(): gabaritoUpdate};
        _state.simulacao.ordem = _state.simulacao.ordem + 1;
      } else {
        _state.simulacao.gabarito[_state.gabaritoKey] = gabaritoUpdate;
      }
      await docRef.setData(_state.simulacao.toMap(), merge: true);
    }

    if (event is DeleteDocumentEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);
      await docRef.setData({
        "gabarito": {
          "${_state.gabaritoKey}": Bootstrap.instance.fieldValue.delete()
        }
      }, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoGabaritoCRUDBloc  = ${event.runtimeType}');
  }
}
