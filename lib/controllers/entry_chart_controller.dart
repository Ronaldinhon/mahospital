import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class EntryChartController extends GetxController {
  static EntryChartController instance = Get.find();
  RxMap<String, dynamic> ixResults = Map<String, dynamic>().obs;

  RxBool editingEntry = false
      .obs; // true when inFocus (single screen not feasible)? or dept has value?
  RxBool savingEntry = false.obs;
  RxString deptId = ''.obs;
  TextEditingController mainEditor = TextEditingController(text: '');
  RxString searchString = ''.obs;
  late TabController tc1;
  late TabController tc2;
  late TabController tc3;

  RxList<bool> isSelected = [
    false,
    false,
    false,
    false,
    false,
    false,
  ].obs;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController itemScrollController1 = ItemScrollController();
  final ItemPositionsListener itemPositionsListener1 =
      ItemPositionsListener.create();
  List<String> depts = [];
  List<String> entryData = [];
  List<int> searchedIndexes = [];
  final FocusNode fc = FocusNode();
  final FocusNode fc1 = FocusNode();
  final searchCont = TextEditingController();

  // ItemScrollController checkISC() {
  //   if (itemScrollController.isAttached)
  //   // itemPositionsListener.i
  // }

  final Map<String, String> medScut = {
    'pw': 'present with',
    'fv': 'fever',
    'drr': 'diarrhea',
    'oe': 'on examination',
    'pe': 'pulmonary embolism',
    'str': 'stroke',
    'st': 'start',
    'abx': 'antibiotics',
    'stty': 'seen by Dr Tan Tze Yang',
    'shx': 'seeb by Dr Hui Xian',
    'nnttsa':
        'no need to trace shit anymore, everything is at your finger tip.',
    'dni': 'DIL NAR issued, patient family understood'
  };

  void insertText(String inserted) {
    // print(fc1.hasFocus);
    // print(fc1.hasPrimaryFocus);
    if (fc1.hasPrimaryFocus) {
      final text = mainEditor.text;
      final selection = mainEditor.selection;
      final newText =
          text.replaceRange(selection.start, selection.end, inserted);
      mainEditor.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.baseOffset + inserted.length),
      );
    } else {
      mainEditor.text += inserted;
    }
  }

  void checkOnChange() {
    var editText = mainEditor.text;
    if (editText.isNotEmpty && editText.substring(editText.length - 1) == ' ') {
      var newt = editText.trimRight();
      var whiteIndex = newt.lastIndexOf(' ');
      var lastWord = newt.split(' ').last;
      var lastWordWon = lastWord.split('\n').last; // last word without \n
      var isStart = whiteIndex == -1;
      // print(lastWord.contains('\n'));
      // print(lastWordWon);
      // print(medScut[lastWordWon]);
      var isNewLine = lastWord.substring(0, 1) == '\n';
      // print(isNewLine);
      if (medScut.keys.contains(lastWordWon)) {
        var cap = medScut[lastWordWon]!.capitalize;
        var toInsert = isStart
            ? '$cap '
            : isNewLine
                ? ' \n$cap '
                : ' ${medScut[lastWord]} ';
        if (fc1.hasPrimaryFocus) {
          final text = mainEditor.text;
          final selection = mainEditor.selection;
          final newText = text.replaceRange(
              isStart ? 0 : whiteIndex, selection.end, toInsert);
          mainEditor.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
                offset: selection.baseOffset + toInsert.length),
          );
          mainEditor.selection = TextSelection.fromPosition(
              TextPosition(offset: mainEditor.text.length));
        } else {
          mainEditor.text += toInsert;
        }
      }
    }
    // print(editText.substring(editText.length - 1) == '\n');
    else if (editText.isNotEmpty &&
        editText.substring(editText.length - 1) == '\n') {
      print('hhehhhehe');
      print(editText.split('\n'));
    }

    // make choose dept then only allow edit
  }

  void replaceInsert(String inserted) {
    if (fc1.hasPrimaryFocus) {
      final text = mainEditor.text;
      final selection = mainEditor.selection;
      final whiteIndex = mainEditor.text.lastIndexOf(' ');
      var isStart = whiteIndex == -1;
      final newText = text.replaceRange(
          isStart ? 0 : whiteIndex, selection.end, ' $inserted ');
      mainEditor.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.baseOffset + inserted.length),
      );
    } else {
      final text = mainEditor.text;
      final whiteIndex = mainEditor.text.lastIndexOf(' ');
      mainEditor.text = text.replaceRange(whiteIndex, null, ' $inserted ');
    }
  }

  void searchData(String keyWord) {
    searchedIndexes = [];
    entryData.asMap().forEach((i, element) {
      for (var i = 0; i < element.length; i++) {
        if (element[i].contains(keyWord)) {
          searchedIndexes.add(i);
          break;
        }
      }
    });
    itemScrollController.scrollTo(
        index: searchedIndexes[0], duration: Duration(milliseconds: 150));
  }

  void searchDept(String dept) {
    searchedIndexes = [];
    for (var i = 0; i < depts.length; i++) {
      if (depts[i] == dept) {
        searchedIndexes.add(i);
      }
    }
    itemScrollController.scrollTo(
        index: searchedIndexes[0], duration: Duration(milliseconds: 200));
  }
}
