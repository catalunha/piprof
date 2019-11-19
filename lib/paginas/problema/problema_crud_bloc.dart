import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/problema_model.dart';
import 'package:firestore_wrapper/firestore_wrapper.dart' as fsw;
import 'package:piprof/modelos/usuario_model.dart';
import 'package:rxdart/rxdart.dart';

class ProblemaCRUDBlocEvent {}

class GetUsuarioAuthEvent extends ProblemaCRUDBlocEvent {
  final UsuarioModel usuarioAuth;

  GetUsuarioAuthEvent(this.usuarioAuth);
}

class GetPastaEvent extends ProblemaCRUDBlocEvent {
  final String pastaID;

  GetPastaEvent(this.pastaID);
}

class GetPastaListEvent extends ProblemaCRUDBlocEvent {}

class GetProblemaEvent extends ProblemaCRUDBlocEvent {
  final String problemaID;

  GetProblemaEvent(this.problemaID);
}

class UpdateAtivoEvent extends ProblemaCRUDBlocEvent {
  final bool ativo;
  UpdateAtivoEvent(this.ativo);
}

class UpdateTextFieldEvent extends ProblemaCRUDBlocEvent {
  final String campo;
  final String texto;
  UpdateTextFieldEvent(this.campo, this.texto);
}

class UpdatePrecisaAlgoritmoPSimulacaoEvent extends ProblemaCRUDBlocEvent {
  final bool precisa;
  UpdatePrecisaAlgoritmoPSimulacaoEvent(this.precisa);
}

class SelectPastaIDEvent extends ProblemaCRUDBlocEvent {
  final PastaModel pasta;

  SelectPastaIDEvent(this.pasta);
}

class SaveEvent extends ProblemaCRUDBlocEvent {}

class DeleteDocumentEvent extends ProblemaCRUDBlocEvent {}

class ProblemaCRUDBlocState {
  bool isDataValid = false;
  String problemaID;
  UsuarioModel usuarioAuth;

  PastaModel pasta = PastaModel();
  List<PastaModel> pastaList = List<PastaModel>();

  ProblemaModel problema = ProblemaModel();

  // dynamic data;
  String nome;
  String descricao;
  bool ativo = true;
  bool precisaAlgoritmoPSimulacao = false;
  String urlSemAlgoritmo;
  bool algoritmoPSimulacaoAtivado;
  PastaFk pastaDestino;

  void updateState() {
    ativo = problema.ativo;
    nome = problema.nome;
    descricao = problema.descricao;
    precisaAlgoritmoPSimulacao = problema.precisaAlgoritmoPSimulacao;
    urlSemAlgoritmo = problema.urlSemAlgoritmo;
    algoritmoPSimulacaoAtivado = problema.algoritmoPSimulacaoAtivado;
    pastaDestino = problema?.pasta;
  }

  bool liberaAtivo() {
    if (precisaAlgoritmoPSimulacao == true &&
        problema.algoritmoPSimulacaoAtivado == false) {
      return false;
    } else {
      return true;
    }
  }
}

class ProblemaCRUDBloc {
  /// Firestore
  final fsw.Firestore _firestore;
  final _authBloc;

  /// Eventos
  final _eventController = BehaviorSubject<ProblemaCRUDBlocEvent>();
  Stream<ProblemaCRUDBlocEvent> get eventStream => _eventController.stream;
  Function get eventSink => _eventController.sink.add;

  /// Estados
  final ProblemaCRUDBlocState _state = ProblemaCRUDBlocState();
  final _stateController = BehaviorSubject<ProblemaCRUDBlocState>();
  Stream<ProblemaCRUDBlocState> get stateStream => _stateController.stream;
  Function get stateSink => _stateController.sink.add;

