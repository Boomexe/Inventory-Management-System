import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventory_manager/components/drawer/my_drawer.dart';
import 'package:inventory_manager/components/return_item_modal.dart';
import 'package:inventory_manager/components/shimmer/shimmer_list.dart';
import 'package:inventory_manager/components/shimmer/shimmer_list_tile.dart';
import 'package:inventory_manager/services/inventory_manager_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _returnItem(
    context,
    Map<String, dynamic> item,
    Map<String, dynamic> assignedItem,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Return Item: ${item['name']}')),
        content: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ReturnItemModal(
            item: item,
            assignedItem: assignedItem,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _futureListBuilder(),
    );
  }

  Widget _futureListBuilder() {
    return FutureBuilder(
      future: InventoryManagerService.getAssignedItems(),
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
                return const Center(child: Text('No assigned items'));
              }

              return ListView.builder(
                itemCount: r.length,
                itemBuilder: (BuildContext context, int index) {
                  return _futureListTileBuilder(r[index]);
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

  Widget _futureListTileBuilder(Map<String, dynamic> data) {
    return FutureBuilder(
      future: InventoryManagerService.getItem(data['item_id']),
      builder: (BuildContext context, AsyncSnapshot<Either> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerListTile();
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          final items = snapshot.data!.fold(
            (l) => Text(l),
            (r) {
              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.25,
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _returnItem(context, r, data),
                      icon: Icons.keyboard_return,
                      label: 'Return',
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: _leadingBuilder(r['image'], r['name'][0]),
                  title: Text(r['name']),
                  subtitle: Text(
                      '${r['description']}\nQuantity: ${data['quantity']}\nStatus: ${r['status']}'),
                  trailing: Text('Assigned: ${data['date_assigned']}'),
                  visualDensity: VisualDensity.comfortable,
                ),
              );
            },
          );

          return items;
        }

        return const SizedBox();
      },
    );
  }

  Widget _leadingBuilder(String iconUrl, String alt) {
    final image = _getWebImage(iconUrl);

    return image.fold(
      (l) => CircleAvatar(
        child: Text(alt),
      ),
      (r) => CircleAvatar(
        backgroundImage: r.image,
      ),
    );
  }

  Either<String, Image> _getWebImage(String url) {
    try {
      Image image = Image.network(url);
      return Right(image);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
