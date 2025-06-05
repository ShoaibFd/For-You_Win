import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/tickets/ticket_services.dart';
import 'package:provider/provider.dart';

class MegaPage extends StatelessWidget {
  MegaPage({super.key});

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: AppText('Mega-4 Game', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Consumer<TicketServices>(
          builder: (context, ticket, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Center(child: AppText('Mega Ticket Search', fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.h),

                // Search Field
                SizedBox(
                  height: 55.h,
                  child: TextFormField(
                    controller: searchController,
                    cursorColor: secondaryColor,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          final order = searchController.text.trim();
                          if (order.isNotEmpty) {
                            ticket.megaTicketSearch(order);
                            log('Order number: $order');
                          }
                          searchController.clear();
                        },
                        child: Container(
                          width: 80.w,
                          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(8.r)),
                          child: Center(child: AppText('Search', fontWeight: FontWeight.bold)),
                        ),
                      ),
                      filled: true,
                      fillColor: primaryColor,
                      hintText: 'Enter Ticket Number or Order Number',
                      hintStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Loading Indicator
                if (ticket.isLoading) Center(child: AppLoading()),

                // Display API data
                if (ticket.megaTicketData != null && !ticket.isLoading)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          AppText('Ticket Result:', fontSize: 18.sp),
                          SizedBox(height: 20.h),
                          dataRow('Status', ticket.megaTicketData!['success'].toString(), valueColor: Colors.green),
                          Divider(),
                          dataRow('Order Number', ticket.megaTicketData!['order_number'].toString()),
                          Divider(),
                          dataRow('Draw Date', ticket.megaTicketData!['draw_date'].toString()),
                          Divider(),
                          dataRow('Has Winners', ticket.megaTicketData!['hasWinners'].toString()),
                          Divider(),
                          dataRow('Total Prize Sum', ticket.megaTicketData!['totalPrize'].toString()),

                          SizedBox(height: 20.h),
                          AppText('Winning Numbers:', fontSize: 18.sp),
                          SizedBox(height: 10.h),
                          Row(
                            children:
                                (ticket.megaTicketData!['winningNumbers'] as List<dynamic>?)
                                    ?.map<Widget>(
                                      (number) => CircleAvatar(
                                        backgroundColor: secondaryColor,
                                        child: Center(
                                          child: AppText(number.toString(), fontSize: 14.sp, color: Colors.white),
                                        ),
                                      ),
                                    )
                                    .toList() ??
                                [AppText("No winning numbers")],
                          ),

                          SizedBox(height: 40.h),
                          AppText('All Tickets:', fontSize: 18.sp),
                          SizedBox(height: 20.h),

                          ...ticket.megaTicketData!['validTickets']?.map<Widget>((ticketData) {
                                final candidate = ticketData['candidate'] as Map<String, dynamic>?;
                                final matchedPrice = ticketData['matched_price'] ?? 0;
                                final isWinner = matchedPrice > 0;

                                final rows = [
                                  MapEntry('Ticket ID', ticketData['id'].toString()),
                                  MapEntry('Product', ticketData['product_name'].toString()),
                                  MapEntry('Draw Date', ticketData['draw_date'].toString()),
                                  MapEntry('Order Date', ticketData['order_date'].toString()),
                                  MapEntry('Numbers', ticketData['numbers'].toString()),
                                  MapEntry('Matched Numbers', ticketData['matched_numbers'].toString()),
                                  MapEntry('Prize Amount', matchedPrice.toString()),
                                  MapEntry('Player Name', candidate?['name'].toString() ?? 'N/A'),
                                ];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Winner Badge
                                    if (isWinner)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: AppText(
                                          '🎉 WINNER!',
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    SizedBox(height: 8.h),

                                    Table(
                                      border: TableBorder.all(
                                        color: isWinner ? Colors.green : secondaryColor,
                                        width: isWinner ? 2 : 1.2,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
                                      children: List.generate((rows.length / 2).ceil(), (index) {
                                        final first = rows[index * 2];
                                        final second = index * 2 + 1 < rows.length ? rows[index * 2 + 1] : null;
                                        return TableRow(
                                          children: [
                                            tableCell('${first.key}\n${first.value}'),
                                            tableCell(second != null ? '${second.key}\n${second.value}' : ''),
                                          ],
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 16.h),

                                    // Pay Now Button (only for winning tickets)
                                    if (isWinner && ticketData['order_status'] != 1)
                                      PrimaryButton(
                                        isLoading: ticket.isLoading,
                                        onTap: () {
                                          ticket.payTicket(
                                            ticket.megaTicketData!['order_number'],
                                            matchedPrice.toString(),
                                          );
                                        },
                                        title: 'Pay Now - $matchedPrice',
                                      )
                                    else if (isWinner && ticketData['order_status'] == 1)
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(12.h),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(color: Colors.green.shade300),
                                        ),
                                        child: Center(
                                          child: AppText(
                                            '✅ Already Paid',
                                            fontSize: 14.sp,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                    SizedBox(height: 24.h),
                                  ],
                                );
                              }).toList() ??
                              [AppText("No tickets found")],
                        ],
                      ),
                    ),
                  ),

                if (!ticket.isLoading && ticket.megaTicketData == null)
                  Center(child: AppText('No Ticket.', color: Colors.grey)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget dataRow(String key, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [AppText(key, fontSize: 14.sp), AppText(value, fontSize: 14.sp, color: valueColor)],
    );
  }

  Widget tableCell(String text) {
    return Padding(padding: EdgeInsets.all(8.w), child: AppText(text, fontSize: 14.sp));
  }
}
