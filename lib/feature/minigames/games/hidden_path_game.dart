import 'dart:math';

import 'package:flutter/material.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// Enum para representar as direções
enum Direction {
  up,
  down,
  left,
  right,
  none, // Para células que não fazem parte do caminho ou são o final
}

// Classe para representar os dados de cada célula do tabuleiro
class CellData {
  final int row;
  final int col;
  bool isRevealed; // true se a célula foi tocada e seu conteúdo revelado
  final bool isPath; // true se esta célula faz parte do caminho escondido
  final Direction arrowDirection; // Direção da seta se for parte do caminho
  final bool isStart; // É o início do caminho?
  final bool isEnd; // É o fim do caminho?
  final int pathIndex; // A ordem no caminho (-1 se não for do caminho)
  bool
      isCorrectTap; // true se o último toque nesta célula foi correto no caminho

  CellData({
    required this.row,
    required this.col,
    this.isRevealed = false,
    this.isPath = false,
    this.arrowDirection = Direction.none,
    this.isStart = false,
    this.isEnd = false,
    this.pathIndex = -1,
    this.isCorrectTap = false, // Initialize as false
  });

  // Método para copiar a célula com novas propriedades (útil para gerenciamento de estado)
  CellData copyWith({
    bool? isRevealed,
    bool? isPath,
    Direction? arrowDirection,
    bool? isStart,
    bool? isEnd,
    int? pathIndex,
    bool? isCorrectTap,
  }) {
    return CellData(
      row: row,
      col: col,
      isRevealed: isRevealed ?? this.isRevealed,
      isPath: isPath ?? this.isPath,
      arrowDirection: arrowDirection ?? this.arrowDirection,
      isStart: isStart ?? this.isStart,
      isEnd: isEnd ?? this.isEnd,
      pathIndex: pathIndex ?? this.pathIndex,
      isCorrectTap: isCorrectTap ?? this.isCorrectTap,
    );
  }

  // Retorna o IconData apropriado para a seta
  IconData get arrowIcon {
    switch (arrowDirection) {
      case Direction.up:
        return Icons.arrow_upward;
      case Direction.down:
        return Icons.arrow_downward;
      case Direction.left:
        return Icons.arrow_back;
      case Direction.right:
        return Icons.arrow_forward;
      case Direction.none:
      default:
        return Icons.close; // Default para células sem seta ou não reveladas
    }
  }
}

class HiddenPathGame implements MiniGame {
  @override
  String get name => "Caminho Escondido";

  @override
  String get description =>
      "O objetivo é encontrar o final do caminho com o mínimo de toques.";

  @override
  IconData get icon => Icons.pattern_sharp;

  @override
  Color get color => Colors.black54;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return HiddenPathGameScreen(onGameComplete: onGameComplete);
  }
}

class HiddenPathGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const HiddenPathGameScreen({super.key, required this.onGameComplete});

  @override
  State<HiddenPathGameScreen> createState() => _HiddenPathGameWidgetState();
}

class _HiddenPathGameWidgetState extends State<HiddenPathGameScreen> {
  final int _gridSize = 6; // Grid 6x6, ajuste conforme preferir
  late List<List<CellData>> _board;
  late List<CellData>
      _hiddenPath; // A lista que armazena a sequência do caminho
  int _currentPathStep = 0; // Índice da próxima célula esperada no _hiddenPath
  int _touchesCount = 0;
  bool _gameOver = false;
  bool _gameWon = false;
  final int _incorrectTapsAllowed = 3; // Número de toques incorretos permitidos
  int _currentIncorrectTaps = 0; // Contador de toques incorretos

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _board = List.generate(
      _gridSize,
      (row) => List.generate(_gridSize, (col) => CellData(row: row, col: col)),
    );
    _hiddenPath = []; // Limpa o caminho anterior
    _touchesCount = 0;
    _currentPathStep = 0;
    _gameOver = false;
    _gameWon = false;
    _currentIncorrectTaps = 0;

