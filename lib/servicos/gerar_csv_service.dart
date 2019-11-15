import 'package:piprof/bootstrap.dart';
import 'package:piprof/modelos/avaliacao_model.dart';
import 'package:piprof/modelos/encontro_model.dart';
import 'package:piprof/modelos/pasta_model.dart';
import 'package:piprof/modelos/simulacao_model.dart';
import 'package:piprof/modelos/problema_model.dart';
import 'package:piprof/modelos/tarefa_model.dart';
import 'package:piprof/modelos/turma_model.dart';
import 'package:piprof/modelos/usuario_model.dart';
import 'package:queries/collections.dart';
import 'package:universal_io/io.dart';
import 'package:piprof/naosuportato/open_file.dart'
    if (dart.library.io) 'package:open_file/open_file.dart';
import 'package:piprof/naosuportato/path_provider.dart'
    if (dart.library.io) 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class GenerateCsvService {
  // PUBLIC

  static csvTurmaListaAluno(TurmaModel turma) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();

    planilha.add(['Turma', 'Informacao']);
    planilha.add(['id', '${turma.id}']);
    planilha.add(['ativo', '${turma.ativo}']);
    planilha.add(['nome', '${turma.nome}']);
    planilha.add(['instituicao', '${turma.instituicao}']);
    planilha.add(['componente', '${turma.componente}']);
    planilha.add(['descricao', '${turma.descricao}']);
    planilha.add([
      'questoes',
      '${turma.questaoNumeroAdicionado - turma.questaoNumeroExcluido}'
    ]);

    final futureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(UsuarioModel.collection)
        // .where("ativo", isEqualTo: true)
        .where("turmaList", arrayContains: turma.id)
        .getDocuments();
    List<UsuarioModel> usuarioList = futureQuerySnapshot.documents
        .map((doc) => UsuarioModel(id: doc.documentID).fromMap(doc.data))
        .toList();


    planilha.add([
      'foto',
      'nome',
      'matricula',
      'email',
      'celular',
      'cracha',
    ]);
    for (var usuario in usuarioList) {
      
      planilha.add([
        '=IMAGE("${usuario.foto.url}")',
        '${usuario.nome}',
        '${usuario.matricula}',
        '${usuario.email}',
        '${usuario.celular}',
        '${usuario.cracha}',
      ]);
    }

// print(planilha.toList());
    String csvData =
        ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    // print('+++ generateCsvFromUsuarioListDaTurma\n$csvData\n--- generateCsvFromUsuarioListDaTurma');
    // _saveFileAndOpen(csvData);
  }

  static csvAlunoListaNota(UsuarioModel usuario) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();
    planilha.add(['Aluno', 'Informacao']);
    planilha.add(['id', '${usuario.id}']);
    planilha.add(['ativo', '${usuario.ativo}']);
    planilha.add(['nome', '${usuario.nome}']);
    planilha.add(['matricula', '${usuario.matricula}']);
    planilha.add(['email', '${usuario.email}']);
    planilha.add(['cracha', '${usuario.cracha}']);
    planilha.add(['celular', '${usuario.celular}']);
    planilha.add(['foto', '=IMAGE("${usuario.foto.url}")']);


    final futureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(TarefaModel.collection)
        .where("aluno.id", isEqualTo: usuario.id)
        .getDocuments();

    List<TarefaModel> tarefaList = futureQuerySnapshot.documents
        .map((doc) => TarefaModel(id: doc.documentID).fromMap(doc.data))
        .toList();

    Map<String, Variavel> variavelMap = Map<String, Variavel>();
    Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();

    planilha.add([
      'Avaliacao',
      'Questao',
      'Item',
      'Valor',
    ]);
    for (var tarefa in tarefaList) {

      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'id',
        '${tarefa.id}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'aberta',
        '${tarefa.aberta}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'ativa',
        '${tarefa.ativo}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'avaliacao',
        '${tarefa.avaliacao.nome}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'questao',
        '${tarefa.questao.numero}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'problema nome',
        '${tarefa.problema.nome}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'problema arquivo',
        '=HYPERLINK("${tarefa.problema.url}";"Link para o arquivo")'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'tempo',
        '${tarefa.tempo}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'tentativa',
        '${tarefa.tentativa}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'tentou',
        '${tarefa.tentou}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'inicio',
        '${tarefa.inicio}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'iniciou',
        '${tarefa.iniciou}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'enviou',
        '${tarefa.enviou}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'fim',
        '${tarefa.fim}'
      ]);
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'modificado',
        '${tarefa.modificado}'
      ]);

      var dicVariavel = Dictionary.fromMap(tarefa.variavel);
      var variavelOrdered = dicVariavel
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      variavelMap.clear();
      variavelMap = variavelOrdered.toMap();

      for (var variavel in variavelMap.entries) {
        // print(variavel.key);
        planilha.add([
          '${tarefa.avaliacao.nome}',
          '${tarefa.questao.numero}',
          'variavel nome',
          '${variavel.value.nome}'
        ]);
        planilha.add([
          '${tarefa.avaliacao.nome}',
          '${tarefa.questao.numero}',
          'variavel valor',
          '${variavel.value.valor}'
        ]);
      }

      var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
      var gabaritoOrderBy = dicGabarito
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      gabaritoMap.clear();
      gabaritoMap = gabaritoOrderBy.toMap();
      String nota = '=';
      for (var gabarito in gabaritoMap.entries) {
        // print(gabarito.key);

        nota = nota + '+${gabarito.value.nota}';
        planilha.add([
          '${tarefa.avaliacao.nome}',
          '${tarefa.questao.numero}',
          'gabarito nome',
          '${gabarito.value.nome}'
        ]);
        if (gabarito.value.tipo == 'numero' ||
            gabarito.value.tipo == 'palavra' ||
            gabarito.value.tipo == 'texto') {
          planilha.add([
            '${tarefa.avaliacao.nome}',
            '${tarefa.questao.numero}',
            'gabarito resposta',
            '${gabarito.value.resposta}'
          ]);
        } else if (gabarito.value.tipo == 'imagem') {
          planilha.add([
            '${tarefa.avaliacao.nome}',
            '${tarefa.questao.numero}',
            'gabarito resposta',
            '=IMAGE("${gabarito.value.resposta}")',
          ]);
        } else if (gabarito.value.tipo == 'arquivo' ||
            gabarito.value.tipo == 'url') {
          planilha.add([
            '${tarefa.avaliacao.nome}',
            '${tarefa.questao.numero}',
            'gabarito resposta',
            '=HYPERLINK("${gabarito.value.resposta}","Link para o arquivo")'
          ]);
        }
        planilha.add([
          '${tarefa.avaliacao.nome}',
          '${tarefa.questao.numero}',
          'gabarito nota',
          '${gabarito.value.nota}'
        ]);
      }
      planilha.add([
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        'notaTotal',
        '$nota'
      ]);
    }
    String csvData =
        ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    // print('+++ generateCsvFromUsuarioModel\n$csvData\n--- generateCsvFromUsuarioModel');
    // _saveFileAndOpen(csvData);
  }

  static csvEncontro(String turmaID) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();

    final encontroFutureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(EncontroModel.collection)
        .where("turma.id", isEqualTo: turmaID)
        .getDocuments();
    var encontroList = encontroFutureQuerySnapshot.documents
        .map((doc) => EncontroModel(id: doc.documentID).fromMap(doc.data))
        .toList();
    encontroList.sort((a, b) => a.inicio.compareTo(b.inicio));

    final alunoFutureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(UsuarioModel.collection)
        .where("turma", arrayContains: turmaID)
        .getDocuments();
    var alunoList = alunoFutureQuerySnapshot.documents
        .map((doc) => UsuarioModel(id: doc.documentID).fromMap(doc.data))
        .toList();
    alunoList.sort((a, b) => a.nome.compareTo(b.nome));
    Map<String, UsuarioModel> alunoMap = Map<String, UsuarioModel>();
    for (var aluno in alunoList) {
      alunoMap[aluno.id] = aluno;
    }

    planilha.add([
      'inicio',
      'fim',
      'modificado',
      'nome',
      'descricao',
      'turma',
      'aluno',
      'foto',
      'celular',
      'matricula',
      'email',
    ]);
    for (var encontro in encontroList) {
      planilha.add([
        '${encontro.inicio}',
        '${encontro.fim}',
        '${encontro.modificado}',
        '${encontro.nome}',
        '${encontro.descricao}',
        '-',
        '-',
        '-',
        '-',
        '-',
      ]);
      for (var aluno in encontro.aluno) {
        planilha.add([
          '${encontro.inicio}',
          '${encontro.fim}',
          '${encontro.modificado}',
          '${encontro.nome}',
          '${encontro.descricao}',
          '${alunoMap[aluno].nome}',
          '=IMAGE("${alunoMap[aluno].foto.url}")',
          '${alunoMap[aluno].celular}',
          '${alunoMap[aluno].matricula}',
          '${alunoMap[aluno].email}',
        ]);
      }
    }

    String csvData =
        ListToCsvConverter().convert(planilha, fieldDelimiter: ';');
    print('+++ generateCsvFromEncontro\n$csvData\n--- generateCsvFromEncontro');
    _saveFileAndOpen(csvData);
  }

  static csvAvaliacaoListaNota(AvaliacaoModel avaliacao) async {
    print('csvNotasDaAvaliacao...');
    List<List<dynamic>> planilha = List<List<dynamic>>();
    planilha.add(['Turma', 'Informacao']);
    planilha.add(['id', '${avaliacao.turma.id}']);
    planilha.add(['nome', '${avaliacao.turma.nome}']);

    planilha.add(['Avaliacao', 'Informacao']);
    planilha.add(['id', '${avaliacao.id}']);
    planilha.add(['nome', '${avaliacao.nome}']);
    planilha.add(['descricao', '${avaliacao.descricao}']);
    planilha.add(['inicio', '${avaliacao.inicio}']);
    planilha.add(['fim', '${avaliacao.fim}']);

    final futureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(TarefaModel.collection)
        .where("avaliacao.id", isEqualTo: avaliacao.id)
        .getDocuments();

    List<TarefaModel> tarefaList = futureQuerySnapshot.documents
        .map((doc) => TarefaModel(id: doc.documentID).fromMap(doc.data))
        .toList();

    // Map<String, Variavel> variavelMap = Map<String, Variavel>();
    Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();

    planilha.add([
      'avaliacao',
      'questao',
      'problema_nome',
      'problema_url',
      'simulacao',
      'aluno_nome',
      'aluno_foto',
      'avaliacao_nota',
      'questao_nota',
      'item',
      'valor',
    ]);
    for (var tarefa in tarefaList) {
      // TarefaModel tarefa = TarefaModel(id: tarefaDocSnapshot.documentID)
      //     .fromMap(tarefaDocSnapshot.data);
      var base = [
        '${tarefa.avaliacao.nome}',
        '${tarefa.questao.numero}',
        '${tarefa.problema.nome}',
        '=HYPERLINK("${tarefa.problema.url}";"Link para a problema")',
        '${tarefa.simulacao}',
        '${tarefa.aluno.nome}',
        '=IMAGE("${tarefa.aluno.foto}")',
        '${tarefa.avaliacaoNota}',
        '${tarefa.questaoNota}',
      ];
      // var dicVariavel = Dictionary.fromMap(tarefa.variavel);
      // var variavelOrdered = dicVariavel
      //     .orderBy((kv) => kv.value.ordem)
      //     .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      // variavelMap.clear();
      // variavelMap = variavelOrdered.toMap();

      // for (var variavel in variavelMap.entries) {
      //   print(variavel.key);
      //   planilha.add([
      //     '${tarefa.avaliacao.nome}',
      //     '${tarefa.questao.numero}',
      //     'variavel nome',
      //     '${variavel.value.nome}'
      //   ]);
      //   planilha.add([
      //     '${tarefa.avaliacao.nome}',
      //     '${tarefa.questao.numero}',
      //     'variavel valor',
      //     '${variavel.value.valor}'
      //   ]);
      // }

      var dicGabarito = Dictionary.fromMap(tarefa.gabarito);
      var gabaritoOrderBy = dicGabarito
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      gabaritoMap.clear();
      gabaritoMap = gabaritoOrderBy.toMap();
      String nota = '=';
      for (var gabarito in gabaritoMap.entries) {
        // print(gabarito.key);
        nota = nota + '+${gabarito.value.nota}';
        // planilha.add([
        //   '${tarefa.avaliacao.nome}',
        //   '${tarefa.questao.numero}',
        //   'gabarito nome',
        //   '${gabarito.value.nome}'
        // ]);
        // if (gabarito.value.tipo == 'numero' ||
        //     gabarito.value.tipo == 'palavra' ||
        //     gabarito.value.tipo == 'texto') {
        //   planilha.add([
        //     '${tarefa.avaliacao.nome}',
        //     '${tarefa.questao.numero}',
        //     'gabarito resposta',
        //     '${gabarito.value.resposta}'
        //   ]);
        // } else if (gabarito.value.tipo == 'imagem') {
        //   planilha.add([
        //     '${tarefa.avaliacao.nome}',
        //     '${tarefa.questao.numero}',
        //     'gabarito resposta',
        //     '=IMAGE("${gabarito.value.resposta}")',
        //   ]);
        // } else if (gabarito.value.tipo == 'arquivo' ||
        //     gabarito.value.tipo == 'url') {
        //   planilha.add([
        //     '${tarefa.avaliacao.nome}',
        //     '${tarefa.questao.numero}',
        //     'gabarito resposta',
        //     '=HYPERLINK("${gabarito.value.resposta}","Link para o arquivo")'
        //   ]);
        // }
        // planilha.add([
        //   '${tarefa.avaliacao.nome}',
        //   '${tarefa.questao.numero}',
        //   'gabarito nota',
        //   '${gabarito.value.nota}'
        // ]);
      }
      planilha.add([
        ...base,
        'gabarito_nota',
        '$nota',
      ]);

      // planilha.add([
      //   ...base,
      //   'tarefa_id',
      //   '${tarefa.id}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'modificado',
      //   '${tarefa.modificado}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'inicio',
      //   '${tarefa.inicio}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'iniciou',
      //   '${tarefa.iniciou}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'enviou',
      //   '${tarefa.enviou}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'fim',
      //   '${tarefa.fim}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'tentativa',
      //   '${tarefa.tentativa}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'tentou',
      //   '${tarefa.tentou}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'tempo',
      //   '${tarefa.tempo}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'aberta',
      //   '${tarefa.aberta}',
      // ]);
      // planilha.add([
      //   ...base,
      //   'erroRelativo',
      //   '${tarefa.erroRelativo}',
      // ]);

    }
    String csvData =
        ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    // print('+++ generateCsvFromUsuarioModel\n$csvData\n--- generateCsvFromUsuarioModel');
    _saveFileAndOpen(csvData);
  }

  static csvPastaListaProblema(List<PastaModel> pastaList) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();

    planilha.add([
      'pasta_nome',
      'pasta_descricao',
      'problema_nome',
      'problema_descricao',
      'problema_uso',
      'problema_algoritmo',
      'problema_url',
    ]);
    for (var pasta in pastaList) {
      final futureQuerySnapshot = await Bootstrap.instance.firestore
          .collection(ProblemaModel.collection)
          .where("pasta.id", isEqualTo: pasta.id)
          .getDocuments();

      List<ProblemaModel> problemaList = futureQuerySnapshot.documents
          .map((doc) => ProblemaModel(id: doc.documentID).fromMap(doc.data))
          .toList();
      var base = [
        '${pasta.nome}',
        '${pasta.descricao}',
      ];
      int usoTotal = 0;
      for (var problema in problemaList) {
        usoTotal = 0;
        if (problema?.uso != null) {
          for (var uso in problema.uso?.entries) {
            usoTotal = usoTotal + uso.value;
          }
        }
        planilha.add([
          ...base,
          '${problema.nome}',
          '${problema.descricao}',
          '$usoTotal',
          '${problema.precisaAlgoritmoPSimulacao}',
          '=HYPERLINK("${problema.url}";"Link para a problema")',
        ]);
      }
    }

