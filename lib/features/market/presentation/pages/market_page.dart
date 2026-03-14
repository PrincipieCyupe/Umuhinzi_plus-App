import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/market_search_bar.dart';
import '../widgets/produce_card.dart';

/// The main Market screen page.
class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarketBloc, MarketState>(
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
              // Produce Grid
              Expanded(child: _buildGrid(context, state, currency)),
            ],
          ),
        );
      },
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
