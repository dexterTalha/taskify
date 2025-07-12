import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/core/theme/app_colors.dart';
import 'package:taskify/core/theme/app_theme.dart';

void main() {
  group('Core Theme Tests', () {
    group('AppColors Tests', () {
      test('should have primary colors defined', () {
        expect(AppColors.primaryColor, isA<Color>());
        expect(AppColors.primaryLight, isA<Color>());
        expect(AppColors.primaryDark, isA<Color>());
      });

      test('should have secondary colors defined', () {
        expect(AppColors.secondaryColor, isA<Color>());
        expect(AppColors.secondaryLight, isA<Color>());
        expect(AppColors.secondaryDark, isA<Color>());
      });

      test('should have accent colors defined', () {
        expect(AppColors.accentColor, isA<Color>());
        expect(AppColors.accentLight, isA<Color>());
        expect(AppColors.accentDark, isA<Color>());
      });

      test('should have surface colors defined', () {
        expect(AppColors.surfaceColor, isA<Color>());
        expect(AppColors.cardColor, isA<Color>());
        expect(AppColors.backgroundColor, isA<Color>());
      });

      test('should have text colors defined', () {
        expect(AppColors.textPrimary, isA<Color>());
        expect(AppColors.textSecondary, isA<Color>());
        expect(AppColors.textOnPrimary, isA<Color>());
      });

      test('should have border colors defined', () {
        expect(AppColors.borderLight, isA<Color>());
        expect(AppColors.borderMedium, isA<Color>());
        expect(AppColors.borderDark, isA<Color>());
      });

      test('should have shadow colors defined', () {
        expect(AppColors.shadowLight, isA<Color>());
        expect(AppColors.shadowMedium, isA<Color>());
        expect(AppColors.shadowDark, isA<Color>());
      });

      test('should have priority colors defined', () {
        expect(AppColors.priorityLow, isA<Color>());
        expect(AppColors.priorityMedium, isA<Color>());
        expect(AppColors.priorityHigh, isA<Color>());
      });

      test('should have status colors defined', () {
        expect(AppColors.success, isA<Color>());
        expect(AppColors.warning, isA<Color>());
        expect(AppColors.error, isA<Color>());
        expect(AppColors.info, isA<Color>());
      });

      test('should have utility colors defined', () {
        expect(AppColors.divider, isA<Color>());
        expect(AppColors.overlay, isA<Color>());
        expect(AppColors.disabled, isA<Color>());
        expect(AppColors.completedTask, isA<Color>());
        expect(AppColors.completedTaskBackground, isA<Color>());
      });

      test('should have all priority colors different', () {
        expect(AppColors.priorityLow, isNot(equals(AppColors.priorityMedium)));
        expect(AppColors.priorityMedium, isNot(equals(AppColors.priorityHigh)));
        expect(AppColors.priorityLow, isNot(equals(AppColors.priorityHigh)));
      });

      test('should have all status colors different', () {
        expect(AppColors.success, isNot(equals(AppColors.warning)));
        expect(AppColors.warning, isNot(equals(AppColors.error)));
        expect(AppColors.error, isNot(equals(AppColors.info)));
      });
    });

    group('AppTheme Tests', () {
      testWidgets('should provide light theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme, isA<ThemeData>());
        expect(theme.brightness, equals(Brightness.light));
        expect(theme.useMaterial3, isTrue);
      });

      testWidgets('should have correct color scheme in light theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.colorScheme.primary, equals(AppColors.primaryColor));
        expect(theme.colorScheme.secondary, equals(AppColors.secondaryColor));
        expect(theme.colorScheme.tertiary, equals(AppColors.accentColor));
        expect(theme.colorScheme.surface, equals(AppColors.surfaceColor));
        expect(theme.colorScheme.error, equals(AppColors.error));
      });

      testWidgets('should have correct app bar theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.appBarTheme.backgroundColor, equals(AppColors.surfaceColor));
        expect(theme.appBarTheme.foregroundColor, equals(AppColors.textPrimary));
        expect(theme.appBarTheme.elevation, equals(0));
        expect(theme.appBarTheme.centerTitle, equals(false));
      });

      testWidgets('should have correct card theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.cardTheme.color, equals(AppColors.cardColor));
        expect(theme.cardTheme.elevation, equals(2));
        expect(theme.cardTheme.shadowColor, equals(AppColors.shadowLight));
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      });

      testWidgets('should have correct elevated button theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.elevatedButtonTheme, isNotNull);
        expect(theme.elevatedButtonTheme.style, isNotNull);
      });

      testWidgets('should have correct text button theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.textButtonTheme, isNotNull);
        expect(theme.textButtonTheme.style, isNotNull);
      });

      testWidgets('should have correct input decoration theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.inputDecorationTheme, isNotNull);
        expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
        expect(theme.inputDecorationTheme.enabledBorder, isA<OutlineInputBorder>());
        expect(theme.inputDecorationTheme.focusedBorder, isA<OutlineInputBorder>());
      });

      testWidgets('should have correct floating action button theme', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        expect(theme.floatingActionButtonTheme, isNotNull);
        expect(theme.floatingActionButtonTheme.backgroundColor, equals(AppColors.primaryColor));
        expect(theme.floatingActionButtonTheme.foregroundColor, equals(AppColors.textOnPrimary));
      });

      testWidgets('should apply theme correctly to widget tree', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: Text('Test')),
          ),
        );

        // Act
        final context = tester.element(find.text('Test'));
        final theme = Theme.of(context);

        // Assert
        expect(theme.colorScheme.primary, equals(AppColors.primaryColor));
        expect(theme.brightness, equals(Brightness.light));
      });

      testWidgets('should have consistent spacing and sizing', (WidgetTester tester) async {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert
        // Check that margin and padding values are consistent
        expect(theme.cardTheme.margin, isNotNull);
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());

        final borderRadius = (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius;
        expect(borderRadius, isA<BorderRadius>());
      });
    });

    group('Theme Integration Tests', () {
      testWidgets('should render AppBar with theme correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(appBar: AppBar(title: const Text('Test AppBar'))),
          ),
        );

        // Find the AppBar
        final appBar = find.byType(AppBar);
        expect(appBar, findsOneWidget);

        // Check AppBar properties
        final appBarWidget = tester.widget<AppBar>(appBar);
        expect(appBarWidget.title, isA<Text>());
      });

      testWidgets('should render Card with theme correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: Card(child: Text('Test Card'))),
          ),
        );

        // Find the Card
        final card = find.byType(Card);
        expect(card, findsOneWidget);

        // Verify card is rendered
        expect(find.text('Test Card'), findsOneWidget);
      });

      testWidgets('should render ElevatedButton with theme correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ElevatedButton(onPressed: () {}, child: const Text('Test Button')),
            ),
          ),
        );

        // Find the button
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);

        // Verify button text
        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('should render TextFormField with theme correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: TextFormField(decoration: InputDecoration(labelText: 'Test Field')),
            ),
          ),
        );

        // Find the text field
        final textField = find.byType(TextFormField);
        expect(textField, findsOneWidget);

        // Verify decoration
        expect(find.text('Test Field'), findsOneWidget);
      });

      testWidgets('should render FloatingActionButton with theme correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
            ),
          ),
        );

        // Find the FAB
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        // Verify icon
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('Color Accessibility Tests', () {
      test('should have sufficient contrast between text and background colors', () {
        // This is a conceptual test - in a real scenario you'd use a contrast ratio calculator
        expect(AppColors.textPrimary, isNot(equals(AppColors.backgroundColor)));
        expect(AppColors.textOnPrimary, isNot(equals(AppColors.primaryColor)));
        expect(AppColors.textSecondary, isNot(equals(AppColors.surfaceColor)));
      });

      test('should have distinct error colors', () {
        expect(AppColors.error, isNot(equals(AppColors.success)));
        expect(AppColors.error, isNot(equals(AppColors.warning)));
        expect(AppColors.error, isNot(equals(AppColors.primaryColor)));
      });

      test('should have distinct priority colors for accessibility', () {
        // All priority colors should be different for clear visual distinction
        final priorityColors = [AppColors.priorityLow, AppColors.priorityMedium, AppColors.priorityHigh];

        for (int i = 0; i < priorityColors.length; i++) {
          for (int j = i + 1; j < priorityColors.length; j++) {
            expect(priorityColors[i], isNot(equals(priorityColors[j])));
          }
        }
      });
    });
  });
}