    _generatePath(); // Gera um novo caminho
  }

  void _generatePath() {
    final Random random = Random();

    // 1. Escolhe um ponto de partida aleatório e o adiciona ao caminho
    int startRow = random.nextInt(_gridSize);
    int startCol = random.nextInt(_gridSize);

    _board[startRow][startCol] = _board[startRow][startCol].copyWith(
      isPath: true,
      isStart: true,
      pathIndex: 0,
      isRevealed: true, // A célula inicial é sempre revelada
      isCorrectTap: true, // É o primeiro toque correto implicitamente
    );
    _hiddenPath.add(_board[startRow][startCol]);

    int currentRow = startRow;
    int currentCol = startCol;

    // Define um comprimento mínimo e máximo para o caminho
    int minPathLength =
        (_gridSize * _gridSize * 0.4).toInt(); // 40% das células
    int maxPathLength =
        (_gridSize * _gridSize * 0.8).toInt(); // 80% das células
    if (minPathLength < 5) minPathLength = 5; // Garante um mínimo razoável

    // Gera o resto do caminho
    for (int i = 1; i < maxPathLength; i++) {
      List<Map<String, dynamic>> possibleNextSteps =
          []; // Armazena {row, col, dir, weight}
      Set<String> visitedForPathGeneration =
          _hiddenPath.map((c) => '${c.row},${c.col}').toSet();

      List<Direction> directionsToTry = Direction.values
          .where((d) => d != Direction.none)
          .toList()
        ..shuffle(random);

      for (Direction dir in directionsToTry) {
        int nextRow = currentRow;
        int nextCol = currentCol;

        switch (dir) {
          case Direction.up:
            nextRow--;
            break;
          case Direction.down:
            nextRow++;
            break;
          case Direction.left:
            nextCol--;
            break;
          case Direction.right:
            nextCol++;
            break;
          case Direction.none:
            continue; // Não deve acontecer
        }

        // Verifica se o próximo passo é válido (dentro da grade e não visitado)
        if (nextRow >= 0 &&
            nextRow < _gridSize &&
            nextCol >= 0 &&
            nextCol < _gridSize &&
            !visitedForPathGeneration.contains('$nextRow,$nextCol')) {
          // Adiciona um peso para tornar a geração do caminho mais interessante (menos repetitiva ou previsível)
          // Ex: penaliza movimentos de volta para a célula anterior
          int weight = 1; // Base weight

          // You could add more complex logic here, e.g., to avoid straight lines too long
          // or prefer turning. For now, basic avoidance of immediate back-tracking.

          possibleNextSteps.add({
            'row': nextRow,
            'col': nextCol,
            'dir': dir,
            'weight': weight,
          });
        }
      }

      if (possibleNextSteps.isEmpty) {
        // Se não houver mais movimentos possíveis, o caminho parou
        break;
      }

      // Seleciona o próximo passo com base nos pesos (se houver mais de uma opção)
      // Para este exemplo simplificado, basta pegar o primeiro passo possível.
      Map<String, dynamic> nextStep =
          possibleNextSteps[random.nextInt(possibleNextSteps.length)];

      int nextRow = nextStep['row']!;
      int nextCol = nextStep['col']!;
      Direction currentDir = nextStep['dir']!;

      // Atualiza a célula anterior para apontar para a próxima célula no caminho
      _board[currentRow][currentCol] = _board[currentRow][currentCol].copyWith(
        arrowDirection: currentDir,
      );

      // Cria e adiciona a nova célula ao caminho
      _board[nextRow][nextCol] = _board[nextRow][nextCol].copyWith(
        isPath: true,
        pathIndex: i,
      );
      _hiddenPath.add(_board[nextRow][nextCol]);

      // Atualiza a posição atual
      currentRow = nextRow;
      currentCol = nextCol;

      // Se o caminho já atingiu o comprimento mínimo e tiver sorte, pode finalizar
      if (i >= minPathLength && random.nextDouble() < 0.3) {
        // 30% chance de finalizar
        break;
      }
    }

    // Marca a última célula do caminho como o ponto final
    if (_hiddenPath.isNotEmpty) {
      _board[_hiddenPath.last.row][_hiddenPath.last.col] =
          _board[_hiddenPath.last.row][_hiddenPath.last.col].copyWith(
        isEnd: true,
        arrowDirection:
            Direction.none, // O ponto final não aponta para mais lugar nenhum
      );
      _hiddenPath[_hiddenPath.length - 1] = _board[_hiddenPath.last.row]
          [_hiddenPath.last.col]; // Atualiza na lista também
    }
  }

  void _handleCellTap(int row, int col) {
    if (_gameOver || _gameWon)
      return; // Não permite toques se o jogo já terminou

    setState(() {
      _touchesCount++;
      CellData tappedCell = _board[row][col];

      // Se já revelada, não faz nada (pode ser ajustado para um feedback visual)
      if (tappedCell.isRevealed) {
        return;
      }

      // Marca a célula como revelada
      _board[row][col] = tappedCell.copyWith(isRevealed: true);

      // Verifica se o toque é o próximo passo correto no caminho
      bool isCorrectCurrentTap = false;
      if (_currentPathStep < _hiddenPath.length) {
        CellData expectedNextCell = _hiddenPath[_currentPathStep];
        if (tappedCell.row == expectedNextCell.row &&
            tappedCell.col == expectedNextCell.col) {
          isCorrectCurrentTap = true;
        }
      }

      if (isCorrectCurrentTap) {
        _board[row][col] = _board[row][col].copyWith(isCorrectTap: true);
        _currentPathStep++; // Avança para o próximo passo no caminho

        if (_currentPathStep >= _hiddenPath.length && _hiddenPath.last.isEnd) {
          _gameWon = true; // Jogo ganho!
        }
      } else {
        // Toque incorreto
        _board[row][col] = _board[row][col].copyWith(isCorrectTap: false);
        _currentIncorrectTaps++;
        if (_currentIncorrectTaps >= _incorrectTapsAllowed) {
          _gameOver = true; // Jogo perdido por muitos toques incorretos
        }
      }
    });
  }

  // Helper para determinar a cor de fundo da célula
  Color _getCellBackgroundColor(CellData cell) {
    if (cell.isRevealed) {
      if (cell.isStart) return Colors.blue.shade200; // Início
      if (cell.isEnd) return Colors.purple.shade200; // Fim
      if (cell.isCorrectTap) return Colors.green.shade100; // Revelado e correto
      return Colors.red.shade100; // Revelado e incorreto
    }
    // Células não reveladas
    return Colors.grey.shade300;
  }

  // Helper para determinar o widget a ser exibido dentro da célula
  Widget _getCellContent(CellData cell) {
    if (!cell.isRevealed) {
      // Se não revelado, mostra um ponto de interrogação ou nada
      return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
    }

    if (cell.isStart) {
      return const Icon(Icons.play_arrow, color: Colors.green, size: 36);
    }
    if (cell.isEnd) {
      return const Icon(Icons.flag, color: Colors.blue, size: 36);
    }
    if (cell.isPath && cell.isCorrectTap) {
      // Se é do caminho e foi corretamente revelado, mostra a seta
      return Icon(cell.arrowIcon, size: 36, color: Colors.blueAccent);
    } else {
      // Se revelado e não faz parte do caminho ou foi um toque incorreto
      return const Icon(Icons.close, size: 36, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caminho Escondido'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame,
            tooltip: 'Reiniciar Jogo',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Toques: $_touchesCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Erros: $_currentIncorrectTaps / $_incorrectTapsAllowed',
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentIncorrectTaps >= _incorrectTapsAllowed
                        ? Colors.red
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                if (_gameWon)
                  const Text(
                    '🎉 Você Ganhou! 🎉',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  )
                else if (_gameOver)
                  const Text(
                    'Game Over! 😔 Tente Novamente.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    'Encontre o caminho oculto do ponto de partida ao fim!',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1, // Mantém a grade quadrada
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _gridSize * _gridSize,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      crossAxisSpacing: 8.0, // Espaçamento entre as células
                      mainAxisSpacing: 8.0, // Espaçamento entre as células
                    ),
                    itemBuilder: (context, index) {
                      final row = index ~/ _gridSize;
                      final col = index % _gridSize;
                      final cell = _board[row][col];

                      return GestureDetector(
                        onTap: () => _handleCellTap(row, col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutQuad,
                          decoration: BoxDecoration(
                            color: _getCellBackgroundColor(cell),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: cell.isRevealed
                                  ? (cell.isCorrectTap
                                      ? Colors.blueAccent
                                      : Colors.red)
                                  : Colors.grey.shade400,
                              width: cell.isRevealed
                                  ? 3.0
                                  : 1.0, // Borda mais grossa ao revelar
                            ),
                          ),
                          child: Center(child: _getCellContent(cell)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
