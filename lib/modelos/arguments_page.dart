class EncontroCRUDPageArguments {
  final String turmaID;
  final String encontroID;

  EncontroCRUDPageArguments({this.turmaID, this.encontroID});
}

class AvaliacaoCRUDPageArguments {
  final String turmaID;
  final String avaliacaoID;

  AvaliacaoCRUDPageArguments({this.turmaID, this.avaliacaoID});
}

class QuestaoCRUDPageArguments {
  final String avaliacaoID;
  final String questaoID;

  QuestaoCRUDPageArguments({this.avaliacaoID, this.questaoID});
}

class ProblemaCRUDPageArguments {
  final String pastaID;
  final String problemaID;

  ProblemaCRUDPageArguments({this.pastaID, this.problemaID});
}

class SimulacaoCRUDPageArguments {
  final String problemaID;
  final String simulacaoID;

  SimulacaoCRUDPageArguments({this.problemaID, this.simulacaoID});
}

class SimulacaoVariavelCRUDPageArguments {
  final String simulacaoID;
  final String variavelKey;

  SimulacaoVariavelCRUDPageArguments({this.simulacaoID, this.variavelKey});
}
class SimulacaoGabaritoCRUDPageArguments {
  final String simulacaoID;
  final String gabaritoKey;

  SimulacaoGabaritoCRUDPageArguments({this.simulacaoID, this.gabaritoKey});
}
