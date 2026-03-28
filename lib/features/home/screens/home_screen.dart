import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/bloc/home/home_cubit.dart';
import '../presentation/bloc/home/home_state.dart';
import '../presentation/bloc/navigation_cubit.dart';

import '../../../core/constants/rwanda_data.dart';
import '../../../core/utils/page_transitions.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/weather_service.dart';
import '../presentation/bloc/weather/weather_bloc.dart';
import '../presentation/bloc/weather/weather_event.dart';
import '../presentation/bloc/weather/weather_state.dart';
import '../service/auth_service.dart';
import 'Custom/app_drawer.dart';
import 'Welcome/input_screen.dart';
import 'login.dart';

// Market imports
import '../../../features/market/data/datasources/market_remote_data_source.dart';
import '../../../features/market/data/datasources/preferences_service.dart';
import '../../../features/market/data/repositories/market_repository_impl.dart';
import '../../../features/market/domain/usecases/add_produce.dart';
import '../../../features/market/domain/usecases/delete_produce.dart';
import '../../../features/market/domain/usecases/get_produce_by_category.dart';
import '../../../features/market/domain/usecases/search_produce.dart';
import '../../../features/market/domain/usecases/update_produce.dart';
import '../../../features/market/presentation/bloc/market_bloc.dart';
import '../../../features/market/presentation/pages/market_page.dart';

