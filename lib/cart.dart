import 'package:flutter/material.dart';
import 'package:inventory/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory/Cart_Tile.dart';
import 'package:inventory/server.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final Data dataStock = Data();
  final Map<String, Map<String, dynamic>?> stockDataCache = {};
  final String deviceToken = 'DEVICE_TOKEN_HERE'; // Replace with the actual token
  void showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.only(bottom: 100),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Fade out the notification after a delay
    Future.delayed(const Duration(milliseconds: 400), () {
      overlayEntry.remove();
    });
  }

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
        stream: dataStock.getUserPurchase(userId),
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
                String stockId = document['stock'];
                String purOwn = document['user'];
                var token = dataStock.getUserField(purOwn, 'notificationToken');
                var email = dataStock.getUserField(userId, 'email');

                // Check if stock data is already cached
                if (stockDataCache[stockId] == null) {
                  fetchStockData(stockId,purOwn);
                }

                Map<String, dynamic>? itemData = stockDataCache[stockId];

                if (itemData == null) {
                  return const ListTile(title: Text('Loading...'));
                }

                String nameText = itemData['name'] ?? 'No Name';
                String descText = itemData['description'] ?? 'No Description';
                String priceNum = itemData['price'].toString();

                String owner = itemData['user'] ?? 'No user';
                int currentOrderCount = document['quantity'];
                final docRef = dataStock.getUserHistoryCollection(userId).doc();
                final docId = docRef.id;

                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: CartTile(
                    onDelPressed: () {
                      dataStock.deleteCart(userId, purchaseId);
                    },
                    name: nameText,
                    description: descText,
                    stock: int.tryParse(priceNum) ?? 0,
                    order: currentOrderCount,
                      onBuyPressed: () async {
                        dataStock.send_alert(owner, itemData['stock'], nameText);
                        if(itemData['stock'] == 0 || currentOrderCount> itemData['stock'])
                        {
                        showToast(context, 'Unavailable');
                        await dataStock.addQuantity(userId, purchaseId, 0);
                        }
                        else if (itemData['stock'] > 0 && currentOrderCount > 0) {
                          final newStockValue = itemData['stock'] - currentOrderCount;
                          dataStock.addProduct(owner, stockId, newStockValue);
                          stockDataCache[stockId]?['stock'] = newStockValue;
                          final int priceSpent = currentOrderCount * int.parse(priceNum);


                          await dataStock.historyAdd(userId, docId, owner, stockId, priceSpent,currentOrderCount);
                          await dataStock.orderAdd(userId, docId, priceSpent,owner, stockId, currentOrderCount);
                          await dataStock.addQuantity(userId, purchaseId, 0);

                          var token = await dataStock.getUserField(purOwn, 'notificationToken');
                          var email = await dataStock.getUserField(userId, 'email');

                          if(itemData['stock'] > 100)
                            {
                              await sendNotification(token.toString(), 'New Order!', 'By: $email');
                            }
                          else
                            {
                              await sendNotification(token.toString(), 'New Order!', 'By: $email| running low on $nameText');
                            }
                        }
                        await dataStock.addQuantity(userId, purchaseId, 0);


                      },

                      onAddPressed: () {
                      currentOrderCount++;
                      dataStock.addQuantity(userId, purchaseId, currentOrderCount);
                    },
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



