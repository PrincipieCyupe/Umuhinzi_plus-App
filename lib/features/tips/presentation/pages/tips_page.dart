import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tips_bloc.dart';
import '../bloc/tips_event.dart';
import '../bloc/tips_state.dart';
import '../widgets/tips_search_bar.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/tip_card.dart';
import 'article_reader_page.dart';
import 'video_player_page.dart';

// This is the main screen where farmers can find tips and news
class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This is the search bar at the very top
          TipsSearchBar(
            onSearch: (query) {
              final state = context.read<TipsBloc>().state;
              if (state is TipsLoaded) {
                context.read<TipsBloc>().add(FilterTips(query: query, category: state.category));
              }
            },
          ),
          const SizedBox(height: 16),
          // Horizontal category tabs
          BlocBuilder<TipsBloc, TipsState>(
            builder: (context, state) {
              final category = state is TipsLoaded ? state.category : 'All';
              return CategoryTabBar(
                selectedCategory: category,
                onCategorySelected: (newCategory) {
                  final query = state is TipsLoaded ? state.query : '';
                  context.read<TipsBloc>().add(FilterTips(query: query, category: newCategory));
                },
              );
            },
          ),
          const SizedBox(height: 20),
          // Main content grid of tip cards
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF3FAE4A),
              onRefresh: () async {
                context.read<TipsBloc>().add(RefreshTips());
              },
              child: BlocBuilder<TipsBloc, TipsState>(
                builder: (context, state) {
                  if (state is TipsLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3FAE4A)));
                  } else if (state is TipsError) {
                    return Center(child: Text(state.message));
                  } else if (state is TipsLoaded) {
                    if (state.tips.isEmpty) {
                      return const Center(child: Text("No tips found"));
                    }
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.tips.length,
                      itemBuilder: (context, index) {
                        final tip = state.tips[index];
                        return TipCard(
                          tip: tip,
                          onTap: () {
                            // If it's a video, open it in the VideoPlayerPage
                            if (tip.category == 'Video' && tip.videoId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerPage(
                                    videoId: tip.videoId!,
                                    title: tip.title,
                                  ),
                                ),
                              );
                            } else if (tip.category == 'Post' || tip.category == 'Article') {
                              // Open article in native reader page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticleReaderPage(
                                    tip: tip,
                                  ),
                                ),
                              );
                            } else {
                              // Fallback: show details bottom sheet
                              _showTipDetails(context, tip.title, tip.description);
                            }
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show a bottom sheet with the full tip details
  void _showTipDetails(BuildContext context, String title, String description) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(description, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3FAE4A)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
