import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/tip_entity.dart';

class ArticleReaderPage extends StatelessWidget {
  final TipEntity tip;

  const ArticleReaderPage({super.key, required this.tip});

  String _formatDate(DateTime date) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month - 1];
    final year = date.year;
    return "$day $month $year";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tip.title),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tip.title));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Title copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: tip.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(
                      tip.category,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(tip.date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tip.body,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
