import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:rxdart/rxdart.dart';

class TarefaConferirBlocEvent {}

class GetSimulacaoEvent extends TarefaConferirBlocEvent {
  final String simulacaoID;

  GetSimulacaoEvent(this.simulacaoID);
}

class UpdatePedeseEvent extends TarefaConferirBlocEvent {
  final String gabaritoKey;
  final String valor;

  UpdatePedeseEvent(this.gabaritoKey, this.valor);
}

class UpdateApagarAnexoImagemArquivoEvent extends TarefaConferirBlocEvent {
  final String gabaritoKey;
  final String valor;

  UpdateApagarAnexoImagemArquivoEvent(this.gabaritoKey, this.valor);
}

class SaveEvent extends TarefaConferirBlocEvent {}

class TarefaConferirBlocState {
  bool isDataValid = false;
  ProblemaModel problema = ProblemaModel();
  SimulacaoModel simulacao = SimulacaoModel();
  Map<String, Gabarito> resposta = Map<String, Gabarito>();
  void updateState() {
    resposta.clear();
    for (var item in simulacao.gabarito.entries) {
      resposta[item.key] = Gabarito.fromMap(item.value.toMap());
    }
  }
}

class TarefaConferirBloc {
  /// Firestore
  final fsw.Firestore _firestore;

  /// Eventos
  final _eventController = BehaviorSubject<TarefaConferirBlocEvent>();
  Stream<TarefaConferirBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final TarefaConferirBlocState _state = TarefaConferirBlocState();
  final _stateController = BehaviorSubject<TarefaConferirBlocState>();
  Stream<TarefaConferirBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  TarefaConferirBloc(this._firestore) {
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

  _mapEventToState(TarefaConferirBlocEvent event) async {
    if (event is GetSimulacaoEvent) {
      _state.simulacao = null;

      final streamDocsRemetente = _firestore
          .collection(SimulacaoModel.collection)
          .document(event.simulacaoID)
          .snapshots();

      final snapListRemetente = streamDocsRemetente
          .map((doc) => SimulacaoModel(id: doc.documentID).fromMap(doc.data));

      snapListRemetente.listen((SimulacaoModel simulacao) async {
        _state.simulacao = simulacao;
        _state.updateState();
        if (!_stateController.isClosed) _stateController.add(_state);

        final streamDocsRemetente = _firestore
            .collection(ProblemaModel.collection)
            .document(_state.simulacao.problema.id)
            .snapshots();
        final snapListRemetente = streamDocsRemetente
            .map((doc) => ProblemaModel(id: doc.documentID).fromMap(doc.data));
        snapListRemetente.listen((ProblemaModel problema) async {
          _state.problema = problema;
          if (!_stateController.isClosed) _stateController.add(_state);
        });
      });
    }
    if (event is UpdatePedeseEvent) {
      var gabarito = _state.resposta[event.gabaritoKey];
      if (gabarito.tipo == 'numero' ||
          gabarito.tipo == 'palavra' ||
          gabarito.tipo == 'texto' ||
          gabarito.tipo == 'url' ||
          gabarito.tipo == 'urlimagem') {
        _state.resposta[event.gabaritoKey].resposta = event.valor;
      }
      if (gabarito.tipo == 'imagem' || gabarito.tipo == 'arquivo') {
        _state.resposta[event.gabaritoKey].respostaPath = event.valor;
        _state.resposta[event.gabaritoKey].resposta = null;
      }
    }
    if (event is UpdateApagarAnexoImagemArquivoEvent) {
      // print('apagar');
      var gabarito = _state.resposta[event.gabaritoKey];
      if (gabarito.tipo == 'imagem' || gabarito.tipo == 'arquivo') {
        _state.resposta[event.gabaritoKey].respostaUploadID = null;
        _state.resposta[event.gabaritoKey].respostaPath = null;
        _state.resposta[event.gabaritoKey].resposta = null;
      }
      print(_state.resposta[event.gabaritoKey]);
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em TarefaConferirBloc  = ${event.runtimeType}');
  }
}
