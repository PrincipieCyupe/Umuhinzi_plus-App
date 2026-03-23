import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/market_search_bar.dart';
import '../widgets/produce_card.dart';
import '../widgets/market_price_section.dart';
import '../cubit/market_price_cubit.dart';
import '../../data/datasources/wfp_price_datasource.dart';
import '../../data/datasources/market_price_firestore_source.dart';
import '../../data/repositories/market_price_repository_impl.dart';

/// The main Market screen page.
class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late final FirebaseFirestore firestore;
  late final WfpPriceDataSource wfpDataSource;
  late final MarketPriceRepositoryImpl repository;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    wfpDataSource = WfpPriceDataSource(client: http.Client(), firestore: firestore);
    repository = MarketPriceRepositoryImpl(
      wfpDataSource: wfpDataSource,
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
          String currency = 'RWF';

          if (state is MarketLoaded) {
            activeCategory = state.activeCategory;
            currency = state.currency;
          }

          return SafeArea(
            child: Column(
              children: [
                // Search Bar
                MarketSearchBar(
                  onSearch: (query) {
                    context.read<MarketBloc>().add(SearchProduceEvent(query));
                  },
                ),
                // Category Tabs
                CategoryTabBar(
                  activeCategory: activeCategory,
                  onCategorySelected: (category) {
                    context.read<MarketBloc>().add(
                      LoadProduceByCategoryEvent(category),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Live WFP Market Prices Section
                const Expanded(
                  flex: 3,
                  child: MarketPriceSection(),
                ),
                const Divider(height: 32, thickness: 2),
                // Produce Grid (Firestore catalogue)
                Expanded(
                  flex: 4,
                  child: _buildGrid(context, state, currency),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, MarketState state, String currency) {
    if (state is MarketLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MarketLoaded) {
      if (state.produceList.isEmpty) {
        return const Center(child: Text('No produce found.'));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > 600;
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 3 : 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.produceList.length,
            itemBuilder: (context, index) {
              return ProduceCard(
                produce: state.produceList[index],
                currency: currency,
              );
            },
          );
        },
      );
    }

    return const Center(child: Text('Please select a category or search.'));
  }
}
