import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../screen/bed_screen.dart';

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
  ].obs;

  RxList<bool> isSelected1 = [
    false,
  ].obs;

  RxInt start = 10000.obs;
  RxInt end = 10000.obs;
  // need to try out above

  late RxString editId = ''.obs;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController itemScrollController1 = ItemScrollController();
  final ItemPositionsListener itemPositionsListener1 =
      ItemPositionsListener.create();
  RxList<String> depts = [''].obs;
  List<String> deptList = [];
  List<String> entryData = [];
  List<int> searchedIndexes = [];
  List<int> searchedIndexes1 = [];
  final FocusNode fc = FocusNode();
  final FocusNode fc1 = FocusNode();
  final searchCont = TextEditingController();
  final searchCont1 = TextEditingController();
  final pgCodeCont = TextEditingController();
  RxBool printingRec = false.obs;
  RxBool printingSum = false.obs;
  RxBool printingDisc = false.obs;
  RxBool printingFC = false.obs;
  RxBool entryFC = false.obs;
  RxBool editFCparam = false.obs;
  RxBool editFcEntry = false.obs;
  RxInt initialRows = 8.obs;
  // Map<dynamic, dynamic> entries = {};

  // ItemScrollController checkISC() {
  //   if (itemScrollController.isAttached)
  //   // itemPositionsListener.i
  // }

  List<List<String>> wer =
      []; // it seems that im saving it as string, then it can be saved as an empty string
  int numberOfDays = 0;
  List<int> ascNum = [];
  List orderedDateTime = [];
  Map<String, List<String>> masterMap = {};

  late ByteData? bb;
  late ByteData? cc;

  List<Pt> asdljk = [];
  late Future<RxList<List<String>>> bloodIx;


  // List<String> bloodParam = [
  //   'Hb',
  //   'Hct',
  //   'Plt',
  //   'Twc',
  //   'Na',
  //   'K',
  //   'Cl',
  //   'Urea',
  //   'Creat',
  // ];

  Map<String, String> ecCorrespondKeys = {};
  List<String> ecIdenTexts = [];

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

  TextEditingController entryCont = TextEditingController();
  TextEditingController dxCont = TextEditingController();
  TextEditingController planCont = TextEditingController();
  TextEditingController drugCont = TextEditingController();

  RxMap<String, String> vitalsTitle = {
    'HR/min': '',
    'SYS/mmHg': '',
    'DIA/mmHg': '',
    'RR/min': '',
    'SpO2': '',
    'Temp': '',
    'Notes': '',
  }.obs;

  RxMap<String, String> bloodResMap = {
    'Hb': '',
    'Hct': '',
    'Plt': '',
    'Twc': '',
    'Na': '',
    'K': '',
    'Cl': '',
    'Urea': '',
    'Creat': '',
    'TProt': '',
    'Alb': '',
    'Glob': '',
    'TBil': '',
    'ALT': '',
    'AST': '',
    'ALP': '',
    'Ca': '', // watchout
    'Phos': '',
    'Mg': '',
    'CK': '',
    'LDH': '',
    'Notes': '',
  }.obs;

  void makeStart(int index) {
    start.value = index;
    if (end.value == index) removeEnd();
  }

  void removeStart() => start.value = currentWPLC.cwpm.value.entries.length;

  void makeEnd(int index) {
    end.value = index;
    if (start.value == index) removeStart();
  }

  void removeEnd() => end.value = currentWPLC.cwpm.value.entries.length;

  void falsifyIS(List<bool> sell) {
    // isSelected.value = List.generate(isSelected.length, (i) => false);
    sell = List.generate(sell.length, (i) => false);
  }

  void setupDepts() {
    depts.value = deptList.toSet().toList();
    isSelected.value = List.generate(depts.length, (i) => false);
    isSelected1.value = List.generate(depts.length, (i) => false);
    // start.value = deptList.length;
    // end.value = deptList.length;
  }

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

  void searchData(String keyWord, ItemScrollController isc,
      ItemPositionsListener ipc, List<bool> sell) {
    searchedIndexes = [];
    falsifyIS(sell);
    // var dd = [];
    // entryData.forEach(
    // (s) => dd.add(s.toUpperCase().contains(keyWord.toUpperCase())));
    // print(entryData.length); // not reliable
    // print(currentWPLC.cwpm.value.entries.length);
    currentWPLC.cwpm.value.entryDataList.asMap().forEach((i, element) {
      if (element.toUpperCase().contains(keyWord.toUpperCase())) {
        searchedIndexes.add(i);
      }
    });
    print(searchedIndexes);
    if (searchedIndexes.isNotEmpty)
      isc.scrollTo(
          index: searchedIndexes[0], duration: Duration(milliseconds: 150));
  }

  void upSearch(ItemScrollController isc, ItemPositionsListener ipc) {
    print(searchedIndexes);
    int currentPos = ipc.itemPositions.value.first.index;
    if (searchedIndexes.length >= 2) {
      int intTo = searchedIndexes.reversed
          .firstWhere((ind) => ind < currentPos, orElse: () => -1);
      if (intTo > -1) {
        isc.scrollTo(index: intTo, duration: Duration(milliseconds: 150));
      }
    }
  }

  void downSearch(ItemScrollController isc, ItemPositionsListener ipc) {
    print(searchedIndexes);
    int currentPos = ipc.itemPositions.value.first.index;
    if (searchedIndexes.length >= 2) {
      int intTo = searchedIndexes.firstWhere((ind) => ind > currentPos,
          orElse: () => -1);
      if (intTo > -1) {
        isc.scrollTo(index: intTo, duration: Duration(milliseconds: 150));
      }
    }
  }

  void searchDept(
      String dept, ItemScrollController isc, ItemPositionsListener ipc) {
    searchedIndexes = [];
    // for (var i = 0; i < deptList.length; i++) {
    //   if (deptList[i] == dept) {
    //     searchedIndexes.add(i);
    //   }
    // }
    print(dept);
    print(currentWPLC.cwpm.value.entryDeptList);
    currentWPLC.cwpm.value.entryDeptList.asMap().forEach((i, element) {
      if (element == dept) {
        searchedIndexes.add(i);
      }
    });
    isc.scrollTo(
        index: searchedIndexes[0], duration: Duration(milliseconds: 150));
  }
}

class Pt {
  late String hNum;
  late String name;
  late String ic;
  late String phone;
  late String add;

  Pt(this.hNum, this.name, this.ic, this.phone, this.add);
}
