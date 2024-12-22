import 'package:flutter/material.dart';
import 'package:inventory_manager/components/my_loading_circle.dart';
import 'package:inventory_manager/components/my_text_field.dart';
import 'package:inventory_manager/pages/home_page.dart';
import 'package:inventory_manager/services/inventory_manager_service.dart';

class ReturnItemModal extends StatefulWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic> assignedItem;

  const ReturnItemModal({
    super.key,
    required this.item,
    required this.assignedItem,
  });

  @override
  State<ReturnItemModal> createState() => _ReturnItemModalState();
}

class _ReturnItemModalState extends State<ReturnItemModal> {
  final TextEditingController _returnReasonController = TextEditingController();
  final TextEditingController _returnAmountController = TextEditingController();

  void _validateReturn() async {
    final String returnReason = _returnReasonController.text;
    final String returnAmount = _returnAmountController.text;

    if (returnReason.isEmpty || returnAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (int.parse(returnAmount) > widget.assignedItem['quantity']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Return amount cannot be greater than assigned quantity')),
      );
      return;
    }

    showLoadingCircle(context);

    final response = await InventoryManagerService.returnItem(
      itemId: widget.item['_id'],
      returnReason: returnReason,
      returnAmount: returnAmount,
    );

    hideLoadingCircle(context);

    response.fold(
      (l) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l)),
      ),
      (r) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item returned successfully')),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyTextField(
              hintText: 'Reason for return',
              textController: _returnReasonController,
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: 'Amount to return',
              textController: _returnAmountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                _validateReturn();
              },
              child: const Text('Return'),
            ),
          ],
        ),
      ),
    );
  }
}
