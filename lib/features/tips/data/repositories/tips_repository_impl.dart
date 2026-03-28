import 'package:http/http.dart' as http;
import '../../domain/entities/tip_entity.dart';
import '../../domain/repositories/tips_repository.dart';
import '../datasources/tips_firestore_data_source.dart';
import '../datasources/tips_local_data_source.dart';
import '../datasources/youtube_data_source.dart';

// Dummy class kept to satisfy existing home_screen.dart wiring without changes
class TipsRemoteDataSourceImpl {
  final dynamic client;
  TipsRemoteDataSourceImpl({required this.client});
}

/// Fetches tips from Firestore (primary) with local hardcoded data as fallback.
/// On first run, seeds Firestore with the local tips so the collection is
/// populated automatically — no manual Firebase console setup required.
class TipsRepositoryImpl implements TipsRepository {
  final TipsLocalDataSource localDataSource;
  final TipsFirestoreDataSource firestoreDataSource;
  late final YoutubeDataSource youtubeDataSource;

  TipsRepositoryImpl({
    required this.localDataSource,
    TipsFirestoreDataSource? firestoreDataSource,
    YoutubeDataSource? youtubeDataSource,
    dynamic remoteDataSource,
  }) : firestoreDataSource =
           firestoreDataSource ?? TipsFirestoreDataSourceImpl() {
    final client = (remoteDataSource is TipsRemoteDataSourceImpl)
        ? remoteDataSource.client as http.Client
        : http.Client();
    this.youtubeDataSource =
        youtubeDataSource ?? YoutubeDataSource(client: client);
  }

  @override
  Future<List<TipEntity>> getTips() async {
    // Seed Firestore on first launch using hardcoded local data
    final localAll = await localDataSource.getTips();
    await firestoreDataSource.seedIfEmpty(localAll);

    // Fetch tips from Firestore (Articles and Posts)
    List<TipEntity> remoteTips = [];
    try {
      final all = await firestoreDataSource.getTips();
      remoteTips = all.where((t) => t.category != 'Video').toList();
    } catch (_) {
      // Firestore unavailable — fall back to local hardcoded tips
      remoteTips = localAll.where((t) => t.category != 'Video').toList();
    }

    // Fetch YouTube videos (with local video fallback)
    final youtubeVideos = await youtubeDataSource.fetchVideos();
    final fallbackVideos = localAll
        .where((t) => t.category == 'Video')
        .toList();
    final videos = youtubeVideos.isNotEmpty ? youtubeVideos : fallbackVideos;

    final combined = [...remoteTips, ...videos];
    combined.sort((a, b) => b.date.compareTo(a.date));
    return combined;
  }
}
