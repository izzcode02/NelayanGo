import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/screen/admin/add_item.dart';
import 'package:nelayanpos/screen/admin/update_item.dart';
import 'package:nelayanpos/model/Item.dart';
import 'package:nelayanpos/widget/backbutton.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Widget? contentItem;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: contentItem ?? Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 70, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    itemListTitle(),
                    Gap(10),
                    itemListTable(),
                  ],
                ),
              ),
            )
    );
  }

  Widget itemListTitle() {
    return Card(
      child: Container(
        width: 986,
        height: 62,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButtonB(),
              Text(
                'Item List',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    contentItem = AddItemScreen();
                  });
                },
                style: ElevatedButton.styleFrom(
                    elevation: 12.0,
                    textStyle: const TextStyle(color: Colors.white)),
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemListTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: auth.getItemData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            // width: 967,
            child: Card(
              child: DataTable(
                  headingRowColor: MaterialStatePropertyAll(Colors.grey[300]),
                  headingRowHeight: 93,
                  dataRowHeight: 66,
                  dividerThickness: 2,
                  columns: [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Color Button')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _itemList(context, snapshot.data!.docs)),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  List<DataRow> _itemList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return snapshot
        .map(
            (data) => _buildListItem(context, data, snapshot.indexOf(data) + 1))
        .toList();
  }

  DataRow _buildListItem(
      BuildContext context, DocumentSnapshot data, int index) {
    final items = Item.fromFirestore(data);

    return DataRow(cells: [
      DataCell(Text(index.toString())),
      DataCell(Text(items.name)),
      DataCell(Text('RM ${items.price.toStringAsFixed(2)}')),
      DataCell(Text(items.category)),
      DataCell(Image.network(items.imageUrl, height: 60, width: 60)),
      DataCell(Text(items.color)),
      DataCell(
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    contentItem = UpdateItemScreen(itemId: items.itemId);
                  },
                );
              },
              child: Icon(Icons.edit),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue)),
            ),
            Gap(5),
            ElevatedButton(
              onPressed: () {
                auth.deleteItem(items.itemId);
              },
              child: Icon(Icons.delete),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.red)),
            ),
          ],
        ),
      ),
    ]);
  }
}
