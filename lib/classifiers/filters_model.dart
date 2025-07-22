// lib/models/filters_model.dart
class Filters {
  String gender;
  String length;

  Filters({this.gender = 'All', this.length = 'All'});

  bool apply(String itemGender, String itemLength) {
    return (gender == 'All' || gender == itemGender) &&
           (length == 'All' || length == itemLength);
  }
}
