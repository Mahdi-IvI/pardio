import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pardio/radio_model.dart';

class RadioItem extends StatelessWidget {
  final RadioModel model;
  final bool firstElement;
  const RadioItem({super.key, required this.model, required this.firstElement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: firstElement? EdgeInsets.only(right: 4,top: 8,bottom: 8,left: 8)
          :EdgeInsets.only(right: 8,top: 8,bottom: 8,left: 4),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 235, 59, 1),
            borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          model.img))),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(
                    model.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
