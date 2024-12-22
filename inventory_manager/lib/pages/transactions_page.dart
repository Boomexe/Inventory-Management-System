import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:inventory_manager/components/drawer/my_drawer.dart';
import 'package:inventory_manager/components/shimmer/shimmer_list.dart';
import 'package:inventory_manager/services/inventory_manager_service.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: _futureListBuilder(),
    );
  }

  Widget _futureListBuilder() {
    return FutureBuilder(
      future: InventoryManagerService.getTransactions(),
      builder: (BuildContext context, AsyncSnapshot<Either> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Center(child: CircularProgressIndicator());
          return const ShimmerList(itemCount: 25);
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          final items = snapshot.data!.fold(
            (l) => Text(l),
            (r) {
              if (r.length == 0) {
                return const Center(child: Text('No transactions'));
              }

              return ListView.builder(
                itemCount: r.length,
                itemBuilder: (BuildContext context, int index) {
                  return _listTileBuilder(r[index]);
                },
              );
            },
          );

          return items;
        }

        return const SizedBox();
      },
    );
  }

  Widget _listTileBuilder(Map<String, dynamic> data) {
    return ListTile(
      title: Text(data['item_name']),
      subtitle: Text(
        'ID: ${data['item_id']}\nQuantity: ${data['quantity']}\nReason: ${data['reason']}\nType: ${data['type']}',
      ),
      trailing: Text('${data['date']}'),
      visualDensity: VisualDensity.comfortable,
    );
  }
}
