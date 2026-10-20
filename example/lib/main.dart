import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    return MaterialApp(
      title: 'Awesome Stepper',
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: CheckoutPage(onToggleTheme: _toggleTheme),
    );
  }

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }
}

/// Every awesome_stepper option in one page: the stepper on the left, the
/// Playground panel (tune icon) on the right.
class CheckoutPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const CheckoutPage({super.key, required this.onToggleTheme});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const _accents = <String, Color?>{
    'Theme': null,
    'Teal': Colors.teal,
    'Orange': Colors.deepOrange,
    'Pink': Colors.pink,
  };

  final _controller = AwesomeStepperController();
  final _formKey = GlobalKey<FormState>();
  AwesomeStepperHeader _header = AwesomeStepperHeader.circle;
  AwesomeStepperLayout _layout = AwesomeStepperLayout.horizontal;
  AwesomeStepperTransition _transition = AwesomeStepperTransition.slide;
  AwesomeStepperLineStyle _line = AwesomeStepperLineStyle.solid;
  String _accent = 'Theme';
  bool _giftWrap = false;
  bool _headerJump = true;
  bool _swipe = true;
  bool _keyboard = true;
  bool _haptics = true;
  bool _sideList = true;
  bool _completedScreen = true;
  bool _customControls = false;
  bool _turkish = false;
  bool _slowPayment = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStep);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStep);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Stepper'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Playground',
              icon: const Icon(Icons.tune),
              onPressed: Scaffold.of(context).openEndDrawer,
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: widget.onToggleTheme,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildHeaderPicker(),
        ),
      ),
      endDrawer: _buildPlayground(),
      body: Theme(
        data: Theme.of(context).copyWith(
          extensions: [AwesomeStepperTheme(accentColor: _accents[_accent])],
        ),
        child: _buildStepper(),
      ),
    );
  }

  Widget _buildHeaderPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SegmentedButton<AwesomeStepperHeader>(
        showSelectedIcon: false,
        segments: [
          for (final type in AwesomeStepperHeader.values)
            ButtonSegment(value: type, label: Text(type.name)),
        ],
        selected: {_header},
        onSelectionChanged: (value) => setState(() => _header = value.first),
      ),
    );
  }

  Widget _buildStepper() {
    return AwesomeStepper(
      controller: _controller,
      headerType: _header,
      layout: _layout,
      transition: _transition,
      lineStyle: _line,
      allowHeaderJump: _headerJump,
      swipeEnabled: _swipe,
      keyboardEnabled: _keyboard,
      hapticsEnabled: _haptics,
      sideBySideMinWidth: _sideList ? 840 : null,
      restorationId: 'checkout',
      nextLabel: _turkish ? 'İleri' : 'Next',
      backLabel: _turkish ? 'Geri' : 'Back',
      finishLabel: _turkish ? 'Bitir' : 'Finish',
      skipLabel: _turkish ? 'Atla' : 'Skip',
      semanticsLabel: _turkish
          ? (step, total, label) => 'Adım $step / $total: $label'
          : null,
      controlBuilder: _customControls ? _buildCustomControls : null,
      onCompleted: _showDone,
      completedBuilder: _completedScreen
          ? (_) => _buildCentered('🎉 Order placed. Thank you!')
          : null,
      steps: [
        AwesomeStepperItem(
          label: 'Address',
          subtitle: 'Validated form',
          icon: Icons.home_outlined,
          content: _buildAddressForm(),
          canContinue: () => _formKey.currentState?.validate() ?? false,
        ),
        AwesomeStepperItem(
          label: 'Extras',
          subtitle: 'Optional: Skip',
          optional: true,
          icon: Icons.redeem_outlined,
          content: _buildExtras(),
        ),
        AwesomeStepperItem(
          label: 'Gift note',
          subtitle: 'Locked until gift wrap',
          icon: Icons.edit_note_outlined,
          enabled: _giftWrap,
          content: _buildCentered('Write a short note for the gift.'),
        ),
        AwesomeStepperItem(
          label: 'Payment',
          subtitle: _slowPayment ? 'Async check: 1 s' : 'Card or wallet',
          icon: Icons.credit_card_outlined,
          content: _buildCentered('Pay with your saved card.'),
          canContinue: _slowPayment ? _checkPayment : null,
        ),
        AwesomeStepperItem(
          label: 'Review',
          subtitle: 'Check and confirm',
          icon: Icons.fact_check_outlined,
          content: _buildCentered('Everything looks good.'),
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Street'),
              validator: _required,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtras() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SwitchListTile(
        title: const Text('Gift wrap'),
        subtitle: const Text('Unlocks the gift note step'),
        value: _giftWrap,
        onChanged: (value) => setState(() => _giftWrap = value),
      ),
    );
  }

  Widget _buildCustomControls(VoidCallback onNext, VoidCallback onBack) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.outlined(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton.filled(
            tooltip: 'Next',
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayground() {
    return Drawer(
      width: 340,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _buildSection('Layout'),
            _buildChoice(
              AwesomeStepperLayout.values,
              _layout,
              (v) => _layout = v,
            ),
            _buildSection('Transition'),
            _buildChoice(
              AwesomeStepperTransition.values,
              _transition,
              (v) => _transition = v,
            ),
            _buildSection('Line style (numbered, vertical)'),
            _buildChoice(
              AwesomeStepperLineStyle.values,
              _line,
              (v) => _line = v,
            ),
            _buildSection('Accent (AwesomeStepperTheme)'),
            _buildChoice(_accents.keys.toList(), _accent, (v) => _accent = v),
            _buildSection('Behavior'),
            _buildSwitch(
              'Jump forward from the header',
              'allowHeaderJump',
              _headerJump,
              (v) => _headerJump = v,
            ),
            _buildSwitch(
              'Swipe between pages',
              'swipeEnabled',
              _swipe,
              (v) => _swipe = v,
            ),
            _buildSwitch(
              'Arrow keys and Enter',
              'keyboardEnabled',
              _keyboard,
              (v) => _keyboard = v,
            ),
            _buildSwitch(
              'Haptic feedback',
              'hapticsEnabled',
              _haptics,
              (v) => _haptics = v,
            ),
            _buildSwitch(
              'Side list on wide windows',
              'sideBySideMinWidth: 840 / null',
              _sideList,
              (v) => _sideList = v,
            ),
            _buildSwitch(
              'Async payment check',
              'canContinue: Future<bool>',
              _slowPayment,
              (v) => _slowPayment = v,
            ),
            _buildSection('Look'),
            _buildSwitch(
              'Completed screen',
              'completedBuilder',
              _completedScreen,
              (v) => _completedScreen = v,
            ),
            _buildSwitch(
              'Custom buttons',
              'controlBuilder',
              _customControls,
              (v) => _customControls = v,
            ),
            _buildSwitch(
              'Turkish labels',
              'nextLabel, backLabel, skipLabel, semanticsLabel',
              _turkish,
              (v) => _turkish = v,
            ),
            _buildSection('Controller (step ${_controller.currentStep + 1})'),
            _buildControllerButtons(),
            _buildSection('AwesomeStepIndicator (standalone)'),
            _buildIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  Widget _buildChoice<T>(List<T> values, T selected, void Function(T) apply) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in values)
            ChoiceChip(
              label: Text(value is Enum ? value.name : '$value'),
              selected: value == selected,
              onSelected: (_) => setState(() => apply(value)),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitch(
    String title,
    String api,
    bool value,
    void Function(bool) apply,
  ) {
    return SwitchListTile(
      dense: true,
      title: Text(title),
      subtitle: Text(api, style: const TextStyle(fontFamily: 'monospace')),
      value: value,
      onChanged: (v) => setState(() => apply(v)),
    );
  }

  Widget _buildControllerButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton(
            onPressed: _controller.back,
            child: const Text('back()'),
          ),
          OutlinedButton(
            onPressed: _controller.next,
            child: const Text('next()'),
          ),
          OutlinedButton(
            onPressed: () => _controller.jumpTo(0),
            child: const Text('jumpTo(0)'),
          ),
          OutlinedButton(
            onPressed: () => _controller.jumpTo(4),
            child: const Text('jumpTo(4)'),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    const labels = ['Address', 'Extras', 'Gift', 'Payment', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for (final type in AwesomeStepperHeader.values)
            AwesomeStepIndicator(
              type: type,
              currentStep: _controller.currentStep,
              labels: labels,
              lineStyle: _line,
              color: _accents[_accent],
              onStepTapped: _controller.jumpTo,
            ),
        ],
      ),
    );
  }

  Widget _buildCentered(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Required' : null;

  Future<bool> _checkPayment() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  void _onStep() => setState(() {});

  void _showDone() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed')));
  }
}
