import '../models/tip_model.dart';

// This is where we keep our hardcoded list of tips for the app
abstract class TipsLocalDataSource {
  // Get all the tips we have saved
  Future<List<TipModel>> getTips();
}

class TipsLocalDataSourceImpl implements TipsLocalDataSource {
  @override
  Future<List<TipModel>> getTips() async {
    return [
      TipModel(
        id: '1',
        title: "Crop Rotation Techniques for Rwandan Farmers",
        description: "Learn how to rotate crops to maintain soil health and reduce pests in Rwandan fields.",
        body: "Crop rotation is the practice of planting different crops sequentially on the same plot of land to improve soil health, optimize nutrients in the soil, and combat pest and weed pressure. For Rwandan farmers, this technique is essential for sustainable agriculture. By rotating crops like maize, beans, and sorghum, you can significantly enhance your yield and protect your land. Maize is a heavy feeder that depletes nitrogen, while legumes like beans are nitrogen fixers that restore it. Sorghum adds organic matter back into the soil through its extensive root system. When planning your seasons, alternating these crops breaks the lifecycle of pests that thrive on a single host. Additionally, crop rotation improves soil structure and water-holding capacity, which is crucial during dry spells. To get started, divide your land into sections and keep a record of what is planted where each season. Never plant crops from the same family in the same spot back-to-back. This ongoing cycle of replenishment ensures your soil remains healthy and productive for generations without relying heavily on expensive chemical fertilizers.",
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TipModel(
        id: '2',
        title: "How to Protect Your Crops From Pests Naturally",
        description: "Learn about natural methods, including neem oil and companion planting, to protect your harvest.",
        body: "In Rwanda, common pests like aphids, stem borers, and armyworms can devastate a harvest. However, you don't always need expensive chemical pesticides to protect your crops. Natural pest control is often more affordable, safer for your family, and better for the environment. Neem oil is one of the most effective organic solutions; it disrupts the life cycle of insects without harming beneficial bugs like bees. Companion planting is another excellent strategy. For example, planting marigolds near your tomatoes can deter nematodes, while garlic and onions can repel various aphids. Crop monitoring is your first line of defense—walk your fields regularly and check under leaves for early signs of infestation. Action should be taken as soon as pests are spotted, rather than waiting for an outbreak. When comparing organic methods to chemical ones, the long-term cost of organic farming is often lower because it builds soil resilience rather than depleting it. By adopting these natural techniques, you can maintain healthy, pest-free crops and secure a better income at the market.",
        imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TipModel(
        id: '3',
        title: "Post-Harvest Storage Tips to Reduce Losses",
        description: "Prevent post-harvest losses with proper drying techniques and moisture control methods.",
        body: "Post-harvest loss is a significant challenge for many farmers, but it can be minimized with the right storage techniques. Properly storing your harvest ensures that your hard work translates into food security and profit, rather than waste. The first critical step is thorough drying. Grains and beans must be dried to the correct moisture content (usually around 13-14%) to prevent mold growth and aflatoxin contamination. Spreading crops on clean tarpaulins in direct sunlight is a common effective method. Once dry, choosing the right storage containers is vital. Airtight hermetic bags or sealed plastic silos are excellent investments because they suffocate insects and prevent rodents from accessing your grain. In traditional granaries, ensure proper ventilation while keeping pests out. Moisture control is ongoing; keep storage areas elevated and dry, away from direct ground contact or leaky roofs. Finally, monitor market prices closely. Storing your crops securely allows you to wait for better prices rather than selling immediately after harvest when market supply is high and prices are low.",
        imageUrl: 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800',
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TipModel(
        id: '4',
        title: "Understanding Soil Health for Better Yields",
        description: "Learn how to manage soil pH, use compost, and prepare your land for seasonal planting.",
        body: "Healthy soil is the foundation of a successful farm. In Rwanda, understanding your soil can mean the difference between a poor harvest and an abundant one. Good soil is teeming with organic matter, helpful microbes, and essential nutrients. The first step to improving your land is soil testing. Local agricultural extension offices can help test your soil's pH levels and nutrient deficiencies. Acidic soils, common in many parts of Rwanda, may require the application of agricultural lime to neutralize the acidity and make nutrients available to plants. Composting is one of the most accessible and effective ways to boost soil fertility. By mixing crop residues, animal manure, and kitchen waste, you create nutrient-rich humus that improves soil structure and retains moisture. When using chemical fertilizers, knowing your soil test results ensures you only apply what is needed, saving money and preventing environmental runoff. Seasonal soil preparation, such as minimal tillage and adding organic matter before the rains begin, sets the stage for strong root development and resilient crops.",
        imageUrl: 'https://images.unsplash.com/photo-1663170901490-2d733f00f9ae?auto=format&fit=crop&w=800&q=80',
        category: 'Article',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      TipModel(
        id: '5',
        title: "Pest Control Meetup — Bugesera District",
        description: "Join local farmers in Bugesera for a hands-on workshop on organic pest management.",
        body: "Attention all farmers in the Bugesera District! There will be a community meetup this Saturday at the main sector cooperative center focusing on organic pest control methods. Local agricultural experts will demonstrate how to prepare natural pesticides using locally available plants. This is a great opportunity to share your own experiences and learn from neighbors. The meetup starts at 9:00 AM. Please bring a notebook, a pen, and samples of any mystery pests you've found in your fields for identification. Light refreshments will be provided.",
        imageUrl: 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=800',
        category: 'Post',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      TipModel(
        id: '6',
        title: "Government Subsidy for Maize Seeds — Apply Now",
        description: "MINAGRI is offering subsidized maize seeds for the upcoming season. Find out how to apply.",
        body: "MINAGRI has officially announced the rollout of subsidized maize seeds for the upcoming planting season. These high-yield, drought-resistant varieties are designed to boost food security across the country. Qualifying farmers can receive up to a 50% discount on seeds and approved fertilizers. To apply, visit your local sector agronomist's office or register through the Smart Nkunganire System (SNS) on your mobile phone. The deadline for application is the 15th of next month, and subsidies are available for farmers in all districts. Don't miss this opportunity to lower your input costs!",
        imageUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800',
        category: 'Post',
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
      TipModel(
        id: '7',
        title: "Seasonal Planting Calendar — Season B 2026",
        description: "Review the recommended planting dates and rainfall forecast for Season B.",
        body: "As we approach Season B 2026, proper timing is crucial. The meteorological department forecasts average to slightly above-average rainfall starting in late February. Extension officers recommend preparing your land now. Fast-maturing crops like beans and vegetables should be prioritized to take full advantage of the moisture. Maize planting should be completed by the second week of March. Remember to secure your inputs early to avoid market shortages. Reach out to your local cooperative leaders if you need help securing loans for seeds and fertilizers.",
        imageUrl: 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=800',
        category: 'Post',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      TipModel(
        id: '8',
        title: "Modern Farming Techniques in Rwanda",
        description: "Learn how Rwandan farmers are using modern techniques to improve their crop yields and increase income through better farming practices.",
        body: "",
        imageUrl: 'https://img.youtube.com/vi/hGPMo26s6EI/mqdefault.jpg',
        category: 'Video',
        videoId: 'hGPMo26s6EI',
        date: DateTime.now().subtract(const Duration(days: 8)),
      ),
      TipModel(
        id: '9',
        title: "How to Grow Maize Successfully in Africa",
        description: "A step-by-step guide to growing maize in African climates, covering soil preparation, planting, watering, and harvesting.",
        body: "",
        imageUrl: 'https://img.youtube.com/vi/ZtFkMGHHoGo/mqdefault.jpg',
        category: 'Video',
        videoId: 'ZtFkMGHHoGo',
        date: DateTime.now().subtract(const Duration(days: 9)),
      ),
      TipModel(
        id: '10',
        title: "Organic Pest Control for Small Farmers",
        description: "Discover natural and affordable ways to protect your crops from pests without using expensive chemicals.",
        body: "",
        imageUrl: 'https://img.youtube.com/vi/AcD8MoRMsDc/mqdefault.jpg',
        category: 'Video',
        videoId: 'AcD8MoRMsDc',
        date: DateTime.now().subtract(const Duration(days: 10)),
      )
    ];
  }
}
