import 'package:http/http.dart' as http;
import '../../domain/entities/tip_entity.dart';
import '../../domain/repositories/tips_repository.dart';
import '../datasources/tips_local_data_source.dart';
import '../datasources/youtube_data_source.dart';

// Dummy class to satisfy home_screen.dart without touching the restricted file
class TipsRemoteDataSourceImpl {
  final dynamic client;
  TipsRemoteDataSourceImpl({required this.client});
}

// This class gets the tips from our local and youtube data sources
class TipsRepositoryImpl implements TipsRepository {
  final TipsLocalDataSource localDataSource;
  late final YoutubeDataSource youtubeDataSource;

  TipsRepositoryImpl({
    required this.localDataSource,
    YoutubeDataSource? youtubeDataSource,
    dynamic remoteDataSource, // Allow unused parameter
  }) {
    final client = (remoteDataSource is TipsRemoteDataSourceImpl)
        ? remoteDataSource.client as http.Client
        : http.Client();
    this.youtubeDataSource = youtubeDataSource ?? YoutubeDataSource(client: client);
  }

  @override
  Future<List<TipEntity>> getTips() async {
    final allLocal = await localDataSource.getTips();
    
    final localTips = allLocal
        .where((t) => t.category != 'Video')
        .toList();
    
    final youtubeVideos = await youtubeDataSource.fetchVideos();
    
    final fallbackVideos = allLocal
        .where((t) => t.category == 'Video')
        .toList();
    
    final videos = youtubeVideos.isNotEmpty 
        ? youtubeVideos 
        : fallbackVideos;
    
    final combined = [...localTips, ...videos];
    combined.sort((a, b) => b.date.compareTo(a.date));
    
    return combined;
  }
}
