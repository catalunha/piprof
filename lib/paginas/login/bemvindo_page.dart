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
      //  body: Image.network(
      //     // 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/iguana.jpeg?alt=media&token=42446346-0659-41a0-a6c7-94539723ab44',
      //     'https://drive.google.com/uc?id=1vKmzKZIs_pxfDMWT2wdstBlI8Ro_Ok0Q'
      //     // 'https://docs.google.com/uc?id=1vKmzKZIs_pxfDMWT2wdstBlI8Ro_Ok0Q'
      //     'https://drive.google.com/open?id=1vKmzKZIs_pxfDMWT2wdstBlI8Ro_Ok0Q'
      //   ),
      body: Center(
        child: Text(
            "Seja bem vindo(a)\nAo Aplicativo PI, versão para professor.\nAqui você cria e distribui de forma simples\nsuas tarefas aos alunos da escola, curso ou faculdade.\nCom um valores individuais para cada aluno.",
            style: TextStyle(
              color: Colors.green,
              fontSize: 22.0,
            ),
            textAlign: TextAlign.center),
      ),
    );
  }
}
