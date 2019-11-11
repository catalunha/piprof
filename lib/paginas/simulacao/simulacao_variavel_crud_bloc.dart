import 'package:piprof/bootstrap.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:uuid/uuid.dart' as uuid;

class SimulacaoVariavelCRUDBlocEvent {}

class GetSimulacaoEvent extends SimulacaoVariavelCRUDBlocEvent {
  final String simulacaoID;
  final String variavelKey;

  GetSimulacaoEvent({this.simulacaoID, this.variavelKey});
}

class GetVariavelEvent extends SimulacaoVariavelCRUDBlocEvent {
  final String variavelKey;

  GetVariavelEvent(this.variavelKey);
}

class UpdateTipoEvent extends SimulacaoVariavelCRUDBlocEvent {
  final String tipo;
  UpdateTipoEvent(this.tipo);
}

class UpdateTextFieldEvent extends SimulacaoVariavelCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class SaveEvent extends SimulacaoVariavelCRUDBlocEvent {}

class DeleteDocumentEvent extends SimulacaoVariavelCRUDBlocEvent {}

class SimulacaoVariavelCRUDBlocState {
  bool isDataValid = false;
  String variavelKey;
  SimulacaoModel simulacao = SimulacaoModel();
  Variavel variavel = Variavel();

  String nome;
  String valor;
  String tipo;

  void updateState() {
    nome = variavel.nome;
    valor = variavel.valor;
    tipo = variavel.tipo;
  }
}

class SimulacaoVariavelCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<SimulacaoVariavelCRUDBlocEvent>();
  Stream<SimulacaoVariavelCRUDBlocEvent> get eventStream =>
      _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final SimulacaoVariavelCRUDBlocState _state =
      SimulacaoVariavelCRUDBlocState();
  final _stateController = BehaviorSubject<SimulacaoVariavelCRUDBlocState>();
  Stream<SimulacaoVariavelCRUDBlocState> get stateStream =>
      _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  SimulacaoVariavelCRUDBloc(this._firestore) {
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
    if (_state.valor == null) {
      _state.isDataValid = false;
    }
    if (_state.tipo == null) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(SimulacaoVariavelCRUDBlocEvent event) async {
    if (event is GetSimulacaoEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.simulacao =
            SimulacaoModel(id: snap.documentID).fromMap(snap.data);
        if (event.variavelKey != null)
          eventSink(GetVariavelEvent(event.variavelKey));
      }
    }
    if (event is GetVariavelEvent) {
      _state.variavelKey = event.variavelKey;
      _state.variavel = _state.simulacao.variavel[event.variavelKey];
      _state.updateState();
    }
    if (event is UpdateTipoEvent) {
      _state.tipo = event.tipo;
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'valor') {
        _state.valor = event.texto;
      }
    }

    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);

      Variavel variavelUpdate = Variavel(
        nome: _state.nome,
        valor: _state.valor,
        tipo: _state.tipo,
      );
      if (_state.variavelKey == null) {
        final uuidG = uuid.Uuid();
        variavelUpdate.ordem = _state.simulacao.ordemAdicionada ?? 1;
        print(uuidG.v4());
        _state.simulacao.variavel = {uuidG.v4(): variavelUpdate};
        _state.simulacao.ordemAdicionada = _state.simulacao.ordemAdicionada + 1;
      } else {
        _state.simulacao.variavel[_state.variavelKey] = variavelUpdate;
      }
      await docRef.setData(_state.simulacao.toMap(), merge: true);
    }

    if (event is DeleteDocumentEvent) {
      final docRef = _firestore
          .collection(SimulacaoModel.collection)
          .document(_state.simulacao.id);
      await docRef.setData({
        "variavel": {
          "${_state.variavelKey}": Bootstrap.instance.fieldValue.delete()
        }
      }, merge: true);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print(
        'event.runtimeType em SimulacaoVariavelCRUDBloc  = ${event.runtimeType}');
  }
}
