import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/paginas/desenvolvimento/desenvolvimento_page.dart';
import 'package:piprof/paginas/login/home.dart';
import 'package:piprof/paginas/login/versao.dart';
import 'package:piprof/paginas/turma/turma_aluno_list_page.dart';
import 'package:piprof/paginas/turma/turma_aluno_page.dart';
import 'package:piprof/paginas/turma/turma_ativa_list_page.dart';
import 'package:piprof/paginas/turma/turma_crud_page.dart';
import 'package:piprof/paginas/turma/turma_inativa_list_page.dart';
import 'package:piprof/paginas/upload/uploader_page.dart';
import 'package:piprof/paginas/usuario/perfil_page.dart';
import 'package:piprof/plataforma/recursos.dart';
// import 'package:piprof/web.dart';

void main() {
  // webSetUp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authBloc = Bootstrap.instance.authBloc;
    Recursos.initialize(Theme.of(context).platform);
    // Intl.defaultLocale = 'pt_br';

    return MaterialApp(
      title: 'PI - Prof',
      theme: ThemeData.dark(),
      // initialRoute: "/tarefa/aberta",
      initialRoute: "/",
      routes: {
        //homePage
        "/": (context) => HomePage(authBloc),

        //upload
        "/upload": (context) => UploaderPage(authBloc),

        //desenvolvimento
        "/desenvolvimento": (context) => Desenvolvimento(),

        // //tarefa
        // "/tarefa/aberta": (context) => TarefaAbertaListPage(authBloc),
        // "/tarefa/responder": (context) {
        //   final settings = ModalRoute.of(context).settings;
        //   return TarefaAbertaResponderPage(settings.arguments);
        // },
        // "/tarefa/list": (context) {
        //   final settings = ModalRoute.of(context).settings;
        //   return TarefaListPage(authBloc, settings.arguments);
        // },
        // // "/tarefa": (context) {
        // //   final settings = ModalRoute.of(context).settings;
        // //   return TarefaPage(authBloc, settings.arguments);
        // // },

        // turma aluno
        // "/turma/list": (context) => TurmaListPage(authBloc),
        // turma prof
        "/turma/ativa/list": (context) => TurmaAtivaListPage(authBloc),
        "/turma/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          return TurmaCRUDPage(authBloc, settings.arguments);
        },
        "/turma/aluno": (context) {
          final settings = ModalRoute.of(context).settings;
          return TurmaAlunoPage(settings.arguments);
        },
        "/turma/aluno/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return TurmaAlunoListPage(settings.arguments);
        },

        "/turma/inativa/list": (context) => TurmaInativaListPage(authBloc),

        // //avaliacao
        // "/avaliacao/list": (context) {
        //   final settings = ModalRoute.of(context).settings;
        //   return AvaliacaoListPage(authBloc, settings.arguments);
        // },

        // //questao
        // "/questao/list": (context) {
        //   final settings = ModalRoute.of(context).settings;
        //   return QuestaoListPage(settings.arguments);
        // },

        //EndDrawer
        //perfil
        "/perfil": (context) => PerfilPage(authBloc),
        //Versao
        "/versao": (context) => Versao(),
      },
    );
  }
}
