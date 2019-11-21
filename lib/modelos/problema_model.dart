import 'package:piprof/modelos/base_model.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class ProblemaModel extends FirestoreModel {
  static final String collection = "Problema";
  bool ativo;
  dynamic modificado;
  int numero;
  String nome;
  String descricao;
  String solucao;
  UsuarioFk professor;
  PastaFk pasta;
  String url;
  bool precisaAlgoritmoPSimulacao;
  String urlSemAlgoritmo;
  bool algoritmoPSimulacaoAtivado;
  int simulacaoNumero;
  Map<String, dynamic> uso;
  ProblemaModel({
    String id,
    this.ativo,
    this.modificado,
    this.numero,
    this.nome,
    this.descricao,
    this.solucao,
    this.professor,
    this.pasta,
    this.url,
    this.precisaAlgoritmoPSimulacao,
    this.urlSemAlgoritmo,
    this.algoritmoPSimulacaoAtivado,
    this.simulacaoNumero,
    this.uso,
  }) : super(id);

  @override
  ProblemaModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('ativo')) ativo = map['ativo'];
    modificado = map.containsKey('modificado') && map['modificado'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            map['modificado'].millisecondsSinceEpoch)
        : null;
    if (map.containsKey('numero')) numero = map['numero'];
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('descricao')) descricao = map['descricao'];
    if (map.containsKey('solucao')) solucao = map['solucao'];
    if (map.containsKey('url')) url = map['url'];
    professor = map.containsKey('professor') && map['professor'] != null
        ? UsuarioFk.fromMap(map['professor'])
        : null;
    pasta = map.containsKey('pasta') && map['pasta'] != null
        ? PastaFk.fromMap(map['pasta'])
        : null;
    if (map.containsKey('precisaAlgoritmoPSimulacao'))
      precisaAlgoritmoPSimulacao = map['precisaAlgoritmoPSimulacao'];
    if (map.containsKey('urlProblemaSemAlgoritmo'))
      urlSemAlgoritmo = map['urlProblemaSemAlgoritmo'];
    if (map.containsKey('algoritmoPSimulacaoAtivado'))
      algoritmoPSimulacaoAtivado = map['algoritmoPSimulacaoAtivado'];
    if (map.containsKey('simulacaoNumero'))
      simulacaoNumero = map['simulacaoNumero'];
    if (map.containsKey('uso')) uso = map['uso'];

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
    if (uso != null) data['uso'] = this.uso;
    if (descricao != null) data['descricao'] = this.descricao;
    if (solucao != null) data['solucao'] = this.solucao;
    data['url'] = this.url;
    if (this.professor != null) {
      data['professor'] = this.professor.toMap();
    }
    if (this.pasta != null) {
      data['pasta'] = this.pasta.toMap();
    }
    if (precisaAlgoritmoPSimulacao != null)
      data['precisaAlgoritmoPSimulacao'] = this.precisaAlgoritmoPSimulacao;
    if (urlSemAlgoritmo != null)
      data['urlProblemaSemAlgoritmo'] = this.urlSemAlgoritmo;
    if (algoritmoPSimulacaoAtivado != null)
      data['algoritmoPSimulacaoAtivado'] = this.algoritmoPSimulacaoAtivado;
    if (simulacaoNumero != null)
      data['simulacaoNumero'] = this.simulacaoNumero;

    return data;
  }
}

class ProblemaFk {
  String id;
  String nome;
  String url;

  ProblemaFk({this.id, this.nome, this.url});

  ProblemaFk.fromMap(Map<dynamic, dynamic> map) {
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
