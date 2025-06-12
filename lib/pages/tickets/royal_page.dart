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

class RoyalPage extends StatelessWidget {
  RoyalPage({super.key});

  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
     appBar: AppBar(title: AppText('Royal-6', fontSize: 16.sp, fontWeight: FontWeight.bold)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Consumer<TicketServices>(
          builder: (context, ticket, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Center(child: AppText('Royal-6 Ticket Search', fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
                            ticket.royalTicketSearch(order);
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
                if (ticket.royalTicketData != null && !ticket.isLoading)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          AppText('Ticket Result:', fontSize: 18.sp),
                          SizedBox(height: 20.h),
                          dataRow('Status', ticket.royalTicketData!['status'].toString(), valueColor: Colors.green),
                          Divider(),
                          dataRow('Order Number', ticket.royalTicketData!['order_number'].toString()),
                          Divider(),
                          dataRow('Has Winners', ticket.royalTicketData!['has_winners'].toString()),

                          SizedBox(height: 40.h),
                          AppText('Matched Tickets:', fontSize: 18.sp),
                          SizedBox(height: 20.h),

                          ...ticket.royalTicketData!['matched_tickets']?.map<Widget>((matched) {
                                final rows = [
                                  MapEntry('Candidate', matched['candidate'].toString()),
                                  MapEntry('Ticket ID', matched['ticket_id'].toString()),
                                  MapEntry('Product', matched['product_name'].toString()),
                                  MapEntry('Draw Date', matched['draw_date'].toString()),
                                  MapEntry('Order Date', matched['order_date'].toString()),
                                  MapEntry('Numbers', matched['numbers']?.join(', ') ?? ''),
                                  MapEntry('Matched', matched['matched_numbers']?.join(', ') ?? ''),
                                  MapEntry('Prize', matched['matched_price'].toString()),
                                ];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Table(
                                      border: TableBorder.all(
                                        color: secondaryColor,
                                        width: 1.2,
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
                                    // Pay Now Button!!
                                    PrimaryButton(
                                      isLoading: ticket.isLoading,
                                      onTap: () {
                                        ticket.payTicket(
                                          ticket.royalTicketData!['order_number'],
                                          matched['matched_price'],
                                        );
                                      },
                                      title: 'Pay Now',
                                    ),
                                    SizedBox(height: 24.h),
                                  ],
                                );
                              }).toList() ??
                              [AppText("No matched tickets found")],
                        ],
                      ),
                    ),
                  ),

                if (!ticket.isLoading && ticket.royalTicketData == null)
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
