import 'package:flutter/material.dart';
import 'dart:async'; // Importa el paquete para usar Timer
import 'dart:math';

void main() {
  runApp(const MiniPigGame());
}

class MiniPigGame extends StatelessWidget {
  const MiniPigGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Pig Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int playerScore = 0;
  int computerScore = 0;
  int currentTurnPoints = 0;
  int diceResult = 1; // Variable to store the dice result
  bool isPlayerTurn = true; // Player starts the game
  bool gameOver = false; // Variable to track if the game is over

  // Function to handle rolling the dice
  void _rollDice() {
    setState(() {
      // Generate a random number between 1 and 6
      var random = Random();
      diceResult = random.nextInt(6) + 1;

      // Update current turn points
      currentTurnPoints += diceResult;

      // If the generated number is 1, player loses all turn points
      if (diceResult == 1) {
        currentTurnPoints = 0;
        // Switch turn to the other player
        isPlayerTurn = !isPlayerTurn;
      }

      // If it's now computer's turn, let the computer play automatically
      if (!isPlayerTurn && !gameOver) {
        _startComputerTurn();
      }
    });
  }

  // Function to handle the computer's turn
  void _computerTurn() {
    // Computer plays automatically until it accumulates at least 20 points or rolls a 1
    while (currentTurnPoints < 20 && diceResult != 1) {
      var random = Random();
      diceResult = random.nextInt(6) + 1;
      currentTurnPoints += diceResult;
    }

    // If computer rolled a 1, reset turn points and switch to player's turn
    if (diceResult == 1) {
      currentTurnPoints = 0;
      isPlayerTurn = true;
    } else {
      // Otherwise, add current turn points to computer score and switch turn
      computerScore += currentTurnPoints;
      currentTurnPoints = 0;
      isPlayerTurn = true;
    }

    // Check if computer has reached 100 points
    if (computerScore >= 100 || playerScore >= 100) {
      setState(() {
        gameOver = true;
      });
    }
  }

  // Function to handle saving current turn points and switch turn
  void _savePointsAndSwitchTurn() {
    setState(() {
      // Add current turn points to player score
      playerScore += currentTurnPoints;
      // Reset current turn points to 0
      currentTurnPoints = 0;
      // Switch turn to the other player
      isPlayerTurn = !isPlayerTurn;

      // If it's now computer's turn, let the computer play automatically
      if (!isPlayerTurn && !gameOver) {
        _startComputerTurn();
      }

      // Check if player has reached 100 points
      if (playerScore >= 100 || computerScore >= 100) {
        setState(() {
          gameOver = true;
        });
      }
    });
  }

  // Function to start the computer's turn with a delay
  void _startComputerTurn() {
    // Show a snackbar to indicate it's computer's turn
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Turn of computer'),
        duration: Duration(seconds: 2), // Duración del mensaje
      ),
    );

    // Delay the start of the computer's turn by 5 seconds
    Timer(const Duration(seconds: 5), () {
      _computerTurn();
      setState(() {});
    });
  }

  // Function to reset the game
  void _resetGame() {
    setState(() {
      playerScore = 0;
      computerScore = 0;
      currentTurnPoints = 0;
      diceResult = 1;
      isPlayerTurn = true;
      gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Pig Game 🐷'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Player Score: $playerScore',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Computer Score: $computerScore',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Turn Points: $currentTurnPoints',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Display the dice
            GestureDetector(
              onTap: isPlayerTurn && !gameOver ? _rollDice : null,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isPlayerTurn ? Colors.blue : Colors.red,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _DiceDotGrid(result: diceResult),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isPlayerTurn && !gameOver)
              ElevatedButton(
                onPressed: _rollDice,
                child: const Text('Roll Dice'),
              ),
            const SizedBox(height: 20),
            Visibility(
              visible: isPlayerTurn,
              child: ElevatedButton(
                onPressed: _savePointsAndSwitchTurn,
                child: const Text('Save'),
              ),
            ),

            const SizedBox(height: 20),
            if (gameOver)
              Column(
                children: [
                  const Text(
                    'Game Over!',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Winner: ${playerScore >= 100 ? 'Player' : 'Computer'}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('Restart Game'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Custom widget to represent a dice dot
class _DiceDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Custom widget to represent the grid of dots on a dice face
class _DiceDotGrid extends StatelessWidget {
  final int result;

  const _DiceDotGrid({required this.result});

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];

    // Define dot positions based on dice result
    switch (result) {
      case 1:
        dots.add(_DiceDot());
        break;
      case 2:
        dots.addAll([_DiceDot(), const SizedBox(height: 50), _DiceDot()]);
        break;
      case 3:
        dots.addAll([_DiceDot(), _DiceDot(), _DiceDot()]);
        break;
      case 4:
        dots.addAll([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_DiceDot(), _DiceDot()],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_DiceDot(), _DiceDot()],
          ),
        ]);
        break;
      case 5:
        dots.addAll([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_DiceDot(), _DiceDot()],
          ),
          const SizedBox(height: 20),
          _DiceDot(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_DiceDot(), _DiceDot()],
          ),
        ]);
        break;
      case 6:
        dots.addAll([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_DiceDot(), _DiceDot(), _DiceDot()],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_DiceDot(), _DiceDot(), _DiceDot()],
          ),
        ]);
        break;
      default:
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }
}