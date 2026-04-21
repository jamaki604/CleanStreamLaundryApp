import 'package:clean_stream_laundry_app/features/login/controller.dart';
import 'package:clean_stream_laundry_app/features/login/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
  });

  Widget buildWidget(LoginController controller) {
    return MaterialApp(
      home: Scaffold(body: _ControllerWrapper(controller: controller)),
    );
  }

  LoginController buildController() => LoginController(
    authService: mockAuthService,
    profileService: mockProfileService,
  );

  group('LoginFormFields', () {
    group('Initial rendering', () {
      testWidgets('displays Email label', (tester) async {
        final controller = buildController();
        await tester.pumpWidget(buildWidget(controller));

        expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      });

      testWidgets('displays Password label', (tester) async {
        final controller = buildController();
        await tester.pumpWidget(buildWidget(controller));

        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      });

      testWidgets('displays email and lock icons in blue', (tester) async {
        final controller = buildController();
        await tester.pumpWidget(buildWidget(controller));

        final emailIcon = tester.widget<Icon>(find.byIcon(Icons.email));
        final lockIcon = tester.widget<Icon>(find.byIcon(Icons.lock));

        expect(emailIcon.color, Colors.blue);
        expect(lockIcon.color, Colors.blue);
      });

      testWidgets('password is obscured by default', (tester) async {
        final controller = buildController();
        await tester.pumpWidget(buildWidget(controller));

        final field = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Password'),
        );
        expect(field.obscureText, isTrue);
      });

      testWidgets('shows visibility_off icon initially', (tester) async {
        final controller = buildController();
        await tester.pumpWidget(buildWidget(controller));

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });
    });

    group('Error state', () {
      testWidgets('shows error label text when setErrorColors called',
              (tester) async {
            final controller = buildController();
            await tester.pumpWidget(buildWidget(controller));

            controller.setErrorColors();
            await tester.pump();

            expect(
              find.widgetWithText(TextField, 'Invalid Password or Email'),
              findsNWidgets(2),
            );
          });

      testWidgets('shows red icons after setErrorColors', (tester) async {
        final controller = buildController();
        await tester.pumpWidget(buildWidget(controller));

        controller.setErrorColors();
        await tester.pump();

        final emailIcon = tester.widget<Icon>(find.byIcon(Icons.email));
        final lockIcon = tester.widget<Icon>(find.byIcon(Icons.lock));

        expect(emailIcon.color, Colors.red);
        expect(lockIcon.color, Colors.red);
      });
    });

    group('Password visibility toggle', () {
      testWidgets('tapping visibility icon toggles obscureText',
              (tester) async {
            final controller = buildController();
            await tester.pumpWidget(buildWidget(controller));

            // onPressed inside the IconButton calls togglePasswordVisibility
            await tester.tap(find.byIcon(Icons.visibility_off));
            await tester.pump();

            final field = tester.widget<TextField>(
              find.widgetWithText(TextField, 'Password'),
            );
            expect(field.obscureText, isFalse);
          });

      testWidgets('shows visibility icon after toggling', (tester) async {
        final controller = buildController();
        controller.togglePasswordVisibility();
        await tester.pumpWidget(buildWidget(controller));

        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);
      });
    });
  });
}

class _ControllerWrapper extends StatefulWidget {
  final LoginController controller;
  const _ControllerWrapper({required this.controller});

  @override
  State<_ControllerWrapper> createState() => _ControllerWrapperState();
}

class _ControllerWrapperState extends State<_ControllerWrapper> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FormFields(controller: widget.controller);
}