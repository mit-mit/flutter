// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<DropdownMenuEntry> menuChildren = <DropdownMenuEntry>[];

  for (final TestMenu value in TestMenu.values) {
    final DropdownMenuEntry entry = DropdownMenuEntry(label: value.label);
    menuChildren.add(entry);
  }

  Widget buildTest(ThemeData themeData, List<DropdownMenuEntry> entries,
      {double? width, double? menuHeight, Widget? leadingIcon, Widget? label}) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          label: label,
          leadingIcon: leadingIcon,
          width: width,
          menuHeight: menuHeight,
          dropdownMenuEntries: entries,
        ),
      ),
    );
  }

  testWidgets('DropdownMenu defaults', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(buildTest(themeData, menuChildren));

    final EditableText editableText = tester.widget(find.byType(EditableText));
    expect(editableText.style.color, themeData.textTheme.labelLarge!.color);
    expect(editableText.style.background, themeData.textTheme.labelLarge!.background);
    expect(editableText.style.shadows, themeData.textTheme.labelLarge!.shadows);
    expect(editableText.style.decoration, themeData.textTheme.labelLarge!.decoration);
    expect(editableText.style.locale, themeData.textTheme.labelLarge!.locale);
    expect(editableText.style.wordSpacing, themeData.textTheme.labelLarge!.wordSpacing);

    final TextField textField = tester.widget(find.byType(TextField));
    expect(textField.decoration?.border, const OutlineInputBorder());

    await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_drop_down).first);
    await tester.pump();
    expect(find.byType(MenuAnchor), findsOneWidget);

    final Finder menuMaterial = find.ancestor(
      of: find.widgetWithText(TextButton, TestMenu.mainMenu0.label),
      matching: find.byType(Material),
    ).last;
    Material material = tester.widget<Material>(menuMaterial);
    expect(material.color, themeData.colorScheme.surface);
    expect(material.shadowColor, themeData.colorScheme.shadow);
    expect(material.surfaceTintColor, themeData.colorScheme.surfaceTint);
    expect(material.elevation, 3.0);
    expect(material.shape, const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))));

    final Finder buttonMaterial = find.descendant(
      of: find.byType(TextButton),
      matching: find.byType(Material),
    ).last;

    material = tester.widget<Material>(buttonMaterial);
    expect(material.color, Colors.transparent);
    expect(material.elevation, 0.0);
    expect(material.shape, const RoundedRectangleBorder());
    expect(material.textStyle?.color, themeData.colorScheme.onSurface);
  });

  testWidgets('DropdownMenu can be disabled', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: SafeArea(
            child: DropdownMenu(
              enabled: false,
              dropdownMenuEntries: menuChildren,
            ),
          ),
        ),
      ),
    );

    final TextField textField = tester.widget(find.byType(TextField));
    expect(textField.decoration?.enabled, false);
    final Finder menuMaterial = find.ancestor(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Material),
    );
    expect(menuMaterial, findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    final Finder updatedMenuMaterial = find.ancestor(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Material),
    );
    expect(updatedMenuMaterial, findsNothing);
  });

  testWidgets('The width of the text field should always be the same as the menu view',
    (WidgetTester tester) async {

    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: Scaffold(
          body: SafeArea(
            child: DropdownMenu(
              dropdownMenuEntries: menuChildren,
            ),
          ),
        ),
      )
    );

    final Finder textField = find.byType(TextField);
    final Size anchorSize = tester.getSize(textField);
    expect(anchorSize, const Size(180.0, 54.0));

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();

    final Finder menuMaterial = find.ancestor(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Material),
    );
    final Size menuSize = tester.getSize(menuMaterial);
    expect(menuSize, const Size(180.0, 304.0));

    // The text field should have same width as the menu
    // when the width property is not null.
    await tester.pumpWidget(buildTest(themeData, menuChildren, width: 200.0));

    final Finder anchor = find.byType(TextField);
    final Size size = tester.getSize(anchor);
    expect(size, const Size(200.0, 54.0));

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();

    final Finder updatedMenu = find.ancestor(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Material),
    );
    final Size updatedMenuSize = tester.getSize(updatedMenu);
    expect(updatedMenuSize, const Size(200.0, 304.0));
  });

  testWidgets('The width property can customize the width of the dropdown menu', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    final List<DropdownMenuEntry> shortMenuItems = <DropdownMenuEntry>[];

    for (final ShortMenu value in ShortMenu.values) {
      final DropdownMenuEntry entry = DropdownMenuEntry(label: value.label);
      shortMenuItems.add(entry);
    }

    const double customBigWidth = 250.0;
    await tester.pumpWidget(buildTest(themeData, shortMenuItems, width: customBigWidth));
    RenderBox box = tester.firstRenderObject(find.byType(DropdownMenu));
    expect(box.size.width, customBigWidth);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();
    expect(find.byType(MenuItemButton), findsNWidgets(6));
    Size buttonSize = tester.getSize(find.widgetWithText(MenuItemButton, 'I0').last);
    expect(buttonSize.width, customBigWidth);

    // reset test
    await tester.pumpWidget(Container());
    const double customSmallWidth = 100.0;
    await tester.pumpWidget(buildTest(themeData, shortMenuItems, width: customSmallWidth));
    box = tester.firstRenderObject(find.byType(DropdownMenu));
    expect(box.size.width, customSmallWidth);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();
    expect(find.byType(MenuItemButton), findsNWidgets(6));
    buttonSize = tester.getSize(find.widgetWithText(MenuItemButton, 'I0').last);
    expect(buttonSize.width, customSmallWidth);
  });

  testWidgets('The menuHeight property can be used to show a shorter scrollable menu list instead of the complete list',
    (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(buildTest(themeData, menuChildren));

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();

    final Element firstItem = tester.element(find.widgetWithText(MenuItemButton, 'Item 0').last);
    final RenderBox firstBox = firstItem.renderObject! as RenderBox;
    final Offset topLeft = firstBox.localToGlobal(firstBox.size.topLeft(Offset.zero));
    final Element lastItem = tester.element(find.widgetWithText(MenuItemButton, 'Item 5').last);
    final RenderBox lastBox = lastItem.renderObject! as RenderBox;
    final Offset bottomRight = lastBox.localToGlobal(lastBox.size.bottomRight(Offset.zero));
    // height = height of MenuItemButton * 6 = 48 * 6
    expect(bottomRight.dy - topLeft.dy, 288.0);

    final Finder menuView = find.ancestor(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Padding),
    ).first;
    final Size menuViewSize = tester.getSize(menuView);
    expect(menuViewSize, const Size(180.0, 304.0)); // 304 = 288 + vertical padding(2 * 8)

    // Constrains the menu height.
    await tester.pumpWidget(Container());
    await tester.pumpWidget(buildTest(themeData, menuChildren, menuHeight: 100));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();

    final Finder updatedMenu = find.ancestor(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Padding),
    ).first;

    final Size updatedMenuSize = tester.getSize(updatedMenu);
    expect(updatedMenuSize, const Size(180.0, 100.0));
  });

  testWidgets('The text in the menu button should be aligned with the text of '
    'the text field - LTR', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    // Default text field (without leading icon).
    await tester.pumpWidget(buildTest(themeData, menuChildren, label: const Text('label')));

    final Finder label = find.text('label');
    final Offset labelTopLeft = tester.getTopLeft(label);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();
    final Finder itemText = find.text('Item 0').last;
    final Offset itemTextTopLeft = tester.getTopLeft(itemText);

    expect(labelTopLeft.dx, equals(itemTextTopLeft.dx));

    // Test when the text field has a leading icon.
    await tester.pumpWidget(Container());
    await tester.pumpWidget(buildTest(themeData, menuChildren,
      leadingIcon: const Icon(Icons.search),
      label: const Text('label'),
    ));

    final Finder leadingIcon = find.widgetWithIcon(Container, Icons.search);
    final double iconWidth = tester.getSize(leadingIcon).width;
    final Finder updatedLabel = find.text('label');
    final Offset updatedLabelTopLeft = tester.getTopLeft(updatedLabel);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();
    final Finder updatedItemText = find.text('Item 0').last;
    final Offset updatedItemTextTopLeft = tester.getTopLeft(updatedItemText);


    expect(updatedLabelTopLeft.dx, equals(updatedItemTextTopLeft.dx));
    expect(updatedLabelTopLeft.dx, equals(iconWidth));

    // Test when then leading icon is a widget with a bigger size.
    await tester.pumpWidget(Container());
    await tester.pumpWidget(buildTest(themeData, menuChildren,
      leadingIcon: const SizedBox(
        width: 75.0,
        child: Icon(Icons.search)),
      label: const Text('label'),
    ));

    final Finder largeLeadingIcon = find.widgetWithIcon(Container, Icons.search);
    final double largeIconWidth = tester.getSize(largeLeadingIcon).width;
    final Finder updatedLabel1 = find.text('label');
    final Offset updatedLabelTopLeft1 = tester.getTopLeft(updatedLabel1);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();
    final Finder updatedItemText1 = find.text('Item 0').last;
    final Offset updatedItemTextTopLeft1 = tester.getTopLeft(updatedItemText1);


    expect(updatedLabelTopLeft1.dx, equals(updatedItemTextTopLeft1.dx));
    expect(updatedLabelTopLeft1.dx, equals(largeIconWidth));
  });

  testWidgets('The text in the menu button should be aligned with the text of '
      'the text field - RTL', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    // Default text field (without leading icon).
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownMenu(
            label: const Text('label'),
            dropdownMenuEntries: menuChildren,
          ),
        ),
      ),
    ));

    final Finder label = find.text('label');
    final Offset labelTopRight = tester.getTopRight(label);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();
    final Finder itemText = find.text('Item 0').last;
    final Offset itemTextTopRight = tester.getTopRight(itemText);

    expect(labelTopRight.dx, equals(itemTextTopRight.dx));

    // Test when the text field has a leading icon.
    await tester.pumpWidget(Container());
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownMenu(
            leadingIcon: const Icon(Icons.search),
            label: const Text('label'),
            dropdownMenuEntries: menuChildren,
          ),
        ),
      ),
    ));
    await tester.pump();

    final Finder leadingIcon = find.widgetWithIcon(Container, Icons.search);
    final double iconWidth = tester.getSize(leadingIcon).width;
    final Offset dropdownMenuTopRight = tester.getTopRight(find.byType(DropdownMenu));
    final Finder updatedLabel = find.text('label');
    final Offset updatedLabelTopRight = tester.getTopRight(updatedLabel);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();
    final Finder updatedItemText = find.text('Item 0').last;
    final Offset updatedItemTextTopRight = tester.getTopRight(updatedItemText);


    expect(updatedLabelTopRight.dx, equals(updatedItemTextTopRight.dx));
    expect(updatedLabelTopRight.dx, equals(dropdownMenuTopRight.dx - iconWidth));

    // Test when then leading icon is a widget with a bigger size.
    await tester.pumpWidget(Container());
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownMenu(
            leadingIcon: const SizedBox(width: 75.0, child: Icon(Icons.search)),
            label: const Text('label'),
            dropdownMenuEntries: menuChildren,
          ),
        ),
      ),
    ));
    await tester.pump();

    final Finder largeLeadingIcon = find.widgetWithIcon(Container, Icons.search);
    final double largeIconWidth = tester.getSize(largeLeadingIcon).width;
    final Offset updatedDropdownMenuTopRight = tester.getTopRight(find.byType(DropdownMenu));
    final Finder updatedLabel1 = find.text('label');
    final Offset updatedLabelTopRight1 = tester.getTopRight(updatedLabel1);

    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();
    final Finder updatedItemText1 = find.text('Item 0').last;
    final Offset updatedItemTextTopRight1 = tester.getTopRight(updatedItemText1);


    expect(updatedLabelTopRight1.dx, equals(updatedItemTextTopRight1.dx));
    expect(updatedLabelTopRight1.dx, equals(updatedDropdownMenuTopRight.dx - largeIconWidth));
  });

  testWidgets('DropdownMenu has default trailing icon button', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(buildTest(themeData, menuChildren));
    await tester.pump();

    final Finder iconButton = find.widgetWithIcon(IconButton, Icons.arrow_drop_down).first;
    expect(iconButton, findsOneWidget);

    await tester.tap(iconButton);
    await tester.pump();

    final Finder menuMaterial = find.ancestor(
      of: find.widgetWithText(MenuItemButton, TestMenu.mainMenu0.label),
      matching: find.byType(Material),
    ).last;
    expect(menuMaterial, findsOneWidget);
  });

  testWidgets('DropdownMenu can customize trailing icon button', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          trailingIcon: const Icon(Icons.ac_unit),
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));
    await tester.pump();

    final Finder iconButton = find.widgetWithIcon(IconButton, Icons.ac_unit).first;
    expect(iconButton, findsOneWidget);

    await tester.tap(iconButton);
    await tester.pump();

    final Finder menuMaterial = find.ancestor(
      of: find.widgetWithText(MenuItemButton, TestMenu.mainMenu0.label),
      matching: find.byType(Material),
    ).last;
    expect(menuMaterial, findsOneWidget);
  });

  testWidgets('Down key can highlight the menu item', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          trailingIcon: const Icon(Icons.ac_unit),
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();

    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    Finder button0Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 0').last,
      matching: find.byType(Material),
    );

    Material item0material = tester.widget<Material>(button0Material);
    expect(item0material.color, themeData.colorScheme.onSurface.withOpacity(0.12));

    // Press down key one more time, the highlight should move to the next item.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    final Finder button1Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Menu 1').last,
      matching: find.byType(Material),
    );
    final Material item1material = tester.widget<Material>(button1Material);
    expect(item1material.color, themeData.colorScheme.onSurface.withOpacity(0.12));
    button0Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 0').last,
      matching: find.byType(Material),
    );
    item0material = tester.widget<Material>(button0Material);
    expect(item0material.color, Colors.transparent); // the previous item should not be highlighted.
  });

  testWidgets('Up key can highlight the menu item', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();

    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    Finder button5Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 5').last,
      matching: find.byType(Material),
    );

    Material item5material = tester.widget<Material>(button5Material);
    expect(item5material.color, themeData.colorScheme.onSurface.withOpacity(0.12));

    // Press up key one more time, the highlight should move up to the item 4.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    final Finder button4Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 4').last,
      matching: find.byType(Material),
    );
    final Material item4material = tester.widget<Material>(button4Material);
    expect(item4material.color, themeData.colorScheme.onSurface.withOpacity(0.12));
    button5Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 5').last,
      matching: find.byType(Material),
    );

    item5material = tester.widget<Material>(button5Material);
    expect(item5material.color, Colors.transparent); // the previous item should not be highlighted.
  });

  testWidgets('The text input should match the label of the menu item while pressing down key', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();

    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Item 0'), findsOneWidget);

    // Press down key one more time to the next item.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Menu 1'), findsOneWidget);

    // Press down to the next item.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Item 2'), findsOneWidget);
  });

  testWidgets('The text input should match the label of the menu item while pressing up key', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();

    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Item 5'), findsOneWidget);

    // Press up key one more time to the upper item.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Item 4'), findsOneWidget);

    // Press up to the upper item.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Item 3'), findsOneWidget);
  });

  testWidgets('Disabled button will be skipped while pressing up/down key', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    final List<DropdownMenuEntry> menuWithDisabledItems = <DropdownMenuEntry>[
      const DropdownMenuEntry(label: 'Item 0'),
      const DropdownMenuEntry(label: 'Item 1', enabled: false),
      const DropdownMenuEntry(label: 'Item 2', enabled: false),
      const DropdownMenuEntry(label: 'Item 3'),
      const DropdownMenuEntry(label: 'Item 4'),
      const DropdownMenuEntry(label: 'Item 5', enabled: false),
    ];
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuWithDisabledItems,
        ),
      ),
    ));
    await tester.pump();

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pumpAndSettle();

    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    final Finder button0Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 0').last,
      matching: find.byType(Material),
    );
    final Material item0Material = tester.widget<Material>(button0Material);
    expect(item0Material.color, themeData.colorScheme.onSurface.withOpacity(0.12)); // first item can be highlighted as it's enabled.

    // Continue to press down key. Item 3 should be highlighted as Menu 1 and Item 2 are both disabled.
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    final Finder button3Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 3').last,
      matching: find.byType(Material),
    );
    final Material item3Material = tester.widget<Material>(button3Material);
    expect(item3Material.color, themeData.colorScheme.onSurface.withOpacity(0.12));
  });

  testWidgets('Searching is enabled by default', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Menu 1');
    await tester.pumpAndSettle();
    final Finder buttonMaterial = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Menu 1').last,
      matching: find.byType(Material),
    );
    final Material itemMaterial = tester.widget<Material>(buttonMaterial);
    expect(itemMaterial.color, themeData.colorScheme.onSurface.withOpacity(0.12)); // Menu 1 button is highlighted.
  });

  testWidgets('Highlight can move up/down from the searching result', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Menu 1');
    await tester.pumpAndSettle();
    final Finder buttonMaterial = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Menu 1').last,
      matching: find.byType(Material),
    );
    final Material itemMaterial = tester.widget<Material>(buttonMaterial);
    expect(itemMaterial.color, themeData.colorScheme.onSurface.withOpacity(0.12));

    // Press up to the upper item (Item 0).
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Item 0'), findsOneWidget);
    final Finder button0Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 0').last,
      matching: find.byType(Material),
    );
    final Material item0Material = tester.widget<Material>(button0Material);
    expect(item0Material.color, themeData.colorScheme.onSurface.withOpacity(0.12)); // Move up, the 'Item 0' is highlighted.

    // Continue to move up to the last item (Item 5).
    await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Item 5'), findsOneWidget);
    final Finder button5Material = find.descendant(
      of: find.widgetWithText(MenuItemButton, 'Item 5').last,
      matching: find.byType(Material),
    );
    final Material item5Material = tester.widget<Material>(button5Material);
    expect(item5Material.color, themeData.colorScheme.onSurface.withOpacity(0.12));
  });

  testWidgets('Filtering is disabled by default', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Menu 1');
    await tester.pumpAndSettle();
    for (final TestMenu menu in TestMenu.values) {
      // One is layout for the _DropdownMenuBody, the other one is the real button item in the menu.
      expect(find.widgetWithText(MenuItemButton, menu.label), findsNWidgets(2));
    }
  });

  testWidgets('Enable filtering', (WidgetTester tester) async {
    final ThemeData themeData = ThemeData();
    await tester.pumpWidget(MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: DropdownMenu(
          enableFilter: true,
          dropdownMenuEntries: menuChildren,
        ),
      ),
    ));

    // Open the menu
    await tester.tap(find.byType(DropdownMenu));
    await tester.pump();

    await tester.enterText(find
        .byType(TextField)
        .first, 'Menu 1');
    await tester.pumpAndSettle();
    for (final TestMenu menu in TestMenu.values) {
      // 'Menu 1' should be 2, other items should only find one.
      if (menu.label == TestMenu.mainMenu1.label) {
        expect(find.widgetWithText(MenuItemButton, menu.label), findsNWidgets(2));
      } else {
        expect(find.widgetWithText(MenuItemButton, menu.label), findsOneWidget);
      }
    }
  });
}

enum TestMenu {
  mainMenu0('Item 0'),
  mainMenu1('Menu 1'),
  mainMenu2('Item 2'),
  mainMenu3('Item 3'),
  mainMenu4('Item 4'),
  mainMenu5('Item 5');

  const TestMenu(this.label);
  final String label;
}

enum ShortMenu {
  item0('I0'),
  item1('I1'),
  item2('I2');

  const ShortMenu(this.label);
  final String label;
}
