import 'package:piprof/modelos/base_model.dart';

class UsuarioNovoModel extends FirestoreModel {
  static final String collection = "UsuarioNovo";
  bool ativo;
  bool professor;
  dynamic cadastrado;
  String email;
  String matricula;
  String nome;
  List<dynamic> rota;
  String turma;

  UsuarioNovoModel({
    String id,
    this.nome,
    this.matricula,
    this.email,
    this.ativo,
    this.professor,
    this.cadastrado,
    this.rota,
    this.turma,
  }) : super(id);

  @override
  UsuarioNovoModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('matricula')) matricula = map['matricula'];
    if (map.containsKey('email')) email = map['email'];
    if (map.containsKey('ativo')) ativo = map['ativo'];
    if (map.containsKey('professor')) professor = map['professor'];
    if (map.containsKey('rota')) rota = map['rota'];
    if (map.containsKey('turma')) turma = map['turma'];
    cadastrado = map.containsKey('cadastrado') && map['cadastrado'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            map['cadastrado'].millisecondsSinceEpoch)
        : null;
    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (nome != null) data['nome'] = this.nome;
    if (matricula != null) data['matricula'] = this.matricula;
    if (email != null) data['email'] = this.email;
    if (ativo != null) data['ativo'] = this.ativo;
    if (professor != null) data['professor'] = this.professor;
    if (rota != null) data['rota'] = this.rota;
    if (turma != null) data['turma'] = this.turma;
    if (cadastrado != null) data['cadastrado'] = this.cadastrado;

    return data;
  }
}
