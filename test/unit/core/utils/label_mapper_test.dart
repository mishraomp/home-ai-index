import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/utils/label_mapper.dart';

void main() {
  group('LabelMapper', () {
    late LabelMapper mapper;

    setUp(() {
      mapper = LabelMapper();
    });

    group('mapLabelToCategory - direct match', () {
      test('should map groceries labels correctly', () {
        expect(mapper.mapLabelToCategory('apple'), equals('groceries'));
        expect(mapper.mapLabelToCategory('banana'), equals('groceries'));
        expect(mapper.mapLabelToCategory('milk'), equals('groceries'));
        expect(mapper.mapLabelToCategory('bread'), equals('groceries'));
      });

      test('should map electronics labels correctly', () {
        expect(mapper.mapLabelToCategory('laptop'), equals('electronics'));
        expect(mapper.mapLabelToCategory('phone'), equals('electronics'));
        expect(mapper.mapLabelToCategory('headphones'), equals('electronics'));
        expect(mapper.mapLabelToCategory('television'), equals('electronics'));
      });

      test('should map furniture labels correctly', () {
        expect(mapper.mapLabelToCategory('chair'), equals('furniture'));
        expect(mapper.mapLabelToCategory('table'), equals('furniture'));
        expect(mapper.mapLabelToCategory('sofa'), equals('furniture'));
        expect(mapper.mapLabelToCategory('desk'), equals('furniture'));
      });

      test('should map clothing labels correctly', () {
        expect(mapper.mapLabelToCategory('shirt'), equals('clothing'));
        expect(mapper.mapLabelToCategory('jeans'), equals('clothing'));
        expect(mapper.mapLabelToCategory('dress'), equals('clothing'));
        expect(mapper.mapLabelToCategory('shoes'), equals('clothing'));
      });

      test('should map books labels correctly', () {
        expect(mapper.mapLabelToCategory('book'), equals('books'));
        expect(mapper.mapLabelToCategory('novel'), equals('books'));
        expect(mapper.mapLabelToCategory('textbook'), equals('books'));
        expect(mapper.mapLabelToCategory('magazine'), equals('books'));
      });

      test('should map media labels correctly', () {
        expect(mapper.mapLabelToCategory('cd'), equals('media'));
        expect(mapper.mapLabelToCategory('dvd'), equals('media'));
        expect(mapper.mapLabelToCategory('blu-ray'), equals('media'));
        expect(mapper.mapLabelToCategory('vinyl'), equals('media'));
      });

      test('should map tools labels correctly', () {
        expect(mapper.mapLabelToCategory('hammer'), equals('tools'));
        expect(mapper.mapLabelToCategory('screwdriver'), equals('tools'));
        expect(mapper.mapLabelToCategory('drill'), equals('tools'));
        expect(mapper.mapLabelToCategory('wrench'), equals('tools'));
      });

      test('should map kitchen labels correctly', () {
        expect(mapper.mapLabelToCategory('plate'), equals('kitchen'));
        expect(mapper.mapLabelToCategory('fork'), equals('kitchen'));
        expect(mapper.mapLabelToCategory('pot'), equals('kitchen'));
        expect(mapper.mapLabelToCategory('pan'), equals('kitchen'));
      });

      test('should map appliances labels correctly', () {
        expect(mapper.mapLabelToCategory('refrigerator'), equals('appliances'));
        expect(mapper.mapLabelToCategory('microwave'), equals('appliances'));
        expect(mapper.mapLabelToCategory('dishwasher'), equals('appliances'));
        expect(
          mapper.mapLabelToCategory('washing machine'),
          equals('appliances'),
        );
      });

      test('should map toys labels correctly', () {
        expect(mapper.mapLabelToCategory('lego'), equals('toys'));
        expect(mapper.mapLabelToCategory('doll'), equals('toys'));
        expect(mapper.mapLabelToCategory('action figure'), equals('toys'));
        expect(mapper.mapLabelToCategory('board game'), equals('toys'));
      });

      test('should map sports labels correctly', () {
        expect(mapper.mapLabelToCategory('basketball'), equals('sports'));
        expect(mapper.mapLabelToCategory('soccer ball'), equals('sports'));
        expect(mapper.mapLabelToCategory('tennis racket'), equals('sports'));
        expect(mapper.mapLabelToCategory('bicycle'), equals('sports'));
      });

      test('should map outdoor labels correctly', () {
        expect(mapper.mapLabelToCategory('tent'), equals('outdoor'));
        expect(mapper.mapLabelToCategory('sleeping bag'), equals('outdoor'));
        expect(mapper.mapLabelToCategory('backpack'), equals('outdoor'));
        expect(mapper.mapLabelToCategory('camping chair'), equals('outdoor'));
      });

      test('should map personal care labels correctly', () {
        expect(mapper.mapLabelToCategory('shampoo'), equals('personal care'));
        expect(
          mapper.mapLabelToCategory('toothbrush'),
          equals('personal care'),
        );
        expect(mapper.mapLabelToCategory('soap'), equals('personal care'));
        expect(mapper.mapLabelToCategory('deodorant'), equals('personal care'));
      });

      test('should map office labels correctly', () {
        expect(mapper.mapLabelToCategory('pen'), equals('office'));
        expect(mapper.mapLabelToCategory('notebook'), equals('office'));
        expect(mapper.mapLabelToCategory('stapler'), equals('office'));
        expect(mapper.mapLabelToCategory('paper'), equals('office'));
      });
    });

    group('mapLabelToCategory - case insensitive', () {
      test('should handle uppercase labels', () {
        expect(mapper.mapLabelToCategory('APPLE'), equals('groceries'));
        expect(mapper.mapLabelToCategory('LAPTOP'), equals('electronics'));
        expect(mapper.mapLabelToCategory('CHAIR'), equals('furniture'));
      });

      test('should handle mixed case labels', () {
        expect(mapper.mapLabelToCategory('ApPlE'), equals('groceries'));
        expect(mapper.mapLabelToCategory('LaPtOp'), equals('electronics'));
        expect(mapper.mapLabelToCategory('ChAiR'), equals('furniture'));
      });

      test('should handle labels with leading/trailing whitespace', () {
        expect(mapper.mapLabelToCategory('  apple  '), equals('groceries'));
        expect(mapper.mapLabelToCategory('\tlaptop\t'), equals('electronics'));
      });
    });

    group('mapLabelToCategory - partial match', () {
      test('should match labels containing category keywords', () {
        expect(mapper.mapLabelToCategory('red apple'), equals('groceries'));
        expect(
          mapper.mapLabelToCategory('gaming laptop'),
          equals('electronics'),
        );
        expect(mapper.mapLabelToCategory('office chair'), equals('furniture'));
      });

      test('should match fruit keyword to groceries', () {
        expect(mapper.mapLabelToCategory('fresh fruit'), equals('groceries'));
        expect(
          mapper.mapLabelToCategory('tropical fruit'),
          equals('groceries'),
        );
      });

      test('should match vegetable keyword to groceries', () {
        expect(
          mapper.mapLabelToCategory('green vegetable'),
          equals('groceries'),
        );
        expect(
          mapper.mapLabelToCategory('root vegetable'),
          equals('groceries'),
        );
      });

      test('should match food keyword to groceries', () {
        expect(mapper.mapLabelToCategory('canned food'), equals('groceries'));
        expect(mapper.mapLabelToCategory('frozen food'), equals('groceries'));
      });

      test('should match computer keyword to electronics', () {
        expect(
          mapper.mapLabelToCategory('desktop computer'),
          equals('electronics'),
        );
        expect(
          mapper.mapLabelToCategory('computer monitor'),
          equals('electronics'),
        );
      });

      test('should match electronic keyword to electronics', () {
        expect(
          mapper.mapLabelToCategory('electronic device'),
          equals('electronics'),
        );
        expect(
          mapper.mapLabelToCategory('electronic gadget'),
          equals('electronics'),
        );
      });

      test('should match clothing keywords', () {
        expect(
          mapper.mapLabelToCategory('winter clothing'),
          equals('clothing'),
        );
        expect(mapper.mapLabelToCategory('sports apparel'), equals('clothing'));
      });
    });

    group('mapLabelToCategory - null return', () {
      test('should return null for unknown labels', () {
        expect(mapper.mapLabelToCategory('unknown'), isNull);
        expect(mapper.mapLabelToCategory('xyz123'), isNull);
        expect(mapper.mapLabelToCategory('random text'), isNull);
      });

      test('should return null for empty label', () {
        expect(mapper.mapLabelToCategory(''), isNull);
        expect(mapper.mapLabelToCategory('   '), isNull);
      });
    });

    group('mapLabelToCategoryWithFallback', () {
      test('should return mapped category when found', () {
        final result = mapper.mapLabelToCategoryWithFallback('apple');
        expect(result, equals('groceries'));
      });

      test('should default to miscellaneous when label is unknown', () {
        final result = mapper.mapLabelToCategoryWithFallback('unknown');
        expect(result, equals('other'));
      });
    });

    group('canMap', () {
      test('should return true for mappable labels', () {
        expect(mapper.canMap('apple'), isTrue);
        expect(mapper.canMap('laptop'), isTrue);
        expect(mapper.canMap('chair'), isTrue);
      });

      test('should return false for unmappable labels', () {
        expect(mapper.canMap('unknown'), isFalse);
        expect(mapper.canMap('xyz123'), isFalse);
      });
    });

    group('supportedCategories', () {
      test('should return all 15 categories', () {
        final categories = LabelMapper.supportedCategories;

        expect(categories.length, equals(15));
        expect(categories, contains('groceries'));
        expect(categories, contains('electronics'));
        expect(categories, contains('furniture'));
        expect(categories, contains('clothing'));
        expect(categories, contains('books'));
        expect(categories, contains('media'));
        expect(categories, contains('tools'));
        expect(categories, contains('kitchen'));
        expect(categories, contains('appliances'));
        expect(categories, contains('toys'));
        expect(categories, contains('sports'));
        expect(categories, contains('outdoor'));
        expect(categories, contains('personal care'));
        expect(categories, contains('office'));
        expect(categories, contains('other'));
      });
    });

    group('real-world Cloud Vision labels', () {
      test('should map common Cloud Vision food labels', () {
        expect(mapper.mapLabelToCategory('Food'), equals('groceries'));
        expect(mapper.mapLabelToCategory('Fruit'), equals('groceries'));
        expect(mapper.mapLabelToCategory('Vegetable'), equals('groceries'));
        expect(mapper.mapLabelToCategory('Produce'), equals('groceries'));
      });

      test('should map common Cloud Vision technology labels', () {
        expect(mapper.mapLabelToCategory('Electronics'), equals('electronics'));
        expect(
          mapper.mapLabelToCategory('Mobile phone'),
          equals('electronics'),
        );
        expect(mapper.mapLabelToCategory('Computer'), equals('electronics'));
      });

      test('should map common Cloud Vision home labels', () {
        expect(mapper.mapLabelToCategory('Furniture'), equals('furniture'));
        expect(mapper.mapLabelToCategory('Table'), equals('furniture'));
      });
    });
  });
}
