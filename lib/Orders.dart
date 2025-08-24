import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory/firebase.dart';
import 'package:inventory/tile_of_order.dart';
import 'package:firebase_auth/firebase_auth.dart';

class order_by extends StatefulWidget {
  const order_by({super.key});

  @override
  State<order_by> createState() => _order_byState();
}

class _order_byState extends State<order_by> {
  final Data dataStock = Data();
  final Map<String, Map<String, dynamic>?> stockDataCache = {};





  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(

        body: Center(
          child: Text('User not authenticated.'),
        ),
      );
    }
    final userId = user.uid;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataStock.getOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<DocumentSnapshot> purchaseList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: purchaseList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = purchaseList[index];
                String purchaseId = document.id;
                String stockId = document['stockid'];
                String purOwn = document['owned'];
                String orderId = document['orderBy'];

                // Check if stock data is already cached
                if (stockDataCache[stockId] == null) {
                  fetchStockData(stockId,purOwn);
                }

                Map<String, dynamic>? itemData = stockDataCache[stockId];

                if (itemData == null) {
                  dataStock.deleteOrder(purchaseId);
                  return null;
                }

                String nameText = itemData['name'] ?? 'No Name';
                String descText = itemData['description'] ?? 'No Description';
                String stockNum = itemData['stock'].toString();
                String owner = itemData['user'] ?? 'No user';
                int currentOrderCount = document['quantity'];
                final docRef = dataStock.getUserHistoryCollection(userId).doc();
                final docId = docRef.id;
                if (purOwn == userId)
                  {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: order_tile(desc: descText, name: nameText, Quantity: currentOrderCount),
                    );
                  }
                return null;
              },
            );
          } else {
            return const Scaffold(body: Center(child: Text('No orders recived yet!')));
          }
        },
      ),
    );
  }
  Future<void> fetchStockData(String stockId, String owner) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var stockDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(owner)
          .collection('stocks')
          .doc(stockId)
          .get();

      if (stockDoc.exists) {
        stockDataCache[stockId] = stockDoc.data();
        if (mounted) setState(() {});
      } else {
        print('No data found for stockId: $stockId');
      }
    } catch (error) {
      print('Error fetching stock data: $error');
      // Consider displaying a Snackbar or Toast here
    }
  }
}

