import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firestore_wrapper/firestore_wrapper.dart' as fw;
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/questao_model.dart';
import 'package:piprof/modelos/situacao_model.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/upload_model.dart';
import 'package:piprof/modelos/usuario_model.dart';

class Desenvolvimento extends StatefulWidget {
  @override
  _DesenvolvimentoState createState() => _DesenvolvimentoState();
}

class _DesenvolvimentoState extends State<Desenvolvimento> {
  final fw.Firestore _firestore = Bootstrap.instance.firestore;
  bool hasTimerStopped = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
        title: Text('Desenvolvimento'),
        body: ListView(
          children: <Widget>[
            Text(
                'Algumas vezes precisamos fazer alimentação das coleções para testes. Por isto criei estes botões para facilitar de forma rápida estas ações.'),
            ListTile(
              title: Text('Criar Usuario Professor.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  await cadastrarProfCatalunha();
                },
              ),
            ),
                        ListTile(
              title: Text('Criar Usuario Aluno.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  await cadastrarAlunoCatalunha();
                },
              ),
            ),
            ListTile(
              title: Text('Atualizar rotas de UsuarioCollection.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await atualizarRotaIndividual('YaTtTki7PZPPHznqpVtZrW6mIa42');
                  // await atualizarRotaTodos();
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Tarefa.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await cadastrarTarefa('0Teste1');
                  // await cadastrarTarefa('0Teste2');
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Turma.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  await cadastrarTurma01();
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Avaliacao.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  await cadastrarAvaliacao('0Avaliacao01');
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Questao.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  await cadastrarQuestao('0Questao01');
                },
              ),
            ),
            ListTile(
              title: Text('Testar comandos firebase.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await testarFirebaseCmds();
                },
              ),
            ),
            // ListTile(
            //   title: Text('Testar cronometro => $hasTimerStopped'),
            //   trailing: IconButton(
            //     icon: Icon(Icons.menu),
            //     onPressed: () async {
            //       hasTimerStopped = true;
            //     },
            //   ),
            // ),
            // Container(
            //   width: 60.0,
            //   padding: EdgeInsets.only(top: 3.0, right: 4.0),
            //   child: CountDownTimer(
            //     secondsRemaining: 7200,
            //     whenTimeExpires: () {
            //       setState(() {
            //         hasTimerStopped = true;
            //       });
            //       print('terminou clock');
            //     },
            //     countDownTimerStyle: TextStyle(
            //         color: Color(0XFFf5a623), fontSize: 17.0, height: 1.2),
            //   ),
            // )
          ],
        ));
  }

  Future atualizarRotaTodos() async {
    var collRef =
        await _firestore.collection(UsuarioModel.collection).getDocuments();

    for (var documentSnapshot in collRef.documents) {
      if (documentSnapshot.data.containsKey('routes')) {
        List<dynamic> routes = List<dynamic>();

        routes.addAll(documentSnapshot.data['routes']);
        // print(routes.runtimeType);
        routes.addAll([
          // Drawer
          // '/',
          // '/upload',
          // '/questionario/home',
          // '/aplicacao/home',
          // '/resposta/home',
          // '/sintese/home',
          // '/produto/home',
          // '/comunicacao/home',
          // '/administracao/home',
          // '/controle/home',
          // "/perfil/configuracao",
          // endDrawer
          '/perfil/configuracao',
          '/perfil',
          // '/painel/home',
          '/modooffline',
          "/versao",
        ]);

        await documentSnapshot.reference
            .setData({"routes": routes}, merge: true);
      } else {
        // print('Sem routes ${documentSnapshot.documentID}');
      }
    }
  }

  Future atualizarRotaIndividual(String userId) async {
    final docRef =
        _firestore.collection(UsuarioModel.collection).document(userId);
    var snap = await docRef.get();
    List<dynamic> routes = List<dynamic>();
    routes.addAll(snap.data['routes']);
    // print(routes.runtimeType);
    routes.addAll([
      //Drawer
      // '/',
      // '/upload',
      // '/questionario/home',
      // '/aplicacao/home',
      // '/resposta/home',
      // '/sintese/home',
      // '/produto/home',
      // '/comunicacao/home',
      // '/administracao/home',
      // '/controle/home',
      // "/perfil/configuracao",
      // endDrawer
      '/perfil/configuracao',
      '/perfil',
      // '/painel/home',
      '/modooffline',
      "/versao",
    ]);

    await docRef.setData({"routes": routes}, merge: true);
  }

  Future cadastrarAlunoCatalunha() async {
    String userId = 'PMAxu4zKfmaOlYAmF3lgFGmCR1w2';
    final docRef =
        _firestore.collection(UsuarioModel.collection).document(userId);
    docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
      id: userId,
      aluno: true,
      ativo: true,
      celular: '123',
      cracha: 'Marcio',
      email: 'catalunha.mj@gmail.com',
      foto: UploadFk(uploadID: 'NFnVSDPpbOwQejMu1jXh'),
      matricula: '20019123',
      nome: 'Marcio J Catalunha',
      rota: [
        '/',
        '/perfil',
        '/upload',
        '/versao',
        '/desenvolvimento',
        '/turma/list',
      ],
    );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarProfCatalunha() async {
    String userId = 'hZyF8tQoXDWPNgUQSof5K3TnS7h1';
    final docRef =
        _firestore.collection(UsuarioModel.collection).document(userId);
    await docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
      id: userId,
      aluno: false,
      ativo: true,
      celular: '456',
      cracha: 'Catalunha',
      email: 'catalunha@uft.edu.br',
      matricula: '007',
      nome: 'Catalunha, MJ',
      rota: [
        '/',
        '/perfil',
        '/upload',
        '/versao',
        '/desenvolvimento',
        '/turma/ativa/list',
      ],
      turmaNumeroAdicionado:0,
      grupoNumeroAdicionado:0,
    );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarTarefa(String tarefaId) async {
    final docRef =
        _firestore.collection(TarefaModel.collection).document(tarefaId);
    docRef.delete();
    TarefaModel tarefaModel = TarefaModel(
        id: tarefaId,
        ativo: true,
        professor: UsuarioFk(id: '0Prof01', nome: 'prof01'),
        turma: TurmaFk(id: '0Turma01', nome: 'turma01'),
        avaliacao: AvaliacaoFk(id: '0Avaliacao01', nome: 'avaliacao01'),
        questao: QuestaoFk(id: '0Questao01', numero: 1),
        aluno: UsuarioFk(id: 'PMAxu4zKfmaOlYAmF3lgFGmCR1w2', nome: 'Cata'),
        modificado: DateTime.now(),
        inicio: DateTime.parse('2019-10-31T18:00:00-0300'),
        // iniciou: DateTime.parse('2019-10-29T09:00:00.000Z'),
        // enviou: DateTime.parse('2019-10-29T09:30:00.000Z'),
        fim: DateTime.parse('2019-10-31T23:00:00-0300'),
        tentativa: 5,
        // tentou: 0,
        tempo: 1,
        aberta: true,
        situacao: SituacaoFk(
          id: '0situacao01',
          nome: 'situacao01',
          erroRelativo: '10',
          url:
              'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a',
        ),
        simulacao: 'simulacao01',
        variavel: {
          'var01': Variavel(
            nome: 'N1',
            ordem: 0,
            valor: '1',
          ),
          'var02': Variavel(
            nome: 'N2',
            ordem: 1,
            valor: '2',
          )
        },
        pedese: {
          'pedese01':
              Pedese(nome: 'a', ordem: 0, tipo: 'numero', gabarito: '20'),
          'pedese02':
              Pedese(nome: 'b', ordem: 1, tipo: 'palavra', gabarito: 'sim'),
          'pedese03':
              Pedese(nome: 'c', ordem: 2, tipo: 'texto', gabarito: 'sim'),
          'pedese04': Pedese(nome: 'd', ordem: 3, tipo: 'url', gabarito: 'sim'),
          'pedese05':
              Pedese(nome: 'e', ordem: 4, tipo: 'arquivo', gabarito: 'sim'),
          'pedese06':
              Pedese(nome: 'f', ordem: 5, tipo: 'imagem', gabarito: 'sim'),
        });

    // print('=>>>>>>>> ${tarefaModel.aberta}');
    await docRef.setData(tarefaModel.toMap(), merge: true);
    // await docRef.setData(tarefaModel.toMap());
  }

  Future cadastrarTurma01() async {
    String turmaId = '0Turma01';

    final docRef =
        _firestore.collection(TurmaModel.collection).document(turmaId);
    await docRef.delete();
    TurmaModel turmaModel = TurmaModel(
      id: turmaId,
      ativo: true,
      numero: 1,
      instituicao: 'UFT',
      componente: 'CN',
      nome: 'cn2020.1',
      descricao: 'turma legal',
      professor: UsuarioFk(id: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1', nome: 'Catalunha, MJ'),
      alunoList: ['PMAxu4zKfmaOlYAmF3lgFGmCR1w2'],
      questaoNumeroAdicionado:0,
      questaoNumeroExcluido:0

    );

    await docRef.setData(turmaModel.toMap(), merge: true);
  }

  Future cadastrarAvaliacao(String avaliacaoId) async {
    final docRef =
        _firestore.collection(AvaliacaoModel.collection).document(avaliacaoId);
    docRef.delete();
    AvaliacaoModel avaliacaoModel = AvaliacaoModel(
      id: avaliacaoId,
      ativo: true,
      professor: UsuarioFk(id: '0Prof01', nome: 'prof01'),
      turma: TurmaFk(id: '0Turma01', nome: '0Turma01'),
      nome: 'P01',
      descricao: 'boa prova',
      inicio: DateTime.parse('2019-10-30T18:00:00-0300'),
      fim: DateTime.parse('2019-10-30T23:00:00-0300'),
      nota: '1',
      aplicada: true,
      aplicadaPAluno: ['PMAxu4zKfmaOlYAmF3lgFGmCR1w2'],
    );

    await docRef.setData(avaliacaoModel.toMap(), merge: true);
  }

  Future cadastrarQuestao(String questaoId) async {
    final docRef =
        _firestore.collection(QuestaoModel.collection).document(questaoId);
    docRef.delete();
    QuestaoModel questaoModel = QuestaoModel(
      id: questaoId,
      ativo: true,
      numero: 1,
      professor: UsuarioFk(id: '0Prof01', nome: 'prof01'),
      turma: TurmaFk(id: '0Turma01', nome: 'turma01'),
      avaliacao: AvaliacaoFk(id: '0Avaliacao01', nome: 'avaliacao01'),
      situacao: SituacaoFk(
        id: '0situacao01',
        nome: 'situacao01',
        erroRelativo: '10',
        url:
            'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a',
      ),
      inicio: DateTime.parse('2019-10-30T18:00:00-0300'),
      fim: DateTime.parse('2019-10-30T23:00:00-0300'),
      tentativa: 5,
      tempo: 1,
      nota: '1',
    );
    await docRef.setData(questaoModel.toMap(), merge: true);
  }

  Future testarFirebaseCmds() async {
    // print('+++ testarFirebaseCmds');
    UsuarioModel usuarioModel = UsuarioModel(
      id: 'PMAxu4zKfmaOlYAmF3lgFGmCR1w2',
      foto: UploadFk(uploadID: 'NFnVSDPpbOwQejMu1jXh', url: null),
    );
    final docRef = _firestore
        .collection(UsuarioModel.collection)
        .document('PMAxu4zKfmaOlYAmF3lgFGmCR1w2');
    await docRef.setData(usuarioModel.toMap(), merge: true);

    // final docRef = await _firestore
    //     .collection(UsuarioModel.collection)
    //     .where('routes', arrayContains: '/comunicacao/home')
    //     .getDocuments();
    // for (var item in docRef.documents) {
    //   print('Doc encontrados: ${item.documentID}');
    // }
    // print('--- testarFirebaseCmds');
  }
}
