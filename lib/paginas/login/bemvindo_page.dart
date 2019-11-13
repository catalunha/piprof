import 'package:flutter/material.dart';
import 'package:piprof/auth_bloc.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/paginas/login/bemvindo_bloc.dart';


class BemVindoPage extends StatefulWidget {
  final AuthBloc authBloc;

  BemVindoPage(this.authBloc);

  _BemVindoPageState createState() => _BemVindoPageState(this.authBloc);
}

class _BemVindoPageState extends State<BemVindoPage> {
  BemvindoBloc bloc;
  _BemVindoPageState(AuthBloc authBloc) : bloc = BemvindoBloc(authBloc);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: StreamBuilder<BemvindoBlocState>(
        stream: bloc.stateStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Text("ERROR");
          }
          if (!snap.hasData) {
            return Text("Buscando usuario...");
          }
          return Text("Oi Prof. ${snap.data?.usuario?.cracha}");
        },
      ),
      body: Center(
        child: Text(
            "Seja bem vindo(a)\nAo Aplicativo PI, versão para professor.\nAqui você aplica de forma simples\nsuas tarefas de escola, curso ou faculdade.\nUma Proposta Individual para cada aluno."),
      ),
    );
  }
}
