import 'package:piprof/modelos/base_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class PastaModel extends FirestoreModel {
  static final String collection = "Pasta";
  bool ativo;
  int numero;
  String nome;
  String descricao;
  UsuarioFk professor;

  PastaModel({
    String id,
    this.ativo,
    this.numero,

    this.nome,
    this.descricao,
    this.professor,
  }) : super(id);

  @override
  PastaModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('ativo')) ativo = map['ativo'];
    if (map.containsKey('numero')) numero = map['numero'];
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('descricao')) descricao = map['descricao'];
    professor = map.containsKey('professor') && map['professor'] != null
        ? UsuarioFk.fromMap(map['professor'])
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
    if (this.professor != null) {
      data['professor'] = this.professor.toMap();
    }
    return data;
  }
}

class PastaFk {
  String id;
  String nome;

  PastaFk({this.id, this.nome});

  PastaFk.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('id')) id = map['id'];
    if (map.containsKey('nome')) nome = map['nome'];
  }

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (id != null) data['id'] = this.id;
    if (nome != null) data['nome'] = this.nome;
    return data;
  }
}