  /// Bloc
  ProblemaCRUDBloc(this._firestore, this._authBloc) {
    eventStream.listen(_mapEventToState);
    _authBloc.perfil.listen((usuarioAuth) {
      eventSink(GetUsuarioAuthEvent(usuarioAuth));
      if (!_stateController.isClosed) _stateController.add(_state);
      eventSink(GetPastaListEvent());
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
    if (_state.precisaAlgoritmoPSimulacao == false &&
        _state.urlSemAlgoritmo == null) {
      _state.isDataValid = false;
    }
    if (_state.urlSemAlgoritmo != null &&
        _state.urlSemAlgoritmo.isEmpty) {
      _state.isDataValid = false;
    }
  }

  _mapEventToState(ProblemaCRUDBlocEvent event) async {
    if (event is GetUsuarioAuthEvent) {
      _state.usuarioAuth = event.usuarioAuth;
    }

    if (event is GetPastaEvent) {
      final docRef =
          _firestore.collection(PastaModel.collection).document(event.pastaID);
      final snap = await docRef.get();
      if (snap.exists) {
        _state.pasta = PastaModel(id: snap.documentID).fromMap(snap.data);
        _state.pastaDestino =
            PastaFk(id: _state.pasta.id, nome: _state.pasta.nome);
      }
    }

    if (event is GetPastaListEvent) {
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
        // print(_state.pastaList);
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    }
    if (event is GetProblemaEvent) {
      final docRef = _firestore
          .collection(ProblemaModel.collection)
          .document(event.problemaID);
      _state.problemaID = event.problemaID;
      final snap = await docRef.get();
      if (snap.exists) {
        _state.problema = ProblemaModel(id: snap.documentID).fromMap(snap.data);
        _state.updateState();
      }
    }
    if (event is UpdateAtivoEvent) {
      _state.ativo = event.ativo;
    }
    if (event is UpdateTextFieldEvent) {
      if (event.campo == 'nome') {
        _state.nome = event.texto;
      } else if (event.campo == 'descricao') {
        _state.descricao = event.texto;
      } else if (event.campo == 'urlSemAlgoritmo') {
        _state.urlSemAlgoritmo = event.texto;
      }
    }

    if (event is UpdatePrecisaAlgoritmoPSimulacaoEvent) {
      _state.precisaAlgoritmoPSimulacao = event.precisa;
      _state.algoritmoPSimulacaoAtivado = false;
    }

    if (event is SelectPastaIDEvent) {
      _state.pastaDestino = PastaFk(id: event.pasta.id, nome: event.pasta.nome);
    }

    if (event is SaveEvent) {
      final docRef = _firestore
          .collection(ProblemaModel.collection)
          .document(_state.problemaID);

      ProblemaModel problemaUpdate = ProblemaModel(
        ativo: _state.precisaAlgoritmoPSimulacao &&
                _state.problema.algoritmoPSimulacaoAtivado == false
            ? false
            : _state.ativo,
        nome: _state.nome,
        descricao: _state.descricao,
        precisaAlgoritmoPSimulacao: _state.precisaAlgoritmoPSimulacao,
        urlSemAlgoritmo: _state.urlSemAlgoritmo,
        algoritmoPSimulacaoAtivado: _state.algoritmoPSimulacaoAtivado,
        modificado: DateTime.now(),
        pasta: _state.pastaDestino,
      );
      if (_state.precisaAlgoritmoPSimulacao) {
        problemaUpdate.url = null;
      } else {
        problemaUpdate.url = _state.urlSemAlgoritmo;
      }
      if (_state.problemaID == null) {
        problemaUpdate.numero =
            (_state.usuarioAuth.problemaNumeroAdicionado ?? 0) + 1;
        //+++ Atualizar usuario com mais uma pasta em seu cadastro
        final usuarioDocRef = _firestore
            .collection(UsuarioModel.collection)
            .document(_state.usuarioAuth.id);
        await usuarioDocRef.setData({
          'problemaNumeroAdicionado':
              Bootstrap.instance.fieldValue.increment(1),
        }, merge: true);
        //---
        problemaUpdate.professor = UsuarioFk(
          id: _state.usuarioAuth.id,
          nome: _state.usuarioAuth.nome,
        );
      }

      await docRef.setData(problemaUpdate.toMap(), merge: true);
    }
    if (event is DeleteDocumentEvent) {
      _firestore
          .collection(ProblemaModel.collection)
          .document(_state.problema.id)
          .delete();
    }

    _validateData();
    if (!_stateController.isClosed) _stateController.add(_state);
    print('event.runtimeType em ProblemaCRUDBloc  = ${event.runtimeType}');
  }
}
