  // Widget numbersInRow(List<dynamic> numbers) {
  //   return Wrap(
  //     alignment: WrapAlignment.center,
  //     spacing: 8.w,
  //     runSpacing: 8.h,
  //     children:
  //         numbers.map((number) {
  //           return Container(
  //             width: 40.w,
  //             height: 40.h,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: primaryColor, width: 2),
  //               color: Colors.white,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.3),
  //                   spreadRadius: 1,
  //                   blurRadius: 3,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Center(
  //               child: AppText(
  //                 number.toString().padLeft(2, '0'),
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: primaryColor,
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //   );
  // }
