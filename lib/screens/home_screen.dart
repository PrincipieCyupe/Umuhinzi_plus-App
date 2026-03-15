import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../core/constants/rwanda_data.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/weather_service.dart';
import '../presentation/blocs/weather/weather_bloc.dart';
import '../presentation/blocs/weather/weather_event.dart';
import '../presentation/blocs/weather/weather_state.dart';
import '../service/auth_service.dart';
import 'Custom/app_drawer.dart';
import 'Welcome/input_screen.dart';
import 'login.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  final String? selectedDistrict;

  const Home({super.key, this.selectedDistrict});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WeatherBloc(
            weatherRepository: WeatherRepository(
              weatherService: WeatherService(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomeContent(),
        theme: ThemeData(
          textTheme: GoogleFonts.sourceSans3TextTheme(),
          scaffoldBackgroundColor: Colors.white,
        ),
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
  int _selectedIndex = 0;

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _selectedDistrict = 'Gasabo';

  String? _userName;
  String? _userEmail;
  String? _userCrop;
  String? _userSeason;
  String? _userProvince;
  String? _userDistrict;

  final List<String> items = ["Home", "Weather", "Market", "Tips & Updates"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeatherForDistrict(_getSelectedDistrict());
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _userName = prefs.getString('user_name');
      _userEmail = firebaseUser?.email ?? prefs.getString('user_email');
      _userCrop = prefs.getString('selected_crop');
      _userSeason = prefs.getString('selected_season');
      _userProvince = prefs.getString('selected_province');
      _userDistrict = prefs.getString('selected_district');

      if (_userDistrict != null && _userDistrict!.isNotEmpty) {
        _selectedDistrict = _userDistrict!;
      }
    });
  }

  String _getSelectedDistrict() {
    final homeWidget = context.findAncestorWidgetOfExactType<Home>();
    return homeWidget?.selectedDistrict ?? _selectedDistrict;
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
    List<Widget> screens = [
      HomeTab(onCategoryTap: _onTapped),
      const Center(
        child: Text(
          "Weather Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      const Center(
        child: Text(
          "Market Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      const Center(
        child: Text(
          "Tips & Updates Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
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
            child: Image.asset('lib/images/logo.png', width: 20, height: 20,),
          ),
        ],
      ),
      drawer: AppDrawer(
        userEmail: _userEmail,
        userName: _userName,
        selectedCrop: _userCrop,
        selectedSeason: _userSeason,
        selectedDistrict: _userDistrict,
        selectedProvince: _userProvince,
        onLogout: () async {
          final authService = AuthService();
          await authService.signOut();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        onUpdateProfile: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputDetails()),
          );
        },
      ),
      body: SafeArea(child: screens.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onTapped,
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
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Market"),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: "Tips",
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final Function(int) onCategoryTap;

  const HomeTab({super.key, required this.onCategoryTap});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
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
                    isSelected: _selectedCategory == 'All',
                    onTap: () => setState(() => _selectedCategory = 'All'),
                  ),
                  _buildCategoryPill(
                    "Crops",
                    isSelected: _selectedCategory == 'Crops',
                    onTap: () => setState(() => _selectedCategory = 'Crops'),
                  ),
                  _buildCategoryPill(
                    "Tips",
                    isSelected: _selectedCategory == 'Tips',
                    onTap: () => setState(() => _selectedCategory = 'Tips'),
                  ),
                  _buildCategoryPill(
                    "Updates",
                    isSelected: _selectedCategory == 'Updates',
                    onTap: () => setState(() => _selectedCategory = 'Updates'),
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
                        onPressed: () => _launchURL("https://www.youtube.com"),
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
                      style: TextStyle(color: Color(0xFF3FAE4A), fontSize: 14),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
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
            _buildMarketItem("Wheat", "Kigali, Nyabugogo", "2700 RWF", true),
            _buildMarketItem("Cotton", "Kigali, Nyabugogo", "8700 RWF", false),
            _buildMarketItem("Orange", "Bugesera, Nyamata", "7400 RWF", false),
            _buildMarketItem("Ginger", "Musanze, Market", "1500 RWF", true),
            const SizedBox(height: 24),
            Text(
              _selectedCategory == 'Crops' ? 'Crops' : 'All',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
              children: [
                _buildGridItem(
                  context,
                  "Today's Weather",
                  "View detailed forecast",
                  'lib/images/home_weather.png',
                  1,
                ),
                _buildGridItem(
                  context,
                  "My Crops",
                  "Track crop growth",
                  'lib/images/home_crop.png',
                  3,
                ),
                _buildGridItem(
                  context,
                  "Livestock Health",
                  "Monitor livestock health",
                  'lib/images/home_ls.png',
                  3,
                ),
                _buildGridItem(
                  context,
                  "Equipment Maintenance",
                  "Schedule equipment checks",
                  'lib/images/home_eq.png',
                  3,
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildGridItem(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    int targetIndex,
  ) {
    return GestureDetector(
      onTap: () {
        context.findAncestorStateOfType<_HomeContentState>()?._onTapped(
          targetIndex,
        );
      },
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$temp°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    condition,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(Icons.water_drop, "Humidity", "$humidity%"),
              _buildWeatherDetail(Icons.air, "Wind", "$windSpeed m/s"),
              _buildWeatherDetail(Icons.thermostat, "Feels", "$temp°C"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
