import 'package:piprof/modelos/base_model.dart';

class UsuarioNovoModel extends FirestoreModel {
  static final String collection = "UsuarioNovo";
  bool ativo;
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
    this.rota,
    this.turma,
  }) : super(id);

  @override
  UsuarioNovoModel fromMap(Map<String, dynamic> map) {
    if (map.containsKey('nome')) nome = map['nome'];
    if (map.containsKey('matricula')) matricula = map['matricula'];
    if (map.containsKey('email')) email = map['email'];
    if (map.containsKey('ativo')) ativo = map['ativo'];
    if (map.containsKey('rota')) rota = map['rota'];
    if (map.containsKey('turma')) turma = map['turma'];

    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (nome != null) data['nome'] = this.nome;
    if (matricula != null) data['matricula'] = this.matricula;
    if (email != null) data['email'] = this.email;
    if (ativo != null) data['ativo'] = this.ativo;
    if (rota != null) data['rota'] = this.rota;
    if (turma != null) data['turma'] = this.turma;

    return data;
  }
}
