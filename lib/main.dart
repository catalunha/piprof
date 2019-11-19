import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/arguments_page.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_crud_page.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_list_page.dart';
import 'package:piprof/paginas/avaliacao/avaliacao_selecionar_aluno_page.dart';
import 'package:piprof/paginas/desenvolvimento/desenvolvimento_page.dart';
import 'package:piprof/paginas/encontro/encontro_aluno_list_page.dart';
import 'package:piprof/paginas/encontro/encontro_crud_page.dart';
import 'package:piprof/paginas/encontro/encontro_list_page.dart';
import 'package:piprof/paginas/login/home.dart';
import 'package:piprof/paginas/login/versao.dart';
import 'package:piprof/paginas/pasta/pasta_crud_page.dart';
import 'package:piprof/paginas/pasta/pasta_list_page.dart';
import 'package:piprof/paginas/questao/questao_crud_page.dart';
import 'package:piprof/paginas/questao/questao_list_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_crud_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_list_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_gabarito_crud_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_gabarito_list_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_variavel_crud_page.dart';
import 'package:piprof/paginas/simulacao/simulacao_variavel_list_page.dart';
import 'package:piprof/paginas/problema/problema_crud_page.dart';
import 'package:piprof/paginas/problema/problema_list_page.dart';
import 'package:piprof/paginas/problema/problema_selecionar_page.dart';
import 'package:piprof/paginas/tarefa/tarefa_corrigir_page.dart';
import 'package:piprof/paginas/tarefa/tarefa_crud_page.dart';
import 'package:piprof/paginas/tarefa/tarefa_list_page.dart';
import 'package:piprof/paginas/turma/turma_aluno_list_page.dart';
import 'package:piprof/paginas/turma/turma_aluno_page.dart';
import 'package:piprof/paginas/turma/turma_ativa_list_page.dart';
import 'package:piprof/paginas/turma/turma_crud_page.dart';
import 'package:piprof/paginas/turma/turma_inativa_list_page.dart';
import 'package:piprof/paginas/upload/uploader_page.dart';
import 'package:piprof/paginas/usuario/perfil_page.dart';
import 'package:piprof/plataforma/recursos.dart';
import 'package:piprof/web.dart';
// import 'package:piprof/web.dart';

void main() {
  webSetUp();
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
      initialRoute: "/",
      routes: {
        //homePage
        "/": (context) => HomePage(authBloc),

        //upload
        "/upload": (context) => UploaderPage(authBloc),

        //desenvolvimento
        "/desenvolvimento": (context) => Desenvolvimento(),

        //turma
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
        "/turma/encontro/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return EncontroListPage(settings.arguments);
        },
        "/turma/encontro/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final EncontroCRUDPageArguments args = settings.arguments;
          return EncontroCRUDPage(
            authBloc: authBloc,
            turmaID: args.turmaID,
            encontroID: args.encontroID,
          );
        },
        "/turma/encontro/aluno": (context) {
          final settings = ModalRoute.of(context).settings;
          return EncontroAlunoListPage(encontroID: settings.arguments);
        },

        //avaliacao
        "/avaliacao/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return AvaliacaoListPage(settings.arguments);
        },
        "/avaliacao/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final AvaliacaoCRUDPageArguments args = settings.arguments;
          return AvaliacaoCRUDPage(
            authBloc: authBloc,
            turmaID: args.turmaID,
            avaliacaoID: args.avaliacaoID,
          );
        },
        "/avaliacao/marcar": (context) {
          final settings = ModalRoute.of(context).settings;
          return AvaliacaoSelecionarAlunoPage(avaliacaoID: settings.arguments);
        },

        //questao
        "/questao/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return QuestaoListPage(settings.arguments);
        },
        "/questao/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final QuestaoCRUDPageArguments args = settings.arguments;
          return QuestaoCRUDPage(
            authBloc: authBloc,
            avaliacaoID: args.avaliacaoID,
            questaoID: args.questaoID,
          );
        },

        //pasta
        "/pasta/list": (context) => PastaListPage(authBloc),
        "/pasta/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          return PastaCRUDPage(authBloc: authBloc, pastaID: settings.arguments);
        },

        //problema
        "/problema/selecionar": (context) => ProblemaSelecionarPage(authBloc),
        "/problema/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return ProblemaListPage(settings.arguments);
        },
        "/problema/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final ProblemaCRUDPageArguments args = settings.arguments;
          return ProblemaCRUDPage(
            authBloc: authBloc,
            pastaID: args.pastaID,
            problemaID: args.problemaID,
          );
        },

        //simulacao
        "/simulacao/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return SimulacaoListPage(settings.arguments);
        },
        "/simulacao/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final SimulacaoCRUDPageArguments args = settings.arguments;
          return SimulacaoCRUDPage(
            authBloc: authBloc,
            problemaID: args.problemaID,
            simulacaoID: args.simulacaoID,
          );
        },
       "/simulacao/variavel/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return SimulacaoVariavelListPage(settings.arguments);
        },
        "/simulacao/variavel/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final SimulacaoVariavelCRUDPageArguments args = settings.arguments;
          return VariavelCRUDPage(
            simulacaoID: args.simulacaoID,
            variavelKey: args.variavelKey,
          );
        },
       "/simulacao/gabarito/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return SimulacaoGabaritoListPage(settings.arguments);
        },
        "/simulacao/gabarito/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          final SimulacaoGabaritoCRUDPageArguments args = settings.arguments;
          return GabaritoCRUDPage(
            simulacaoID: args.simulacaoID,
            gabaritoKey: args.gabaritoKey,
          );
        },


        //tarefa
        "/tarefa/list": (context) {
          final settings = ModalRoute.of(context).settings;
          return TarefaListPage(settings.arguments);
        },
        "/tarefa/crud": (context) {
          final settings = ModalRoute.of(context).settings;
          return TarefaCRUDPage(settings.arguments);
        },
        "/tarefa/corrigir": (context) {
          final settings = ModalRoute.of(context).settings;
          return TarefaCorrigirPage(settings.arguments);
        },

        //EndDrawer
        //perfil
        "/perfil": (context) => PerfilPage(authBloc),
        //Versao
        "/versao": (context) => Versao(),
      },
    );
  }
}
