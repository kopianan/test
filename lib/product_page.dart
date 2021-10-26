import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>? futureColor = null;
  double price = 0;
  @override
  void initState() {
    getAllProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          future: getAllProducts(),
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var _data = snapshot.data![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        _data['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      _data['item_name'].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                        children: (_data['color'] as List)
                            .map((e) => InkWell(
                                  onTap: () {
                                    price = 0;
                                    futureColor = getProductByColor(
                                      _data['item_id'].toString(),
                                      e['color_id'].toString(),
                                    );
                                    setState(() {});
                                  },
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Color(e['color_hexa'] as int),
                                  ),
                                ))
                            .toList()),
                    (futureColor == null)
                        ? SizedBox()
                        : FutureBuilder<
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                            future: futureColor,
                            builder: (context, snapshot) {
                              var color = snapshot.data;
                              return Container(
                                height: 60,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: color!.length,
                                  itemBuilder: (context, index) {
                                    var _single = color[index].data();
                                    return InkWell(
                                      onTap: () {
                                        price = double.parse(
                                            _single['price'].toString());
                                        setState(() {});
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(_single['size'],
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 50),
                    Text("PRICE ${price}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                  ],
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getAllProducts();
        },
      ),
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllProducts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var _query = await firestore.collection('products').get();
    return _query.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getProductByColor(
      String itemId, String colorId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var _query = await firestore
        .collection('products')
        .doc(itemId)
        .collection(colorId)
        .get();

    return _query.docs;
  }
}
