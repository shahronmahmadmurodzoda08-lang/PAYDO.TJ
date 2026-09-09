/// Категорияҳои маҳсулот (banди 8 спецификатсия).
/// PHASE 4: static list. Дар PHASE 19 (Admin Panel) идора кардани
/// категорияҳо аз Firestore (`categories` collection) илова мешавад —
/// он вақт ин feҳрист ба сифати "seed data" истифода мешавад.
class ProductCategories {
  ProductCategories._();

  static const List<String> all = [
    'Electronics',
    'Phones',
    'Computers',
    'Clothes',
    'Shoes',
    'Home',
    'Furniture',
    'Food',
    'Beauty',
    'Auto',
    'Books',
    'Services',
    'Other',
  ];

  /// Номи Тоҷикии категория барои намоиш дар UI.
  static String labelOf(String key) {
    switch (key) {
      case 'Electronics':
        return 'Электроника';
      case 'Phones':
        return 'Телефонҳо';
      case 'Computers':
        return 'Компютерҳо';
      case 'Clothes':
        return 'Либос';
      case 'Shoes':
        return 'Пойафзол';
      case 'Home':
        return 'Хона';
      case 'Furniture':
        return 'Мебел';
      case 'Food':
        return 'Хӯрока';
      case 'Beauty':
        return 'Зебоӣ';
      case 'Auto':
        return 'Мошин';
      case 'Books':
        return 'Китобҳо';
      case 'Services':
        return 'Хизматрасонӣ';
      default:
        return 'Дигар';
    }
  }
}