// Tips imports
import '../../../features/tips/data/datasources/tips_local_data_source.dart';
import '../../../features/tips/data/repositories/tips_repository_impl.dart';
import '../../../features/tips/domain/usecases/get_tips.dart';
import '../../../features/tips/presentation/bloc/tips_bloc.dart';
import '../../../features/tips/presentation/bloc/tips_event.dart';
import '../../../features/tips/presentation/pages/tips_page.dart';
import '../../../features/weather/weather_page.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  final String? selectedDistrict;

  const Home({super.key, this.selectedDistrict});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textTheme: GoogleFonts.sourceSans3TextTheme(),
              scaffoldBackgroundColor: Colors.white,
            ),
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF3FAE4A)),
              ),
            ),
          );
        }

        final sharedPreferences = snapshot.data!;
        final firestore = FirebaseFirestore.instance;
        final remoteDataSource = MarketRemoteDataSourceImpl(
          firestore: firestore,
        );
        final repository = MarketRepositoryImpl(
          remoteDataSource: remoteDataSource,
        );
        final preferencesService = PreferencesService(
          sharedPreferences: sharedPreferences,
        );

        final getProduceByCategory = GetProduceByCategory(repository);
        final searchProduce = SearchProduce(repository);
        final addProduce = AddProduce(repository);
        final updateProduce = UpdateProduce(repository);
        final deleteProduce = DeleteProduce(repository);

        final tipsDataSource = TipsLocalDataSourceImpl();
        final tipsRemoteDataSource = TipsRemoteDataSourceImpl(
          client: http.Client(),
        );
        final tipsRepository = TipsRepositoryImpl(
          localDataSource: tipsDataSource,
          remoteDataSource: tipsRemoteDataSource,
        );
        final getTips = GetTips(tipsRepository);

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => NavigationCubit()),
            BlocProvider(create: (_) => HomeCubit()..loadUserData()),
            BlocProvider(
              create: (context) => WeatherBloc(
                weatherRepository: WeatherRepository(
                  weatherService: WeatherService(),
                ),
              ),
            ),
            BlocProvider(
              create: (context) => MarketBloc(
                getProduceByCategory: getProduceByCategory,
                searchProduce: searchProduce,
                addProduce: addProduce,
                updateProduce: updateProduce,
                deleteProduce: deleteProduce,
                preferencesService: preferencesService,
              ),
            ),
            BlocProvider(
              create: (context) => TipsBloc(getTips: getTips)..add(LoadTips()),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomeContent(selectedDistrict: selectedDistrict),
            theme: ThemeData(
              textTheme: GoogleFonts.sourceSans3TextTheme(),
              scaffoldBackgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class HomeContent extends StatefulWidget {
  final String? selectedDistrict;

  const HomeContent({super.key, this.selectedDistrict});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = context.read<HomeCubit>().state;
      final district =
          widget.selectedDistrict ?? homeState.userDistrict ?? 'Gasabo';
      _fetchWeatherForDistrict(district);
    });
  }

  void _fetchWeatherForDistrict(String district) {
    final coords = RwandaDistricts.getCoordinates(district);
    if (coords != null) {
      context.read<WeatherBloc>().add(
        FetchWeatherByCoordinates(
          latitude: coords['lat']!,
          longitude: coords['lon']!,
          locationName: district,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeTab(),
      const WeatherPage(),
      const MarketPage(),
      const TipsPage(),
    ];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                title: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: "UMUHIN",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                      TextSpan(
                        text: "ZI+",
                        style: TextStyle(color: Colors.yellow.shade700),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      'lib/images/logo.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
              drawer: AppDrawer(
                userEmail: homeState.userEmail,
                userName: homeState.userName,
                selectedCrop: homeState.userCrop,
                selectedSeason: homeState.userSeason,
                selectedDistrict: homeState.userDistrict,
                selectedProvince: homeState.userProvince,
                onLogout: () async {
                  final authService = AuthService();
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      FadeRoute(page: const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                onUpdateProfile: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SlideUpRoute(page: const InputDetails()),
                  );
                },
                onWeatherTap: () =>
                    context.read<NavigationCubit>().navigateTo(1),
              ),
              body: SafeArea(child: screens.elementAt(selectedIndex)),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                currentIndex: selectedIndex,
                onTap: (i) => context.read<NavigationCubit>().navigateTo(i),
                unselectedItemColor: Colors.green.shade700,
                selectedItemColor: Colors.orangeAccent,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.wb_sunny_outlined),
                    activeIcon: Icon(Icons.wb_sunny),
                    label: "Weather",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart),
                    label: "Market",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.lightbulb_outline),
                    activeIcon: Icon(Icons.lightbulb),
                    label: "Tips",
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final selectedCategory = state.selectedCategory;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F4EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search farming tips, markets, or updates",
                      hintStyle: TextStyle(color: Colors.black54),
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryPill(
                        "All",
                        isSelected: selectedCategory == 'All',
                        onTap: () =>
                            context.read<HomeCubit>().selectCategory('All'),
                      ),
                      _buildCategoryPill(
                        "Crops",
                        isSelected: selectedCategory == 'Crops',
                        onTap: () =>
                            context.read<HomeCubit>().selectCategory('Crops'),
                      ),
                      _buildCategoryPill(
                        "Tips",
                        isSelected: selectedCategory == 'Tips',
                        onTap: () =>
                            context.read<HomeCubit>().selectCategory('Tips'),
                      ),
                      _buildCategoryPill(
                        "Updates",
                        isSelected: selectedCategory == 'Updates',
                        onTap: () =>
                            context.read<HomeCubit>().selectCategory('Updates'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 170,
                  child: PageView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildBannerCard(
                        title: "How to use app",
                        subtitle: "learn about all the features\nof app",
                        buttonWidget: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Color(0xFF3FAE4A),
                              size: 30,
                            ),
                            onPressed: () =>
                                _launchURL("https://www.youtube.com"),
                          ),
                        ),
                        imagePath: 'lib/images/Image1.png',
                        bgColor: const Color(0xFFDDEEDC),
                      ),
                      _buildBannerCard(
                        title: "Fast help desk",
                        subtitle: "Talk to one of our team\nmembers",
                        buttonWidget: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3FAE4A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _launchURL("tel:0798200584"),
                          child: const Text(
                            "Get Call",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        imagePath: 'lib/images/Image2.png',
                        bgColor: const Color(0xFFDDEEDC),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3FAE4A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Today's Weather",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDynamicWeatherCard(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Market Views",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Overview of market trends",
                          style: TextStyle(
                            color: Color(0xFF3FAE4A),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<NavigationCubit>().navigateTo(2),
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          color: Color(0xFF3FAE4A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMarketItem(
                  "Wheat",
                  "Kigali, Nyabugogo",
                  "2700 RWF",
                  true,
                ),
                _buildMarketItem(
                  "Cotton",
                  "Kigali, Nyabugogo",
                  "8700 RWF",
                  false,
                ),
                _buildMarketItem(
                  "Orange",
                  "Bugesera, Nyamata",
                  "7400 RWF",
                  false,
                ),
                _buildMarketItem("Ginger", "Musanze, Market", "1500 RWF", true),
                const SizedBox(height: 24),
                Text(
                  selectedCategory,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                  children: _buildFilteredGridItems(context, selectedCategory),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint("Could not launch $url");
    }
  }

  Widget _buildCategoryPill(
    String text, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3FAE4A) : const Color(0xFFF6F4EB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3FAE4A) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard({
    required String title,
    required String subtitle,
    required Widget buttonWidget,
    required String imagePath,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3FAE4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  buttonWidget,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(
    String name,
    String location,
    String price,
    bool isUp,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F4EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.grass, color: Color(0xFF3FAE4A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF3FAE4A),
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: isUp ? Colors.green : Colors.red,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredGridItems(
    BuildContext context,
    String selectedCategory,
  ) {
    final allItems = [
      {
        'title': "Today's Weather",
        'subtitle': "View detailed forecast",
        'image': 'lib/images/home_weather.png',
        'index': 1,
        'category': 'Tips',
      },
      {
        'title': "My Crops",
        'subtitle': "Track crop growth",
        'image': 'lib/images/home_crop.png',
        'index': 3,
        'category': 'Crops',
      },
      {
        'title': "Livestock Health",
        'subtitle': "Monitor livestock health",
        'image': 'lib/images/home_ls.png',
        'index': 3,
        'category': 'Tips',
      },
      {
        'title': "Equipment Maintenance",
        'subtitle': "Schedule equipment checks",
        'image': 'lib/images/home_eq.png',
        'index': 3,
        'category': 'Tips',
      },
    ];

    final filtered = selectedCategory == 'All'
        ? allItems
        : allItems.where((i) => i['category'] == selectedCategory).toList();

    return filtered
        .map(
          (item) => _buildGridItem(
            context,
            item['title'] as String,
            item['subtitle'] as String,
            item['image'] as String,
            item['index'] as int,
          ),
        )
        .toList();
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    int targetIndex,
  ) {
    return GestureDetector(
      onTap: () => context.read<NavigationCubit>().navigateTo(targetIndex),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF6F4EB),
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFB08968), fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicWeatherCard(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3FAE4A)),
          );
        }

        if (state is WeatherError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F4EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        if (state is WeatherLoaded) {
          return _buildWeatherCard(state);
        }

        return _buildWeatherCard(null);
      },
    );
  }

  Widget _buildWeatherCard(WeatherLoaded? state) {
    final temp = state?.weather.temperature.toStringAsFixed(0) ?? '--';
    final condition = state?.weather.weatherMain ?? 'Loading...';
    final humidity = state?.weather.humidity.toString() ?? '--';
    final windSpeed = state?.weather.windSpeed.toStringAsFixed(1) ?? '--';
    final locationName = state?.weather.districtName ?? 'Gasabo';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Green header section similar to weather page
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Weather",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  locationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$temp°",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  condition,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // White body section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(Icons.water_drop, "Humidity", "$humidity%"),
                _buildWeatherDetail(Icons.air, "Wind", "$windSpeed m/s"),
                _buildWeatherDetail(Icons.thermostat, "Feels", "$temp°C"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
