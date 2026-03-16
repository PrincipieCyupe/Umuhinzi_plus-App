import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umuhinzi_plus/firebase_options.dart';
import 'package:umuhinzi_plus/features/home/presentation/bloc/navigation_cubit.dart';
import 'package:umuhinzi_plus/features/market/data/datasources/market_remote_data_source.dart';
import 'package:umuhinzi_plus/features/market/data/datasources/preferences_service.dart';
import 'package:umuhinzi_plus/features/market/data/repositories/market_repository_impl.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/add_produce.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/delete_produce.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/get_produce_by_category.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/search_produce.dart';
import 'package:umuhinzi_plus/features/market/domain/usecases/update_produce.dart';
import 'package:umuhinzi_plus/features/market/presentation/bloc/market_bloc.dart';
import 'package:umuhinzi_plus/features/market/presentation/pages/market_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
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
        home: const HomeContent(),
        routes: {'/market': (_) => const MarketPage()},
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static List<TextStyle> appstyle = [
    const TextStyle(fontWeight: FontWeight.bold),
    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  ];

  static List<String> items = ["Home", "Weather", "Market", "Tips & Updates"];

  @override
  Widget build(BuildContext context) {
    final List<Widget> laterwidgets = [
      Text("Future home page", style: appstyle[1]),
      Text("Future Weather page", style: appstyle[1]),
      const MarketPage(),
      Text("Future Tips and Update page", style: appstyle[1]),
    ];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          body: Center(child: laterwidgets.elementAt(selectedIndex)),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: items[0],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.wb_sunny),
                label: items[1],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.trending_up),
                label: items[2],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.lightbulb),
                label: items[3],
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (index) => context.read<NavigationCubit>().navigateTo(index),
            unselectedItemColor: Colors.green,
            selectedItemColor: Colors.orangeAccent,
          ),
        );
      },
    );
  }
}
