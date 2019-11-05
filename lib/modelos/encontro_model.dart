import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/base_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class UploadModel extends FirestoreModel {
  static final String collection = "Upload";
  TurmaFk turma;
  dynamic data;
  dynamic modificado;
  String nome;
  String descricao;
  List<dynamic> alunoList;

  UploadModel({
    String id,
    this.turma,
    this.data,
    this.modificado,
    this.nome,
    this.descricao,
    this.alunoList,
  }) : super(id);

  @override
  UploadModel fromMap(Map<String, dynamic> map) {
    turma = map.containsKey('turma') && map['turma'] != null ? TurmaFk.fromMap(map['turma']) : null;
    data = map.containsKey('data') && map['data'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['modificado'].millisecondsSinceEpoch)
        : null;
    modificado = map.containsKey('modificado') && map['modificado'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['modificado'].millisecondsSinceEpoch)
        : null;
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('descricao')) descricao = map['descricao'];
    if (map.containsKey('alunoList')) alunoList = map['alunoList'];
    return this;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.turma != null) {
      data['turma'] = this.turma.toMap();
    }
    if (data != null) data['data'] = this.data;
    if (modificado != null) data['modificado'] = this.modificado;
    if (nome != null) data['nome'] = this.nome;
    if (descricao != null) data['descricao'] = this.descricao;
    if (alunoList != null) data['alunoList'] = this.alunoList;
    return data;
  }
}

class EncontroFk {
  String id;
  String nome;

  EncontroFk({this.id, this.nome});

  EncontroFk.fromMap(Map<dynamic, dynamic> map) {
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