// print(planilha.toList());
    String csvData =
        ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    // print('+++ generateCsvFromUsuarioListDaTurma\n$csvData\n--- generateCsvFromUsuarioListDaTurma');
    _saveFileAndOpen(csvData);
  }

  static csvProblemaListaSimulacao(ProblemaModel problema) async {
    List<List<dynamic>> planilha = List<List<dynamic>>();

    final futureQuerySnapshot = await Bootstrap.instance.firestore
        .collection(SimulacaoModel.collection)
        .where("problema.id", isEqualTo: problema.id)
        .getDocuments();

    List<SimulacaoModel> simulacaoList = futureQuerySnapshot.documents
        .map((doc) => SimulacaoModel(id: doc.documentID).fromMap(doc.data))
        .toList();
    planilha.add([
      'pasta_nome',
      'problema_nome',
      'problema_descricao',
      'problema_url',
      'simulacao_nome',
      'simulacao_descricao',
      'simulacao_url',
      'item',
      'valor',
    ]);

    var base1 = [
      '${problema.pasta.nome}',
      '${problema.nome}',
      '${problema.descricao}',
      '=HYPERLINK("${problema.url}";"Link para a problema")',
    ];
    Map<String, Variavel> variavelMap = Map<String, Variavel>();
    Map<String, Gabarito> gabaritoMap = Map<String, Gabarito>();
    for (var simulacao in simulacaoList) {
      var base2 = [
        '${simulacao.nome}',
        '${simulacao.descricao}',
        '=HYPERLINK("${simulacao.url}";"Link para a simulacao")',
      ];
      var dicVariavel = Dictionary.fromMap(simulacao.variavel);
      var variavelOrdered = dicVariavel
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      variavelMap.clear();
      variavelMap = variavelOrdered.toMap();
      for (var variavel in variavelMap.entries) {
        planilha.add([
          ...base1,
          ...base2,
          'variavel_nome',
              '${variavel.value.nome}',
        ]);
        planilha.add([
          ...base1,
          ...base2,
          'variavel_tipo',
              '${variavel.value.tipo}',
        ]);
        if (variavel.value.tipo == 'url') {
          planilha.add([
            ...base1,
            ...base2,
            'variavel_valor',
                '=HYPERLINK("${variavel.value.valor}";"Link para a variavel")',
          ]);
        } else if (variavel.value.tipo == 'urlimagem') {
          planilha.add([
            ...base1,
            ...base2,
            'variavel_valor',
                '=IMAGE("${variavel.value.valor}")',
          ]);
        } else {
          planilha.add([
            ...base1,
            ...base2,
            'variavel_valor',
                '${variavel.value.valor}',
          ]);
        }
      }
      var dicGabarito = Dictionary.fromMap(simulacao.gabarito);
      var gabaritoOrderBy = dicGabarito
          .orderBy((kv) => kv.value.ordem)
          .toDictionary$1((kv) => kv.key, (kv) => kv.value);
      gabaritoMap.clear();
      gabaritoMap = gabaritoOrderBy.toMap();
      String nota = '=';
      for (var gabarito in gabaritoMap.entries) {
         planilha.add([
          ...base1,
          ...base2,
          'gabarito_nome',
              '${gabarito.value.nome}',
        ]);
        planilha.add([
          ...base1,
          ...base2,
          'gabarito_tipo',
              '${gabarito.value.tipo}',
        ]);
        if (gabarito.value.tipo == 'url'||gabarito.value.tipo == 'arquivo') {
          planilha.add([
            ...base1,
            ...base2,
            'gabarito_valor',
                '=HYPERLINK("${gabarito.value.valor}";"Link para a gabarito")',
          ]);
        } else if (gabarito.value.tipo == 'urlimagem'||gabarito.value.tipo == 'imagem') {
          planilha.add([
            ...base1,
            ...base2,
            'gabarito_valor',
                '=IMAGE("${gabarito.value.valor}")',
          ]);
        } else {
          planilha.add([
            ...base1,
            ...base2,
            'gabarito_valor',
                '${gabarito.value.valor}',
          ]);
        }
      }
    }

// print(planilha.toList());
    String csvData =
        ListToCsvConverter().convert(planilha, fieldDelimiter: ',');
    // print('+++ generateCsvFromUsuarioListDaTurma\n$csvData\n--- generateCsvFromUsuarioListDaTurma');
    _saveFileAndOpen(csvData);
  }

  static _saveFileAndOpen(String csvData) async {
    //gerar e salvar
    var csvDirectory = (await getExternalStorageDirectory()).path + "/";
    var fileDirectory = "$csvDirectory";
    String filename = "piprof_brintec.csv";

    await _salvarArquivoCsv(csvData, filename, fileDirectory);
    await _openFileFromDirectory(filename, fileDirectory);
  }

  static Future<File> _salvarArquivoCsv(
      String csvData, String filename, String fileDirectory) async {
    File csvFile = new File(fileDirectory + filename);
    await csvFile.writeAsString(csvData);
    return csvFile;
  }

  static _openFileFromDirectory(String filename, String fileDirectory) async {
    // Veja https://pub.dev/packages/open_file
    await OpenFile.open(
      fileDirectory + filename,
    );
    // await OpenFile.open(fileDirectory + filename,
    //     type:
    //         "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    // await OpenFile.open(fileDirectory + filename,
    //     type:
    //         "application/vnd.ms-excel");
  }
}
