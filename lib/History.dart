import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class history extends StatefulWidget {
  const history({super.key});

  @override
  State<history> createState() => _historyState();
}

class _historyState extends State<history> {
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
        stream: dataStock.getUserHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<DocumentSnapshot> historyList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = historyList[index];
                String historyId = document.id;
                String stockId = document['stockid'];
                String purOwn = document['owned'];


                // Check if stock data is already cached
                if (stockDataCache[stockId] == null) {
                  fetchStockData(stockId, purOwn);
                }

                Map<String, dynamic>? itemData = stockDataCache[stockId];

                if (itemData == null) {
                  dataStock.deleteHis(userId, historyId);
                  return null;
                }

                String nameText = itemData['name'] ?? 'No Name';
                String descText = itemData['description'] ?? 'No Description';
                String owner = itemData['user'] ?? 'No user';
                int currentOrderCount = document['quantity'];
                int priceSpent = document['priceSpent'];



                final docRef = dataStock.getUserHistoryCollection(userId).doc();
                final docId = docRef.id;

                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: IconButton(
                          onPressed: () =>
                              dataStock.deleteHis(userId, historyId),
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                          )),
                      title: Text(nameText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(descText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(currentOrderCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No Items'));
          }
        },
      ),
    );
  }

  Future<void> fetchStockData(String stockId, String owner) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    print('Fetching stock data for stockId: $stockId...');

    try {
      // Fetch stock data using the owner's user ID
      var stockDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(owner)
          .collection('stocks')
          .doc(stockId)
          .get();

      if (mounted) {
        if (stockDoc.exists) {
          print('Data retrieved: ${stockDoc.data()}');
          stockDataCache[stockId] = stockDoc.data();
          setState(() {});
        } else {
          print('No data found for stockId: $stockId');
        }
      }
    } catch (error) {
      print('Error fetching stock data: $error');
    }
  }
}
