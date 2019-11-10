import 'package:piprof/modelos/base_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class SimulacaoModel extends FirestoreModel {
  static final String collection = "Simulacao";
  bool ativo;
  dynamic modificado;
  UsuarioFk professor;
  SituacaoFk situacao;
  bool algoritmoDoAdmin;
  bool algoritmoDoProfessor;
  int ordemAdicionada;

  String nome;
  String descricao;
  String url;
  Map<String, Variavel> variavel = Map<String, Variavel>();
  Map<String, Pedese> pedese = Map<String, Pedese>();

  SimulacaoModel({
    String id,
    this.ativo,
    this.modificado,
    this.professor,
    this.situacao,
    this.algoritmoDoAdmin,
    this.algoritmoDoProfessor,
    this.nome,
    this.ordemAdicionada,
    this.descricao,
    this.url,
    this.variavel,
    this.pedese,
  }) : super(id);

  @override
  SimulacaoModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('ativo')) ativo = map['ativo'];
    professor = map.containsKey('professor') && map['professor'] != null
        ? UsuarioFk.fromMap(map['professor'])
        : null;
    situacao = map.containsKey('situacao') && map['situacao'] != null
        ? SituacaoFk.fromMap(map['situacao'])
        : null;

    modificado = map.containsKey('modificado') && map['modificado'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            map['modificado'].millisecondsSinceEpoch)
        : null;

    if (map.containsKey('algoritmoDoAdmin'))
      algoritmoDoAdmin = map['algoritmoDoAdmin'];
    if (map.containsKey('algoritmoDoProfessor'))
      algoritmoDoProfessor = map['algoritmoDoProfessor'];
    if (map.containsKey('ordemAdicionada'))
      ordemAdicionada = map['ordemAdicionada'];
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('descricao')) descricao = map['descricao'];
    if (map.containsKey('url')) url = map['url'];

    if (map["variavel"] is Map) {
      variavel = Map<String, Variavel>();
      for (var item in map["variavel"].entries) {
        variavel[item.key] = Variavel.fromMap(item.value);
      }
    }
    if (map["pedese"] is Map) {
      pedese = Map<String, Pedese>();
      for (var item in map["pedese"].entries) {
        pedese[item.key] = Pedese.fromMap(item.value);
      }
    }
    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // _updateAll();
    if (ativo != null) data['ativo'] = this.ativo;
    if (this.professor != null) {
      data['professor'] = this.professor.toMap();
    }
    if (this.situacao != null) {
      data['situacao'] = this.situacao.toMap();
    }

    if (modificado != null) data['modificado'] = this.modificado;
    if (algoritmoDoAdmin != null)
      data['algoritmoDoAdmin'] = this.algoritmoDoAdmin;
    if (algoritmoDoProfessor != null)
      data['algoritmoDoProfessor'] = this.algoritmoDoProfessor;
    if (ordemAdicionada != null) data['ordemAdicionada'] = this.ordemAdicionada;
    if (nome != null) data['nome'] = this.nome;
    if (descricao != null) data['descricao'] = this.descricao;
    if (url != null) data['url'] = this.url;

    if (variavel != null && variavel is Map) {
      data["variavel"] = Map<String, dynamic>();
      for (var item in variavel.entries) {
        data["variavel"][item.key] = item.value.toMap();
      }
    }
    if (pedese != null && pedese is Map) {
      data["pedese"] = Map<String, dynamic>();
      for (var item in pedese.entries) {
        data["pedese"][item.key] = item.value.toMap();
      }
    }
    return data;
  }
}

class Variavel {
  String nome;
  int ordem;
  String tipo;
  String valor;

  Variavel({
    this.nome,
    this.ordem,
    this.tipo,
    this.valor,
  });

  Variavel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('ordem')) ordem = map['ordem'];
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('tipo')) tipo = map['tipo'];
    if (map.containsKey('valor')) valor = map['valor'];
  }

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (ordem != null) data['ordem'] = this.ordem;
    if (nome != null) data['nome'] = this.nome;
    if (tipo != null) data['tipo'] = this.tipo;
    if (valor != null) data['valor'] = this.valor;
    return data;
  }
}

class Pedese {
  String nome;
  int ordem;
  String tipo;
  String gabarito;

  Pedese({
    this.nome,
    this.ordem,
    this.tipo,
    this.gabarito,
  });

  Pedese.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('ordem')) ordem = map['ordem'];
    if (map.containsKey('tipo')) tipo = map['tipo'];
    if (map.containsKey('gabarito')) gabarito = map['gabarito'];
  }

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (nome != null) data['nome'] = this.nome;
    if (ordem != null) data['ordem'] = this.ordem;
    if (tipo != null) data['tipo'] = this.tipo;
    if (gabarito != null) data['gabarito'] = this.gabarito;
    return data;
  }
}
