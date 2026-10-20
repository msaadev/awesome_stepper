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

class CheckoutPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const CheckoutPage({super.key, required this.onToggleTheme});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _controller = AwesomeStepperController();
  final _formKey = GlobalKey<FormState>();
  AwesomeStepperHeader _header = AwesomeStepperHeader.circle;
  bool _giftWrap = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Stepper'),
        actions: [
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
      body: AwesomeStepper(
        controller: _controller,
        headerType: _header,
        onCompleted: _showDone,
        steps: [
          AwesomeStepperItem(
            label: 'Address',
            subtitle: 'Where should we deliver?',
            icon: Icons.home_outlined,
            content: _buildAddressForm(),
            canContinue: () => _formKey.currentState?.validate() ?? false,
          ),
          AwesomeStepperItem(
            label: 'Extras',
            subtitle: 'Optional',
            icon: Icons.redeem_outlined,
            content: _buildExtras(),
          ),
          AwesomeStepperItem(
            label: 'Gift note',
            subtitle: 'Only with gift wrap',
            icon: Icons.edit_note_outlined,
            enabled: _giftWrap,
            content: _buildCentered('Write a short note for the gift.'),
          ),
          AwesomeStepperItem(
            label: 'Payment',
            subtitle: 'Card or wallet',
            icon: Icons.credit_card_outlined,
            content: _buildCentered('Pay with your saved card.'),
          ),
          AwesomeStepperItem(
            label: 'Review',
            subtitle: 'Check and confirm',
            icon: Icons.fact_check_outlined,
            content: _buildCentered('Everything looks good.'),
          ),
        ],
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

  Widget _buildAddressForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(24),
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
    );
  }

  Widget _buildExtras() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SwitchListTile(
          title: const Text('Gift wrap'),
          subtitle: const Text('Unlocks the gift note step'),
          value: _giftWrap,
          onChanged: (value) => setState(() => _giftWrap = value),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => _controller.jumpTo(4),
          child: const Text('Skip to review (controller.jumpTo)'),
        ),
      ],
    );
  }

  Widget _buildCentered(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Required' : null;

  void _showDone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed')),
    );
  }
}
