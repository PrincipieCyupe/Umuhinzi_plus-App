import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/market/data/datasources/market_remote_data_source.dart';
import 'features/market/data/datasources/preferences_service.dart';
import 'features/market/data/repositories/market_repository_impl.dart';
import 'features/market/domain/usecases/add_produce.dart';
import 'features/market/domain/usecases/delete_produce.dart';
import 'features/market/domain/usecases/get_produce_by_category.dart';
import 'features/market/domain/usecases/search_produce.dart';
import 'features/market/domain/usecases/update_produce.dart';
import 'features/market/presentation/bloc/market_bloc.dart';
import 'features/market/presentation/pages/market_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Note: This requires google-services.json to be present for Android.
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  final sharedPrefs = await SharedPreferences.getInstance();
  runApp(Home(sharedPreferences: sharedPrefs));
}

class Home extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const Home({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = MarketRemoteDataSourceImpl(firestore: firestore);
    final repository = MarketRepositoryImpl(remoteDataSource: remoteDataSource);
    final preferencesService = PreferencesService(
      sharedPreferences: sharedPreferences,
    );

    final getProduceByCat = GetProduceByCategory(repository);
    final searchProd = SearchProduce(repository);
    final addProd = AddProduce(repository);
    final updateProd = UpdateProduce(repository);
    final deleteProd = DeleteProduce(repository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<MarketBloc>(
          create: (context) => MarketBloc(
            getProduceByCategory: getProduceByCat,
            searchProduce: searchProd,
            addProduce: addProd,
            updateProduce: updateProd,
            deleteProduce: deleteProd,
            preferencesService: preferencesService,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.sourceSans3TextTheme()),
        home:
            const MarketPage(), // Directly showing MarketPage for demonstration
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  static List<TextStyle> appstyle = [
    TextStyle(fontWeight: FontWeight.bold),
    TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ];
  List<Widget> laterwidgets = [
    Text("Future home page", style: appstyle[1]),
    Text("Future Weather page", style: appstyle[1]),
    Text("Future Market page", style: appstyle[1]),
    Text("Future Tips and Update page", style: appstyle[1]),
  ];
  List<String> items = ["Home", "Weather", "Market", "Tips & Updates"];

  int _selectedIndex = 0;
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Center(child: laterwidgets.elementAt(_selectedIndex)),
      appBar: AppBar(
        title: Text("Umuhinzi+", style: appstyle[0]),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset('lib/images/logo.png', width: 20, height: 20),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: items[0]),
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: items[1]),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: items[2],
          ),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: items[3]),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapped,
        unselectedItemColor: Colors.green,
        selectedItemColor: Colors.orangeAccent,
      ),
    );
  }
}
