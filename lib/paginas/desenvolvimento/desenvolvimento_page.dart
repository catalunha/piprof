import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firestore_wrapper/firestore_wrapper.dart' as fw;
import 'package:piprof/bootstrap.dart';
import 'package:piprof/componentes/default_scaffold.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/questao_model.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/upload_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:piprof/modelos/usuario_novo_model.dart';

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
                  // await cadastrarProfCatalunha();
                  // await cadastrarProfRicelly();
                  // await cadastrarFabin();
                },
              ),
            ),
            ListTile(
              title: Text('Criar Usuario Aluno.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await cadastrarAlunoCatalunha();
                  // await cadastrarAlunoLucas();
                  // await usuarioNovoAlunoDaniel();
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
                  // await cadastrarTarefa01();
                  // await cadastrarTarefa02();
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Turma.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await cadastrarTurma01();
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Avaliacao.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await cadastrarAvaliacao('0Avaliacao01');
                },
              ),
            ),
            ListTile(
              title: Text('Cadastrar Questao.'),
              trailing: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () async {
                  // await cadastrarQuestao('0Questao01');
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
            ListTile(
              title: Text('Inserir pasta'),
              trailing: IconButton(
                icon: Icon(Icons.folder),
                onPressed: () async {
                  // await incluirPasta(
                  //   pastaID: '0Pasta01',
                  //   nome: 'pasta01',
                  //   professorID: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1',
                  // );
                  // await incluirPasta(
                  //   pastaID: '0Pasta02',
                  //   nome: 'pasta02',
                  //   professorID: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1',
                  // );
                },
              ),
            ),
            ListTile(
              title: Text('Inserir Problema'),
              trailing: IconButton(
                icon: Icon(Icons.folder),
                onPressed: () async {
                  // await incluirProblema01();
                  // await incluirProblema02();
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
    var collRef = await _firestore.collection(UsuarioModel.collection).getDocuments();

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

        await documentSnapshot.reference.setData({"routes": routes}, merge: true);
      } else {
        // print('Sem routes ${documentSnapshot.documentID}');
      }
    }
  }

  Future atualizarRotaIndividual(String userId) async {
    final docRef = _firestore.collection(UsuarioModel.collection).document(userId);
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
    final docRef = _firestore.collection(UsuarioModel.collection).document(userId);
    docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
        id: userId,
        professor: false,
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
        turma: [
          '0Turma01'
        ]);
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarAlunoLucas() async {
    String userId = 'alunoLucas';
    final docRef = _firestore.collection(UsuarioModel.collection).document(userId);
    docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
      id: userId,
      professor: false,
      ativo: true,
      celular: '123',
      cracha: 'Lucas',
      email: 'lucas@gmail.com',
      foto: UploadFk(uploadID: 'uploadLucas'),
      matricula: '20091021',
      nome: 'Lucas L Catalunha',
      rota: [
        '/',
        '/perfil',
        '/upload',
        '/versao',
        '/turma/list',
      ],
    );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future usuarioNovoAlunoDaniel() async {
    // String userId = 'usuarioNovoDaniel';
    final docRef = _firestore.collection(UsuarioNovoModel.collection).document();

    UsuarioNovoModel usuarioModel = UsuarioNovoModel(
        ativo: true,
        email: 'daniel@gmail.com',
        matricula: '20110924',
        nome: 'Daniel L Catalunha',
        turma: '0Turma02',
        rota: [
          '/',
          '/perfil',
          '/upload',
          '/versao',
          '/turma/list',
        ],
        );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarProfCatalunha() async {
    String userId = 'hZyF8tQoXDWPNgUQSof5K3TnS7h1';
    final docRef = _firestore.collection(UsuarioModel.collection).document(userId);
    await docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
      id: userId,
      professor: true,
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
      turmaNumero: 0,
      pastaNumero: 0,
      problemaNumero: 0,
    );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarProfRicelly() async {
    String userId = 'KTLy0I7crCRzQFVEI0mMOBk3VwE2';
    final docRef = _firestore.collection(UsuarioModel.collection).document(userId);
    await docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
      id: userId,
      professor: true,
      ativo: true,
      celular: '7070',
      cracha: 'vó',
      email: 'ricelly.catalunha@gmail.com',
      matricula: '007',
      nome: 'Ricelly MLS Catalunha',
      rota: [
        '/',
        '/perfil',
        '/upload',
        '/versao',
        '/turma/ativa/list',
        '/pasta/list',
        '/turma/inativa/list',
      ],
      turmaNumero: 0,
      pastaNumero: 0,
      problemaNumero: 0,
    );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarFabin() async {
    String userId = 'PSI0UXpC3rPb91bDXyEWVUVYyV92';
    final docRef = _firestore.collection(UsuarioModel.collection).document(userId);
    await docRef.delete();
    UsuarioModel usuarioModel = UsuarioModel(
      id: userId,
      professor: true,
      ativo: true,
      // celular: '123',
      // cracha: 'Costa',
      email: 'ambiental.costa@gmail.com',
      matricula: '123',
      nome: 'Fabio Costa',
      rota: [
        '/',
        '/perfil',
        '/upload',
        '/versao',
        '/turma/ativa/list',
        '/turma/inativa/list',
        '/pasta/list',
      ],
      turmaNumero: 0,
      pastaNumero: 0,
      problemaNumero: 0,
    );
    await docRef.setData(usuarioModel.toMap(), merge: true);
  }

  Future cadastrarTarefa01() async {
    final docRef = _firestore.collection(TarefaModel.collection).document();
    docRef.delete();
    TarefaModel tarefaModel = TarefaModel(
        ativo: true,
        professor: UsuarioFk(id: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1', nome: 'prof01'),
        turma: TurmaFk(id: '0Turma01', nome: 'cn2020.1'),
        avaliacao: AvaliacaoFk(id: 'lxXRTA56hCmoW718NrW5', nome: 'a'),
        questao: QuestaoFk(id: 'pdPfwz2YCmgw42NKlnbF', numero: 2),
        aluno: UsuarioFk(
            id: 'PMAxu4zKfmaOlYAmF3lgFGmCR1w2',
            nome: 'Cata',
            foto:
                'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086'),
        modificado: DateTime.now(),
        inicio: DateTime.parse('2019-10-31T18:00:00-0300'),
        // iniciou: DateTime.parse('2019-10-29T09:00:00.000Z'),
        // enviou: DateTime.parse('2019-10-29T09:30:00.000Z'),
        fim: DateTime.parse('2019-10-31T23:00:00-0300'),
        tentativa: 3,
        // tentou: 0,
        tempo: 1,
        erroRelativo: 10,
        avaliacaoNota: '1',
        questaoNota: '1',
        aberta: true,
        problema: ProblemaFk(
          id: '548KCdtFN8Vr1j1U2WvZ',
          nome: 'sit02',
          url:
              'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a',
        ),
        // simulacao: 'simulacao01',
        variavel: {
          'var01': Variavel(
            nome: 'v1',
            ordem: 1,
            valor: '1',
            tipo: 'numero',
          ),
          'var02': Variavel(
            nome: 'v2',
            ordem: 2,
            valor: 'a',
            tipo: 'palavra',
          ),
          'var03': Variavel(
            nome: 'v3',
            ordem: 3,
            valor: 'b bb bbb',
            tipo: 'texto',
          ),
          'var04': Variavel(
            nome: 'v4',
            ordem: 4,
            valor: 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086',
            tipo: 'url',
          ),
          'var05': Variavel(
            nome: 'v5',
            ordem: 5,
            valor: 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086',
            tipo: 'urlimagem',
          )
        },
        gabarito: {
          'valor01': Gabarito(nome: 'a', ordem: 1, nota:0, tipo: 'numero', valor: '20', resposta:'20'),
          'valor02': Gabarito(nome: 'b', ordem: 2, nota:0, tipo: 'palavra', valor: 'sim', resposta:'sim'),
          'valor03': Gabarito(nome: 'c', ordem: 3, nota:0, tipo: 'texto', valor: 'sim ou nao', resposta:'sim ou nao'),
          'valor04': Gabarito(nome: 'd', ordem: 4, nota:0, tipo: 'url', valor: 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a', resposta:'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a'),
          'valor05': Gabarito(nome: 'e', ordem: 5, nota:0, tipo: 'urlimagem', valor: 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086', resposta:'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086'),
          'valor06': Gabarito(nome: 'f', ordem: 6, nota:0, tipo: 'arquivo', valor: 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a', resposta:'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a'),
          'valor07': Gabarito(nome: 'g', ordem: 7, nota:0, tipo: 'imagem', valor: 'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086', resposta:'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/50d5473f-6a8d-4f3a-830b-5b87d02dc57d?alt=media&token=ffc4ab3b-4aab-45fc-8ded-3c8957184086'),
        });

    // print('=>>>>>>>> ${tarefaModel.aberta}');
    await docRef.setData(tarefaModel.toMap(), merge: true);
    // await docRef.setData(tarefaModel.toMap());
  }

  Future cadastrarTarefa02() async {
    final docRef = _firestore.collection(TarefaModel.collection).document();
    docRef.delete();
    TarefaModel tarefaModel = TarefaModel(
        ativo: true,
        professor: UsuarioFk(id: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1', nome: 'prof01'),
        turma: TurmaFk(id: '0Turma01', nome: 'cn2020.1'),
        avaliacao: AvaliacaoFk(id: 'lxXRTA56hCmoW718NrW5', nome: 'a'),
        questao: QuestaoFk(id: 'jaQKHFRFw1OerhiY4nNM', numero: 3),
        aluno: UsuarioFk(
            id: 'alunoDaniel',
            nome: 'Daniel',
            foto:
                'https://cptstatic.s3.amazonaws.com/imagens/enviadas/materias/materia9575/peixe-andira-cursos-cpt.jpg'),
        modificado: DateTime.now(),
        inicio: DateTime.parse('2019-10-31T18:00:00-0300'),
        // iniciou: DateTime.parse('2019-10-29T09:00:00.000Z'),
        // enviou: DateTime.parse('2019-10-29T09:30:00.000Z'),
        fim: DateTime.parse('2019-10-31T23:00:00-0300'),
        tentativa: 3,
        // tentou: 0,
        tempo: 1,
        aberta: true,
        problema: ProblemaFk(
          id: '548KCdtFN8Vr1j1U2WvZ',
          nome: 'sit02',
          url:
              'https://firebasestorage.googleapis.com/v0/b/pi-brintec.appspot.com/o/texto_base.pdf?alt=media&token=617247d1-e4ae-452f-b79a-16a964a6745a',
        ),
        // simulacao: 'simulacao01',
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
        gabarito: {
          'valor01': Gabarito(nome: 'a', ordem: 0, tipo: 'numero', valor: '20'),
          'valor02': Gabarito(nome: 'b', ordem: 1, tipo: 'palavra', valor: 'sim'),
          'valor03': Gabarito(nome: 'c', ordem: 2, tipo: 'texto', valor: 'sim'),
          'valor04': Gabarito(nome: 'd', ordem: 3, tipo: 'url', valor: 'sim'),
          'valor05': Gabarito(nome: 'e', ordem: 4, tipo: 'arquivo', valor: 'sim'),
          'valor06': Gabarito(nome: 'f', ordem: 5, tipo: 'imagem', valor: 'sim'),
        });

    // print('=>>>>>>>> ${tarefaModel.aberta}');
    await docRef.setData(tarefaModel.toMap(), merge: true);
    // await docRef.setData(tarefaModel.toMap());
  }

  Future cadastrarTurma01() async {
    String turmaId = '0Turma01';

    final docRef = _firestore.collection(TurmaModel.collection).document(turmaId);
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
        questaoNumero: 0,
        );

    await docRef.setData(turmaModel.toMap(), merge: true);
  }

  Future cadastrarTurma02() async {
    String turmaId = '0Turma02';

    final docRef = _firestore.collection(TurmaModel.collection).document(turmaId);
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
        questaoNumero: 0,
       );

    await docRef.setData(turmaModel.toMap(), merge: true);
  }

  Future cadastrarAvaliacao(String avaliacaoId) async {
    final docRef = _firestore.collection(AvaliacaoModel.collection).document(avaliacaoId);
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
    final docRef = _firestore.collection(QuestaoModel.collection).document(questaoId);
    docRef.delete();
    QuestaoModel questaoModel = QuestaoModel(
      id: questaoId,
      ativo: true,
      numero: 1,
      professor: UsuarioFk(id: '0Prof01', nome: 'prof01'),
      turma: TurmaFk(id: '0Turma01', nome: 'turma01'),
      avaliacao: AvaliacaoFk(id: '0Avaliacao01', nome: 'avaliacao01'),
      problema: ProblemaFk(
        id: '0problema01',
        nome: 'problema01',
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
    final docRef = _firestore.collection(UsuarioModel.collection).document('PMAxu4zKfmaOlYAmF3lgFGmCR1w2');
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

  Future incluirPasta({String pastaID, String nome, String professorID}) async {
    final docRef = _firestore.collection(PastaModel.collection).document(pastaID);
    docRef.delete();
    PastaModel pastaModel = PastaModel(
      id: pastaID,
      ativo: true,
      numero: 2,
      nome: 'Pasta?',
      professor: UsuarioFk(id: professorID, nome: 'prof01'),
    );
    await docRef.setData(pastaModel.toMap(), merge: true);
  }

  Future incluirProblema01() async {
    final docRef = _firestore.collection(ProblemaModel.collection).document();
    ProblemaModel problemaModel = ProblemaModel(
      ativo: true,
      numero: 1,
      nome: 'Sit01',
      professor: UsuarioFk(id: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1', nome: 'prof01'),
      pasta: PastaFk(id: '0Pasta01', nome: 'pasta01'),
    );
    await docRef.setData(problemaModel.toMap(), merge: true);
  }

  Future incluirProblema02() async {
    final docRef = _firestore.collection(ProblemaModel.collection).document();
    ProblemaModel problemaModel = ProblemaModel(
      ativo: true,
      numero: 2,
      nome: 'Sit02',
      professor: UsuarioFk(id: 'hZyF8tQoXDWPNgUQSof5K3TnS7h1', nome: 'prof01'),
      pasta: PastaFk(id: '0Pasta01', nome: 'pasta01'),
    );
    await docRef.setData(problemaModel.toMap(), merge: true);
  }
}
