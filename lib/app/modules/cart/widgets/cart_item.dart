import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopperz/app/modules/cart/controller/cart_controller.dart';
import 'package:shopperz/app/modules/cart/model/cartmodel.dart';
import 'package:shopperz/widgets/textwidget.dart';

class CartWidget extends StatefulWidget {
 const CartWidget(
      {super.key,
        required this.item, 
        required this.controller
      });
  final Product? item;
  final CartController controller;

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late TextEditingController _qtyController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.item?.quantity ?? '0',
    );

    _focusNode = FocusNode();

    // ✅ API triggers when user leaves (disables) the input field
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _onQtyEditingDone();
      }
    });
  }

  void _onQtyEditingDone() {
  final enteredQty = int.tryParse(_qtyController.text.trim());
  if (enteredQty == null || enteredQty < 1) {
    _qtyController.text = widget.item?.quantity ?? '1';
    return;
  }
  final currentQty = int.tryParse(widget.item?.quantity ?? '1') ?? 1;
  if (enteredQty == currentQty) return;

  final index = widget.controller.wishlistProducts
      .indexWhere((p) => p.cartId == widget.item?.cartId);

  if (widget.controller.isLoggedIn) {
    widget.controller.updateQtyWishlist(
      cartId: widget.item?.cartId ?? '',
      newQty: enteredQty,
      index: index,
    );
  } else {
    widget.controller.updateQtyGuest(
      cartId: widget.item?.cartId ?? '',
      newQty: enteredQty,
      index: index,
    );
  }
}
  @override
  void dispose() {
    _qtyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      final liveItem = widget.controller.wishlistProducts.firstWhereOrNull(
        (p) => p.cartId == widget.item?.cartId,
      );

      final currentQty = liveItem?.quantity ?? widget.item?.quantity ?? '1';

       if (!_focusNode.hasFocus && _qtyController.text != currentQty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_focusNode.hasFocus) {
            _qtyController.text = currentQty;
          }
        });
      }

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
              imageUrl: widget.item!.attributeImageUrl.toString().trim(),
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
                  text: widget.item!.name,
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
                    text: "QTY: $currentQty - ${liveItem?.unit ?? widget.item?.unit ?? ''}",
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: const Color.fromARGB(255, 42, 98, 195),
                  ),
                ),
                SizedBox(height: 11,),
    
                Row(
                  children: [
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
                              if(widget.controller.isLoggedIn){
                                widget.controller.minusOneItemInWishlist(widget.item!.cartId ??'');
                              }else{
                                widget.controller.minusOneItemGuest(widget.item!.cartId ?? '');
                              }                              
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
                          // Obx((){
                            // final current = controller.itemHistoryList.firstWhere(
                            //   (i) => i.nopProductId == item!.nopProductId,
                            //   orElse: () => item!,
                            // );
                            // return 
                          //   TextWidget(
                          //   text: widget.item!.quantity?? '0',
                          //   fontSize: 18,
                          //   fontWeight: FontWeight.w600,
                          // ),//;
                          // }),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _qtyController,
                              focusNode: _focusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) {
                                _focusNode.unfocus();
                              },
                            ),
                          ),
                          SizedBox(width: 12,),
                          GestureDetector(
                            onTap: () {
                              if(widget.controller.isLoggedIn){
                                widget.controller.addOneItemInWishlist(widget.item!.cartId ??'');
                              }else{
                                widget.controller.addOneItemGuest(widget.item!.cartId ?? '');
                              }
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
                    ),
                  

                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          if(widget.controller.isLoggedIn){
                                widget.controller.deleteItemInWishlist(widget.item!.cartId ??'');
                              }else{
                                widget.controller.deleteItemGuest(widget.item!.cartId ?? '');
                              }
                        },
                        child: Icon(Icons.delete),
                      )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
    });
  }
}
