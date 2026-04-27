import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopperz/app/modules/order/controller/item_controller.dart';
import 'package:shopperz/data/model/item_history_model.dart';
import 'package:shopperz/widgets/textwidget.dart';
import 'package:get/get.dart';

class ItemHistoryWidget extends StatelessWidget {
  const ItemHistoryWidget({super.key, required this.item, required this.controller,});
  final OrderItemHistory? item;
  final ItemController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height:65 ,
            width: 65,
            child: CachedNetworkImage(
              imageUrl: item!.image ?? '',
              fit: BoxFit.cover,
              memCacheHeight: 100,
              memCacheWidth: 100,
              errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: Colors.grey[300]),
              placeholder: (_, __) => Container(color: Colors.grey[100]),
            ),
          ),
          SizedBox(width: 8,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: item!.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
                SizedBox(height: 8,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextWidget(
                    text: "QTY: ${item!.itemQty} - ${item!.unit}",
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: const Color.fromARGB(255, 42, 98, 195),
                  ),
                ),
                SizedBox(height: 11,),
    
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7,vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.minusQtyAndRefresh(
                            productId: item!.nopProductId ?? '',
                            quantity: '1',
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 11,
                          child: Icon(
                            Icons.remove, 
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Obx((){
                        final current = controller.itemHistoryList.firstWhere(
                          (i) => i.nopProductId == item!.nopProductId,
                          orElse: () => item!,
                        );
                        return TextWidget(
                        text: current.newQty ?? '0',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      );
                      }),
                      SizedBox(width: 12,),
                      GestureDetector(
                        onTap: () {
                          controller.plusQuantityFromHistory(productId: item!.nopProductId ??'', quantity: '1');
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 11,
                          child: Icon(
                            Icons.add, 
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
