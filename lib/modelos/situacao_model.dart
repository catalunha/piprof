import 'package:piprof/modelos/base_model.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class SituacaoModel extends FirestoreModel {
  static final String collection = "Situacao";
  bool ativo;
  int numero;
  String nome;
  String descricao;
  UsuarioFk professor;
  PastaFk pasta;
String url;
  SituacaoModel({
    String id,
    this.ativo,
    this.numero,
    this.nome,
    this.descricao,
    this.professor,
    this.pasta,
    this.url,
  }) : super(id);

  @override
  SituacaoModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('ativo')) ativo = map['ativo'];
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
    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // _updateAll();
    if (ativo != null) data['ativo'] = this.ativo;
    if (numero != null) data['numero'] = this.numero;
    if (nome != null) data['nome'] = this.nome;
    if (descricao != null) data['descricao'] = this.descricao;
    if (url != null) data['url'] = this.url;
    if (this.professor != null) {
      data['professor'] = this.professor.toMap();
    }
    if (this.pasta != null) {
      data['pasta'] = this.pasta.toMap();
    }
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
