import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: '我的計算機 🧮'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ===== 計算機要記住的 4 件事（狀態）=====
  String _display = '0'; // 螢幕上顯示的文字
  double _firstOperand = 0; // 按運算子時，先存下來的第一個數字
  String _operator = ''; // 記住按了哪個運算子（+ - * /），空字串代表還沒按
  bool _startNewNumber = true; // 下一個數字是否要「重新輸入」（而不是接在後面）

  // 一個聰明的函式：所有按鈕都呼叫它，靠傳進來的 value 判斷要做什麼
  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        // 清除：把所有狀態歸零
        _display = '0';
        _firstOperand = 0;
        _operator = '';
        _startNewNumber = true;
      } else if (value == '+' || value == '-' || value == '*' || value == '/') {
        // 按了運算子
        if (!_startNewNumber && _operator != '') {
          // 若前面已經有一段算式（例如 2 + 3 再按 +），先把它算出來
          _firstOperand = _compute();
          _display = _formatResult(_firstOperand);
        } else {
          _firstOperand = _parseDisplay(); // 把螢幕上的數字存起來
        }
        _operator = value; // 記住這次按的運算子
        _startNewNumber = true; // 下一個數字要重新輸入
      } else if (value == '=') {
        // 按了等於：算出結果
        _display = _formatResult(_compute());
        _operator = '';
        _startNewNumber = true;
      } else if (value == '.') {
        // 按了小數點
        if (_startNewNumber) {
          _display = '0.'; // 重新輸入時，從 "0." 開始
          _startNewNumber = false;
        } else if (!_display.contains('.')) {
          _display = '$_display.'; // 只有在還沒有小數點時才加（避免 1.2.3）
        }
      } else {
        // 按了數字 0~9
        if (_startNewNumber) {
          _display = value; // 重新輸入：直接換成這個數字
          _startNewNumber = false;
        } else {
          // 接在後面；但若目前是 "0" 就直接取代（避免 007 這種）
          _display = _display == '0' ? value : '$_display$value';
        }
      }
    });
  }

  // 把螢幕上的字串轉成數字（tryParse 失敗就回 0，避免當機）
  double _parseDisplay() {
    final text = _display.endsWith('.')
        ? _display.substring(0, _display.length - 1)
        : _display;
    return double.tryParse(text) ?? 0;
  }

  // 用記住的運算子，計算 第一個數 (運算子) 螢幕上的數
  double _compute() {
    final second = _parseDisplay();
    switch (_operator) {
      case '+':
        return _firstOperand + second;
      case '-':
        return _firstOperand - second;
      case '*':
        return _firstOperand * second;
      case '/':
        return _firstOperand / second; // 除以 0 在 Dart 會得到「無限大」，下面會處理
      default:
        return second; // 還沒有運算子，就直接回螢幕上的數
    }
  }

  // 把結果整理成漂亮的字串
  String _formatResult(double value) {
    if (value.isInfinite || value.isNaN) return '錯誤'; // 例如除以 0
    if (value == value.roundToDouble()) {
      return value.toInt().toString(); // 整數就不要顯示 .0（例如 10 而非 10.0）
    }
    return value.toString();
  }

  // 小工具：產生一顆計算機按鈕，避免重複寫 16 次 ElevatedButton
  Widget _calcButton(String label, {Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color != null ? Colors.white : null,
        minimumSize: const Size(70, 60), // 讓按鈕大小一致
      ),
      onPressed: () => _onButtonPressed(label),
      child: Text(label, style: const TextStyle(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ===== 上方：顯示螢幕 =====
          Container(
            alignment: Alignment.centerRight, // 數字靠右，像真計算機
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Text(
              _display,
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          // ===== 下方：按鈕區（每一列是一個 Row）=====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton('7'),
              const SizedBox(width: 10),
              _calcButton('8'),
              const SizedBox(width: 10),
              _calcButton('9'),
              const SizedBox(width: 10),
              _calcButton('+', color: Colors.blue[300]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton('4'),
              const SizedBox(width: 10),
              _calcButton('5'),
              const SizedBox(width: 10),
              _calcButton('6'),
              const SizedBox(width: 10),
              _calcButton('-', color: Colors.blue[300]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton('1'),
              const SizedBox(width: 10),
              _calcButton('2'),
              const SizedBox(width: 10),
              _calcButton('3'),
              const SizedBox(width: 10),
              _calcButton('*', color: Colors.blue[300]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton('C', color: Colors.red[200]),
              const SizedBox(width: 10),
              _calcButton('0'),
              const SizedBox(width: 10),
              _calcButton('.'),
              const SizedBox(width: 10),
              _calcButton('/', color: Colors.blue[300]),
            ],
          ),
          const SizedBox(height: 10),
          // ===== 最下面：等於鍵（佔右側兩排、靠右）=====
          SizedBox(
            width: 310, // 跟上面整排按鈕一樣寬（70×4 + 10×3）
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // 在這個框內「靠右」
              children: [
                SizedBox(
                  width: 150, // 右側兩排的寬度（70 + 10 + 70）
                  child: _calcButton('=', color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
