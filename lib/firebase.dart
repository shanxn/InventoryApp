import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inventory/server.dart';
import 'package:permission_handler/permission_handler.dart';

class Data {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference order = FirebaseFirestore.instance.collection('order');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Get the user's document reference
  DocumentReference getUserDocument(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // Get user's collections
  CollectionReference getUserStocksCollection(String userId) {
    return getUserDocument(userId).collection('stocks');
  }
  CollectionReference getUserAnalyticCollection(String userId) {
    return getUserDocument(userId).collection('analytics');
  }

  CollectionReference getUserHistoryCollection(String userId) {
    return getUserDocument(userId).collection('history');
  }

  CollectionReference getUserPurchaseCollection(String userId) {
    return getUserDocument(userId).collection('purchase');
  }

  // Add stock for a specific user
  Future<void> addStock(String userId, String stockId, String name, String description, int value, int price) async {
    try {
      await getUserStocksCollection(userId).doc(stockId).set({
        'user': userId,
        'name': name,
        'description': description,
        'stock': value,
        'price': price,
        'time': Timestamp.now(),
      });
    } catch (e) {
      return;
    }
  }


  Future<void> purchaseAdd(String userId, String purchaseId, String stockId, String owner, int quantity) async {
    try {
      await getUserPurchaseCollection(userId).doc(purchaseId).set({
        'user': owner,
        'stock': stockId,
        'quantity': quantity,
        'time': Timestamp.now(),
      });
    } catch (e) {
      return;
    }
  }


  // History add:
  Future<void> historyAdd(String userId, String historyId, String owner, String stockId, int price, int quantity) async {
    try {
      await getUserHistoryCollection(userId).doc(historyId).set({
        'owned': owner,
        'orderBy': userId,
        'stockid': stockId,
        'quantity': quantity,
        'priceSpent': price,
        'time': Timestamp.now(),
      });
    } catch (e) {
      return;
    }
  }

  Future<void> orderAdd(String userId, String historyId,int price, String owner, String stockId, int quantity) async {
    try {
      await order.add({
        'owned': owner,
        'orderBy': userId,
        'stockid': stockId,
        'quantity': quantity,
        'pricrRecived': price,
        'time': Timestamp.now(),
      });
    } catch (e) {
      return;
    }
  }
  Future<void> send_alert(String userid, int num, String name) async{
    var token = await getUserField(userid, 'notificationToken');
    if(num < 100){
      return sendNotification(token.toString(), 'Insufficient stock', 'running low on $name');
    }
  }


  // Get list of stocks for a specific user
  Stream<QuerySnapshot> getUserStocks(String userId) {
    return getUserDocument(userId).collection('stocks').orderBy('time', descending: true).snapshots();
  }

  // Get user purchases list
  Stream<QuerySnapshot> getUserPurchase(String userId) {
    return getUserDocument(userId).collection('purchase').orderBy('time', descending: true).snapshots();
  }

  // History
  Stream<QuerySnapshot> getUserHistory(String userId) {
    return getUserDocument(userId).collection('history').orderBy('time', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getOrderHistory() {
    return order.orderBy('time', descending: true).snapshots();
  }

  // Get all stocks (for buyers)
  Stream<QuerySnapshot> getAllStocks() {
    return FirebaseFirestore.instance.collectionGroup('stocks')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Delete stock for a specific user
  Future<void> deleteStock(String userId, String stockId) async {
    try {
      await getUserStocksCollection(userId).doc(stockId).delete();
    } catch (e) {
      return;
    }
  }
  //get field:
  Future<dynamic> getUserField(String userId, String fieldName) async {
    try {
      DocumentSnapshot docSnapshot = await getUserDocument(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.get(fieldName); // Access the field
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting field: $e');
      return null; // Handle error
    }
  }
  // order analysis:
  Stream<List<Map<String, dynamic>>> getOrdersSortedByTime() {
    return order.orderBy('time', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }


  Future<void> analyzeOrders(List<Map<String, dynamic>> dailyTotalsList, String userId) async {
    // Use the stream method to listen for orders
    getOrdersSortedByTime().listen((orders) {
      Map<DateTime, int> dailyTotals = {}; // Map to aggregate totals by date

      for (var order in orders) {
        if (order['owned'] == userId) {
          int priceReceived = order['pricrRecived'] ?? 0; // Correct field name
          Timestamp timestamp = order['time']; // Assuming 'time' is the field name

          // Convert timestamp to DateTime for analysis
          DateTime orderTime = timestamp.toDate();

          // Normalize the date to just the day (removing time)
          DateTime orderDate = DateTime(orderTime.year, orderTime.month, orderTime.day);

          // Aggregate priceReceived for that date
          if (dailyTotals.containsKey(orderDate)) {
            dailyTotals[orderDate] = dailyTotals[orderDate]! + priceReceived;
          } else {
            dailyTotals[orderDate] = priceReceived;
          }
        }
      }

      // Update dailyTotalsList without duplicates
      for (var entry in dailyTotals.entries) {
        String dateKey = entry.key.toLocal().toIso8601String();
        int total = entry.value;

        // Check if the date already exists in the list
        bool exists = dailyTotalsList.any((item) => item['date'] == dateKey);

        if (exists) {
          // Update the existing entry
          dailyTotalsList.firstWhere((item) => item['date'] == dateKey)['total'] += total;
        } else {
          // Add a new entry
          dailyTotalsList.add({
            'date': dateKey,
            'total': total,
          });
        }
      }

      // Optionally, you can print the results
      print(dailyTotalsList);
    });
  }




  // Delete Cart
  Future<void> deleteCart(String userId, String stockId) async {
    try {
      await getUserPurchaseCollection(userId).doc(stockId).delete();
    } catch (e) {
      return;
    }
  }

  // History del:
  Future<void> deleteHis(String userId, String stockId) async {
    try {
      await getUserHistoryCollection(userId).doc(stockId).delete();
    } catch (e) {
      return;
    }
  }
  //order del:
  Future<void> deleteOrder(String stockId) async {
    try {
      await order.doc(stockId).delete();
    } catch (e) {
      return;
    }
  }

  // Update product stock value
  Future<void> addProduct(String userId, String stockId, int newValue) {
    return getUserStocksCollection(userId).doc(stockId).update({'stock': newValue});
  }

  Future<Map<String, dynamic>?> getStockData(String userId, String stockId) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(userId).collection('stocks').doc(stockId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>?;
      } else {
        return null; // Document does not exist
      }
    } catch (e) {
      print('Error getting stock data: $e');
      return null; // Return null in case of an error
    }
  }

  Future<void> addQuantity(String userId, String purchaseId, int newValue) {
    return getUserPurchaseCollection(userId).doc(purchaseId).update({'quantity': newValue});
  }


  // message:
  Future<void> getPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permission Denied');
    }
  }

  final curruser = FirebaseAuth.instance.currentUser;
  Future<void> FcmToken() async {
    try {
      await FirebaseMessaging.instance.getToken().then((Token) async {
        await getUserDocument(curruser!.uid).set({
          'notificationToken': Token,
          'email': curruser!.email,
        });
      });
      FirebaseMessaging.instance.onTokenRefresh.listen((Token) async {
        await getUserDocument(curruser!.uid).set({
          'notificationToken': Token,
          'email': curruser!.email,

        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print("Notification tapped with payload: ${response.payload}");
    });

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message.notification!);
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("A new message was opened: ${message.notification?.title}");
    });
  }

  Future<void> _showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // Change as necessary
      'your_channel_name', // Change as necessary
      channelDescription: 'your_channel_description', // Change as necessary
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: notification.body, // Optional payload
    );
  }
  }

