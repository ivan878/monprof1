// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/subscription/controllers/mes_transactions_controller.dart';
import 'package:monprof/prepa/subscription/data/models/transaction_model.dart';
import 'package:provider/provider.dart';

class MesTransactionsScreen extends StatefulWidget {
  const MesTransactionsScreen({super.key});

  @override
  State<MesTransactionsScreen> createState() => _MesTransactionsScreenState();
}

class _MesTransactionsScreenState extends State<MesTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MesTransactionsController>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MesTransactionsController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const SimpleText(
              text: 'Transactions',
              size: 17,
              weight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, MesTransactionsController controller) {
    if (controller.state.isLoading && controller.items.isEmpty) {
      return const Loading();
    }

    if (controller.state.hasError && controller.items.isEmpty) {
      return ErrorPage(
        errorMessage:
            controller.state.errorModel?.error ?? 'Erreur de chargement',
        reload: controller.loadTransactions,
      );
    }

    if (controller.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            SimpleText(text: 'Aucune transaction', size: 15, color: onGrey300),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: prepaPrimaryColor,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 300 &&
              !controller.state.isLoading &&
              controller.hasMore) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _TransactionCard(tx: controller.items[index]);
          },
        ),
      ),
    );
  }
}

// ── Carte transaction ────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _statusColor(tx.status);
    final isDebit = tx.sens?.toUpperCase() == 'DEBIT' ||
        tx.sens?.toUpperCase() == 'OUT';
    final amountColor =
        isDebit ? Colors.red.shade600 : Colors.green.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Direction icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: amountColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDebit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: amountColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Reference + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SimpleText(
                        text: tx.reference ?? 'Transaction',
                        size: 13,
                        weight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tx.phoneNumber != null)
                        SimpleText(
                          text: tx.phoneNumber!,
                          size: 12,
                          color: onGrey300,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount + status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SimpleText(
                      text:
                          '${isDebit ? '-' : '+'}${tx.amount?.toStringAsFixed(0) ?? '0'} F',
                      size: 14,
                      weight: FontWeight.bold,
                      color: amountColor,
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SimpleText(
                        text: tx.status ?? 'N/A',
                        size: 10,
                        weight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rejection reason
          if (tx.raisonReject != null &&
              tx.status?.toUpperCase() == 'FAILED') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 13, color: Colors.red.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SimpleText(
                        text: tx.raisonReject!,
                        size: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Footer: date + externalId
          if (tx.createdAt != null) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 5),
                  SimpleText(
                    text: fmt.format(tx.createdAt!),
                    size: 11,
                    color: onGrey300,
                  ),
                  const Spacer(),
                  if (tx.externalId != null)
                    Flexible(
                      child: SimpleText(
                        text: 'ext: ${tx.externalId!}',
                        size: 10,
                        color: Colors.grey.shade400,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green.shade700;
      case 'FAILED':
        return Colors.red.shade700;
      case 'PENDING':
        return Colors.orange.shade700;
      case 'CANCELED':
      case 'CANCELLED':
        return Colors.grey.shade500;
      default:
        return prepaPrimaryColor;
    }
  }
}
