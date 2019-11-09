import 'package:piprof/modelos/base_model.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class SituacaoModel extends FirestoreModel {
  static final String collection = "Situacao";
  bool ativo;
  dynamic modificado;
  int numero;
  String nome;
  String descricao;
  UsuarioFk professor;
  PastaFk pasta;
  String url;
  bool precisaAlgoritmoPSimulacao;
  String urlPDFSituacaoSemAlgoritmo;
  bool ativadoAlgoritmoPSimulacao;
  int simulacaoNumeroAdicionado;
  SituacaoModel({
    String id,
    this.ativo,
    this.modificado,
    this.numero,
    this.nome,
    this.descricao,
    this.professor,
    this.pasta,
    this.url,
    this.precisaAlgoritmoPSimulacao,
    this.urlPDFSituacaoSemAlgoritmo,
    this.ativadoAlgoritmoPSimulacao,
    this.simulacaoNumeroAdicionado,
  }) : super(id);

  @override
  SituacaoModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('ativo')) ativo = map['ativo'];
    modificado = map.containsKey('modificado') && map['modificado'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            map['modificado'].millisecondsSinceEpoch)
        : null;
    if (map.containsKey('numero')) numero = map['numero'];
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('descricao')) descricao = map['descricao'];
    if (map.containsKey('url')) url = map['url'];
    professor = map.containsKey('professor') && map['professor'] != null
        ? UsuarioFk.fromMap(map['professor'])
        : null;
    pasta = map.containsKey('pasta') && map['pasta'] != null
        ? PastaFk.fromMap(map['pasta'])
        : null;
    if (map.containsKey('precisaAlgoritmoPSimulacao'))
      precisaAlgoritmoPSimulacao = map['precisaAlgoritmoPSimulacao'];
    if (map.containsKey('urlPDFSituacaoSemAlgoritmo'))
      urlPDFSituacaoSemAlgoritmo = map['urlPDFSituacaoSemAlgoritmo'];
    if (map.containsKey('ativadoAlgoritmoPSimulacao'))
      ativadoAlgoritmoPSimulacao = map['ativadoAlgoritmoPSimulacao'];
    if (map.containsKey('simulacaoNumeroAdicionado'))
      simulacaoNumeroAdicionado = map['simulacaoNumeroAdicionado'];

    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // _updateAll();
    if (ativo != null) data['ativo'] = this.ativo;
    if (modificado != null) data['modificado'] = this.modificado;
    if (numero != null) data['numero'] = this.numero;
    if (nome != null) data['nome'] = this.nome;
    if (descricao != null) data['descricao'] = this.descricao;
    data['url'] = this.url;
    if (this.professor != null) {
      data['professor'] = this.professor.toMap();
    }
    if (this.pasta != null) {
      data['pasta'] = this.pasta.toMap();
    }
    if (precisaAlgoritmoPSimulacao != null)
      data['precisaAlgoritmoPSimulacao'] = this.precisaAlgoritmoPSimulacao;
    if (urlPDFSituacaoSemAlgoritmo != null)
      data['urlPDFSituacaoSemAlgoritmo'] = this.urlPDFSituacaoSemAlgoritmo;
    if (ativadoAlgoritmoPSimulacao != null)
      data['ativadoAlgoritmoPSimulacao'] = this.ativadoAlgoritmoPSimulacao;
    if (simulacaoNumeroAdicionado != null)
      data['simulacaoNumeroAdicionado'] = this.simulacaoNumeroAdicionado;

    return data;
  }
}

class SituacaoFk {
  String id;
  String nome;
  String url;

  SituacaoFk({this.id, this.nome, this.url});

  SituacaoFk.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('id')) id = map['id'];
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('url')) url = map['url'];
  }

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (id != null) data['id'] = this.id;
    if (nome != null) data['nome'] = this.nome;
    if (url != null) data['url'] = this.url;
    return data;
  }
}
