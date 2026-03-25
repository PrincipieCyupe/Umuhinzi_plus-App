import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_price_model.dart';
import 'package:flutter/foundation.dart';

class WfpPriceDataSource {
  final http.Client client;
  final FirebaseFirestore firestore;

  WfpPriceDataSource({required this.client, required this.firestore});

  Future<void> fetchAndSync() async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        final url = Uri.parse(
          'https://data.humdata.org/api/3/action/datastore_search'
          '?resource_id=wfp-food-prices-for-rwanda'
          '&limit=100',
        );

        final response = await client.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            final records = data['result']['records'] as List;
            
            final batch = firestore.batch();
            
            for (var record in records) {
              final model = MarketPriceModel.fromJson(record as Map<String, dynamic>);
              
              // Create document ID: {cmname}_{mktname}_{date} snake_case, lowercase
              final safeCommodity = model.commodity.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
              final safeMarket = model.market.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
              final safeDate = model.date.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
              
              final docId = '${safeCommodity}_${safeMarket}_$safeDate';
              
              final docRef = firestore.collection('market_prices').doc(docId);
              batch.set(docRef, model.toFirestore(), SetOptions(merge: true));
            }
            
            await batch.commit();
            debugPrint('WFP sync successful. Synced ${records.length} records.');
            return; // Success
          }
        }
      } catch (e) {
        debugPrint('Fetch attempt ${attempts + 1} failed: $e');
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    debugPrint('WFP sync failed after $maxAttempts attempts. Silent fail.');
  }
}
