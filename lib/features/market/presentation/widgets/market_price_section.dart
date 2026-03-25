import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/market_price_cubit.dart';


class MarketPriceSection extends StatelessWidget {
  const MarketPriceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Live Market Prices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildDistrictFilters(context),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<MarketPriceCubit, MarketPriceState>(
            builder: (context, state) {
              if (state is MarketPriceInitial || state is MarketPriceLoading) {
                return _buildLoading();
              } else if (state is MarketPriceError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              } else if (state is MarketPriceLoaded) {
                return _buildLoadedState(state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictFilters(BuildContext context) {
    final districts = ['All', 'Kigali', 'Eastern', 'Northern', 'Southern', 'Western'];
    return _DistrictFilterChips(districts: districts);
  }

  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 60,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildLoadedState(MarketPriceLoaded state) {
    if (state.prices.isEmpty) {
      return const Center(
        child: Text(
          'No prices available for this area',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              Text(
                'Last updated: ${state.lastUpdated}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.prices.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final price = state.prices[index];
              final isRetail = price.priceType.toLowerCase() == 'retail';
              final badgeColor = isRetail ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price.commodity,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price.market,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${price.price} RWF / ${price.unit}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                price.date,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withAlpha(50),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: badgeColor),
                                ),
                                child: Text(
                                  price.priceType,
                                  style: TextStyle(fontSize: 8, color: badgeColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DistrictFilterChips extends StatefulWidget {
  final List<String> districts;

  const _DistrictFilterChips({required this.districts});

  @override
  State<_DistrictFilterChips> createState() => _DistrictFilterChipsState();
}

class _DistrictFilterChipsState extends State<_DistrictFilterChips> {
  String _selectedDistrict = 'All';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: widget.districts.map((district) {
          final isSelected = _selectedDistrict == district;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(district),
              selected: isSelected,
              onSelected: (selected) {
                if (selected && _selectedDistrict != district) {
                  setState(() {
                    _selectedDistrict = district;
                  });
                  context.read<MarketPriceCubit>().filterByDistrict(district);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
