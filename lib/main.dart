import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_blue/models.dart';
import 'package:quick_blue/quick_blue.dart' as qb;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  
//创建行为
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // ↓ Add the code below.保存单词
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  var devices = <String>[];
  void addDevName(devName) {
    if (devices.contains(devName)) {
      // favorites.remove(current);
      print("["+devName+"已存在]");
    } else {
      devices.add(devName);
    }
    notifyListeners();
  }
  void delDevName() {
    devices.removeRange(0,devices.length);
    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   var selectedIndex = 0;     // ← Add this property.
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = BluetoothPage();
        break;
      case 3:
        page = DeviceiPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
        
    return LayoutBuilder(
      builder: (context,constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,  // ← Here.,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Bluetooth'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.devices_other_sharp),
                      label: Text('Devices'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    // ↓ Replace print with this.
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ...

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
class DeviceiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.devices.isEmpty) {
      return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.devices.length} device:'),
        ),
       
          ListTile(
            leading: Icon(Icons.bluetooth_disabled_outlined),
            title: Text('No devices yet.'),
          ),
      ],
    );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.devices.length} device:'),
        ),
        for (var pair in appState.devices)
          ListTile(
            leading: Icon(Icons.bluetooth_audio),
            title: Text(pair),
          ),
      ],
    );
  }
}


class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothScannerPageState createState() => _BluetoothScannerPageState();
}

class _BluetoothScannerPageState extends State<BluetoothPage> {
 StreamSubscription<BlueScanResult>? _scanSubscription;
  var deviceName = null;
  var stateAPP = null;
 
  @override
  void initState() {
    super.initState();
   
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _startScanning() async {
    try {
       qb.QuickBlue.startScan();
      _scanSubscription = qb.QuickBlue.scanResultStream.listen((result) {
        
        print('onScanResult:'+result.name);
          stateAPP.addDevName(result.name.trim());
          print("长度："+stateAPP.devices.length.toString());
        if(result.name.trim() != ""){
          
        }        
      });
    } catch (e) {
      print('Error starting scanning: $e');
    }
  }

  void _stopScanning() {
    print("停止扫描");
    qb.QuickBlue.stopScan();
    _scanSubscription?.cancel();
  }
 void dleDevState(){
    stateAPP.delDevName();
  }
  void addState(state){
    stateAPP = state;
  }
  @override
  Widget build(BuildContext context) {
  var appState = context.watch<MyAppState>();
  
  addState(appState);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _startScanning,
            child: Text('开始扫描'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _stopScanning,
            child: Text('停止扫描'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: dleDevState,
            child: Text('清空列表'),
          ),
          
          // You can add a list to show the scanned devices here
        ],
      ),
    );
  }
  
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);//选择颜色，请求应用的当前主题。
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,//添加颜色
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}"
          ),
      ),
    );
  }
}