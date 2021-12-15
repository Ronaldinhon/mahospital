import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntryChartController extends GetxController {
  static EntryChartController instance = Get.find();
  RxMap<String, dynamic> ixResults = Map<String, dynamic>().obs;

  RxBool editingEntry = false.obs;
  TextEditingController mainEditor = TextEditingController(text: '');
  RxString searchString = ''.obs;

  void insertText(String inserted) {
    final text = mainEditor.text;
    final selection = mainEditor.selection;
    final newText = text.replaceRange(selection.start, selection.end, inserted);
    mainEditor.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.baseOffset + inserted.length),
    );
  }
}
