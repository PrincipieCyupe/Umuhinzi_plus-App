import '../models/tip_model.dart';

// Local data source - provides hardcoded farming tips for Rwanda
abstract class TipsLocalDataSource {
  Future<List<TipModel>> getTips();
}

class TipsLocalDataSourceImpl implements TipsLocalDataSource {
  @override
  Future<List<TipModel>> getTips() async {
    // Return hardcoded list of tips as requested
    return [
      TipModel(
        id: '1',
        title: "Crop Rotation Techniques",
        description: "Learn how to rotate crops to maintain soil health and reduce pests in Rwandan fields.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Crop+Rotation",
        category: 'Post',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TipModel(
        id: '2',
        title: "Pest Control Meetup",
        description: "Join local farmers in Musanze to discuss organic pest control methods this weekend.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Pest+Control",
        category: 'Post',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TipModel(
        id: '3',
        title: "Soil Management for Maize",
        description: "Detailed guide on managing acidic soils common in Rwanda for better maize yields.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Soil+Maize",
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TipModel(
        id: '4',
        title: "How to Store Harvest Properly",
        description: "Prevent post-harvest losses with these simple storage techniques for beans and grains.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Storage+Tips",
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      TipModel(
        id: '5',
        title: "Weather Patterns This Season",
        description: "Stay updated on the expected rains and how they will affect your planting schedule.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Weather+Patterns",
        category: 'Post',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TipModel(
        id: '6',
        title: "Government Subsidy Announcement",
        description: "New fertilizers and seeds subsidies are now available for local cooperatives.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Government+News",
        category: 'Post',
        date: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      TipModel(
        id: '7',
        title: "Organic Pest Control Methods",
        description: "Watch this video to learn how to make natural pesticides from local plants.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Organic+Pest+Video",
        category: 'Video',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      TipModel(
        id: '8',
        title: "Best Crops for Rwanda Highlands",
        description: "Analysis of the most profitable and resilient crops for high-altitude farming in Rwanda.",
        imageUrl: "https://placehold.co/400x200/e8f5e9/2e7d32?text=Highland+Crops",
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}
