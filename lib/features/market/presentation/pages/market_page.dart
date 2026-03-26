import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/market_search_bar.dart';
import '../widgets/market_price_section.dart';
import '../cubit/market_price_cubit.dart';
import '../../data/datasources/market_csv_data_source.dart';
import '../../data/datasources/market_price_firestore_source.dart';
import '../../data/repositories/market_price_repository_impl.dart';

// The main Market screen where users can see crop prices
class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late final FirebaseFirestore firestore;
  late final MarketCsvDataSource csvDataSource;
  late final MarketPriceRepositoryImpl repository;

  // We set up the database and data sources when the page first loads
  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    csvDataSource = MarketCsvDataSource(client: http.Client());
    repository = MarketPriceRepositoryImpl(
      csvDataSource: csvDataSource,
      firestoreSource: MarketPriceFirestoreSource(firestore: firestore),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MarketPriceCubit>(
      create: (_) => MarketPriceCubit(repository: repository),
      child: BlocConsumer<MarketBloc, MarketState>(
        listener: (context, state) {
          if (state is MarketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is MarketOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MarketOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<MarketBloc>().add(const ResetMarketEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          String activeCategory = 'All';

          if (state is MarketLoaded) {
            activeCategory = state.activeCategory;
          }

          return SafeArea(
            child: RefreshIndicator(
              // Allow users to pull down to refresh both Firestore and CSV data
              onRefresh: () async {
                context.read<MarketBloc>().add(LoadProduceByCategoryEvent(activeCategory)); // Refresh Firestore data
                await repository.syncPrices(); // Refresh CSV data
              },
              child: Column(
                children: [
                  // Search Bar
                  MarketSearchBar(
                    onSearch: (query) {
                      context.read<MarketBloc>().add(SearchProduceEvent(query));
                      // Update Live Prices search results
                      context.read<MarketPriceCubit>().searchPrices(query);
                    },
                  ),
                  // Category Tabs
                  CategoryTabBar(
                    activeCategory: activeCategory,
                    onCategorySelected: (category) {
                      context.read<MarketBloc>().add(
                        LoadProduceByCategoryEvent(category),
                      );
                      // Update Live Prices category filter
                      context.read<MarketPriceCubit>().filterByCategory(category);
                    },
                  ),
                  const SizedBox(height: 8),
                  // This part shows when the prices were last updated from the source
                  BlocBuilder<MarketPriceCubit, MarketPriceState>(
                    builder: (context, priceState) {
                      String dateStr = '--';
                      if (priceState is MarketPriceLoaded) {
                        dateStr = priceState.lastUpdated;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              'Prices updated: $dateStr',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Live WFP Market Prices Section
                  const Expanded(
                    child: MarketPriceSection(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
