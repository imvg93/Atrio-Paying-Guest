import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_views.dart';
import '../../meta/data/amenity.dart';
import '../../meta/data/amenity_repository.dart';
import '../../properties/data/models/property.dart';
import '../application/owner_properties_controller.dart';
import '../data/models/property_draft.dart';
import 'widgets/wizard_stepper.dart';

/// How a step asks for the draft to be changed.
///
/// A function of the *current* draft rather than a finished replacement. A step
/// holds the draft it was built with, so `onChanged(draft.copyWith(name: v))`
/// would apply the edit to whatever the draft was at that step's last build —
/// and two edits landing before a rebuild would silently undo the first. This
/// signature makes that impossible: the parent always applies the change to the
/// live value.
typedef DraftEditor = void Function(PropertyDraft Function(PropertyDraft));

/// H3 — the property wizard, in both create and edit mode.
///
/// Five steps: basics, location, amenities and rules, photos, review. One
/// [PropertyDraft] is carried across all of them and only becomes a request at
/// the end, so nothing is written until the owner says so.
///
/// **Why it does not save after step 1.** `latitude`/`longitude` are NOT NULL in
/// the schema, so a property cannot exist before the pin is set. The whole
/// draft is therefore held locally until the review step. The cost is that
/// backgrounding the app mid-wizard loses it; the alternative was a migration
/// making the location nullable, which every distance query would then have to
/// defend against forever.
class PropertyWizardScreen extends ConsumerStatefulWidget {
  const PropertyWizardScreen({super.key, this.propertyId});

  /// Null in create mode.
  final String? propertyId;

  bool get isEditing => propertyId != null;

  @override
  ConsumerState<PropertyWizardScreen> createState() =>
      _PropertyWizardScreenState();
}

class _PropertyWizardScreenState extends ConsumerState<PropertyWizardScreen> {
  static const _steps = <({String title, String subtitle})>[
    (title: 'The basics', subtitle: 'What is this place called?'),
    (title: 'Where is it?', subtitle: 'Students search by locality and city.'),
    (title: 'What is included?', subtitle: 'Amenities and house rules.'),
    (title: 'Photos', subtitle: 'Listings with photos get far more enquiries.'),
    (title: 'Review', subtitle: 'Check it over, then save.'),
  ];

  final _pageController = PageController();
  int _step = 0;
  bool _busy = false;

  PropertyDraft _draft = const PropertyDraft();

  /// The property as loaded, in edit mode. The patch is diffed against it.
  Property? _original;
  bool _seeded = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Applies a step's edit to the live draft. See [DraftEditor].
  void _update(PropertyDraft Function(PropertyDraft) change) {
    setState(() => _draft = change(_draft));
  }

  // ---- navigation ---------------------------------------------------

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: AppMotion.medium,
      curve: AppMotion.standard,
    );
    // A step change is a meaningful checkpoint, and the tick makes the wizard
    // feel like it is responding rather than merely scrolling.
    HapticFeedback.selectionClick();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      _goTo(_step + 1);
    }
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  /// True when the current step has everything it needs to move on.
  bool get _canAdvance => switch (_step) {
        0 => _draft.hasBasics,
        1 => _draft.hasLocation,
        // Amenities, photos and review have nothing mandatory: a PG with no
        // amenities listed is unusual, not invalid, and blocking on it would
        // just teach owners to tick boxes at random.
        _ => true,
      };

  String? get _hint => switch (_step) {
        0 when !_draft.hasBasics =>
          'Add a name of at least two characters and pick who it is for.',
        1 when !_draft.hasLocation =>
          'Address, locality, city, state, a 6-digit pincode and a map pin '
              'are all needed.',
        _ => null,
      };

  // ---- saving -------------------------------------------------------

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(ownerPropertiesProvider.notifier);
      final Property saved;

      if (_original != null) {
        saved = await ref.read(ownerPropertyEditorProvider).save(
              original: _original!,
              draft: _draft,
            );
      } else {
        saved = await controller.create(_draft);
      }

      if (!mounted) return;

      // Replaces the wizard rather than stacking on it: backing out of the
      // overview should return to the portfolio, not to a filled-in form for a
      // property that already exists.
      context.pushReplacement(
        AppRoutes.ownerPropertyOverviewFor(saved.id),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _original == null
                ? 'Saved as a draft. Publish it when you are ready.'
                : 'Changes saved.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppErrorView.messageFor(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Guards the back button once anything has been typed.
  Future<bool> _confirmDiscard() async {
    final untouched = _original == null
        ? _draft == const PropertyDraft()
        : _draft.toUpdateJson(_original!).isEmpty;
    if (untouched) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Anything you have entered here will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Edit mode has to load the property before the form can be seeded.
    if (widget.isEditing && !_seeded) {
      final async = ref.watch(ownerPropertyProvider(widget.propertyId!));

      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorView(
            error: error,
            onRetry: () =>
                ref.invalidate(ownerPropertyProvider(widget.propertyId!)),
          ),
        ),
        data: (property) {
          // Seeded once, after this frame — assigning state during build would
          // throw, and re-seeding on every rebuild would wipe the owner's edits
          // the moment the provider refreshed.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _original = property;
              _draft = PropertyDraft.from(property);
              _seeded = true;
            });
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Back inside the wizard walks the steps first, and only leaves from
        // step one — losing four steps of typing to a stray swipe would be
        // indefensible.
        if (_step > 0) {
          _back();
          return;
        }
        if (await _confirmDiscard() && mounted) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit property' : 'New property'),
          leading: IconButton(
            icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back),
            onPressed: () async {
              if (_step > 0) {
                _back();
              } else if (await _confirmDiscard() && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            WizardStepper(
              step: _step,
              total: _steps.length,
              title: _steps[_step].title,
              subtitle: _steps[_step].subtitle,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                // Driven only by the buttons: swiping past a step whose fields
                // are incomplete would defeat the per-step validation.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _BasicsStep(draft: _draft, onEdit: _update),
                  _LocationStep(draft: _draft, onEdit: _update),
                  _AmenitiesStep(draft: _draft, onEdit: _update),
                  const _PhotosStep(),
                  _ReviewStep(
                    draft: _draft,
                    isEditing: widget.isEditing,
                    onJumpTo: _goTo,
                  ),
                ],
              ),
            ),
            WizardNavBar(
              onBack: _step == 0 ? null : _back,
              onNext: _step == _steps.length - 1
                  ? (_draft.isSubmittable ? _save : null)
                  : (_canAdvance ? _next : null),
              nextLabel: _step == _steps.length - 1
                  ? (widget.isEditing ? 'Save changes' : 'Create property')
                  : 'Continue',
              hint: _step == _steps.length - 1 && !_draft.isSubmittable
                  ? 'Some required details are still missing.'
                  : _hint,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }
}

// ---- step 1: basics -------------------------------------------------

class _BasicsStep extends StatelessWidget {
  const _BasicsStep({required this.draft, required this.onEdit});

  final PropertyDraft draft;
  final DraftEditor onEdit;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      children: [
        _Field(
          label: 'Property name',
          hint: 'Sunrise PG',
          initialValue: draft.name,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => onEdit((d) => d.copyWith(name: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Label('Who is it for?'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final type in PropertyGenderType.values) ...[
              Expanded(
                child: _ChoiceCard(
                  label: type.label,
                  icon: switch (type) {
                    PropertyGenderType.male => Icons.man,
                    PropertyGenderType.female => Icons.woman,
                    PropertyGenderType.coliving => Icons.groups_outlined,
                  },
                  selected: draft.genderType == type,
                  onTap: () => onEdit((d) => d.copyWith(genderType: type)),
                ),
              ),
              if (type != PropertyGenderType.values.last)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Field(
          label: 'Description',
          hint: 'What makes this place worth living in?',
          initialValue: draft.description,
          maxLines: 4,
          optional: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => onEdit((d) => d.copyWith(description: v)),
        ),
      ],
    );
  }
}

// ---- step 2: location -----------------------------------------------

class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.draft, required this.onEdit});

  final PropertyDraft draft;
  final DraftEditor onEdit;

  @override
  Widget build(BuildContext context) {
    return _StepBody(
      children: [
        _Field(
          label: 'Address',
          hint: '12 MG Road, above the bakery',
          initialValue: draft.addressLine,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => onEdit((d) => d.copyWith(addressLine: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: 'Locality',
          hint: 'Indiranagar',
          initialValue: draft.locality,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => onEdit((d) => d.copyWith(locality: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'City',
                hint: 'Bengaluru',
                initialValue: draft.city,
                textCapitalization: TextCapitalization.words,
                onChanged: (v) => onEdit((d) => d.copyWith(city: v)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _Field(
                label: 'Pincode',
                hint: '560038',
                initialValue: draft.pincode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (v) => onEdit((d) => d.copyWith(pincode: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: 'State',
          hint: 'Karnataka',
          initialValue: draft.state,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => onEdit((d) => d.copyWith(state: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        _MapPinField(
          latitude: draft.latitude,
          longitude: draft.longitude,
          onChanged: (lat, lng) =>
              onEdit((d) => d.copyWith(latitude: lat, longitude: lng)),
        ),
      ],
    );
  }
}

/// The map pin, entered as coordinates until a map SDK lands.
///
/// A real map needs a Google Maps key and a platform-config change that is not
/// this wave's business, so this collects the same two values honestly rather
/// than shipping a fake map. The field is deliberately explicit that a map is
/// coming, so it does not look like the finished design.
class _MapPinField extends StatelessWidget {
  const _MapPinField({
    required this.latitude,
    required this.longitude,
    required this.onChanged,
  });

  final double? latitude;
  final double? longitude;
  final void Function(double?, double?) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSet = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isSet
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSet ? Icons.location_on : Icons.location_searching,
                color: isSet
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Map pin', style: theme.textTheme.titleSmall),
              ),
              if (isSet)
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Students search by distance, so this decides who finds you. '
            'Picking it on a map arrives with the maps integration.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Latitude',
                  hint: '12.971599',
                  initialValue: latitude?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (v) =>
                      onChanged(double.tryParse(v.trim()), longitude),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Field(
                  label: 'Longitude',
                  hint: '77.594566',
                  initialValue: longitude?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (v) =>
                      onChanged(latitude, double.tryParse(v.trim())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- step 3: amenities and rules -------------------------------------

class _AmenitiesStep extends ConsumerWidget {
  const _AmenitiesStep({required this.draft, required this.onEdit});

  final PropertyDraft draft;
  final DraftEditor onEdit;

  void _toggle(String key, bool value) {
    onEdit((d) {
      final next = Map<String, bool>.from(d.amenities);
      if (value) {
        next[key] = true;
      } else {
        // Removed rather than set false: the map is what lands in JSONB, and a
        // pile of false entries is noise that every reader then has to filter.
        next.remove(key);
      }
      return d.copyWith(amenities: next);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedAmenitiesProvider);
    final theme = Theme.of(context);

    return _StepBody(
      children: [
        grouped.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(amenityCatalogueProvider),
          ),
          data: (groups) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, group) in groups.indexed)
                FadeSlideIn(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amenityGroupTitle(group.key),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final amenity in group.value)
                              FilterChip(
                                label: Text(amenity.label),
                                selected:
                                    draft.amenities[amenity.key] ?? false,
                                onSelected: (v) => _toggle(amenity.key, v),
                                showCheckmark: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: AppSpacing.xl),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Food included in rent'),
          subtitle: const Text('Students filter on this.'),
          value: draft.foodIncluded,
          onChanged: (v) => onEdit((d) => d.copyWith(foodIncluded: v)),
        ),
        const SizedBox(height: AppSpacing.md),
        _Label('Notice period'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'How much warning a tenant must give before leaving. '
          'Used to work out exit dates.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final days in const [15, 30, 45, 60]) ...[
              Expanded(
                child: _ChoiceCard(
                  label: '$days days',
                  selected: draft.noticePeriodDays == days,
                  onTap: () => onEdit((d) => d.copyWith(noticePeriodDays: days)),
                ),
              ),
              if (days != 60) const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ],
    );
  }
}

// ---- step 4: photos --------------------------------------------------

/// Photos (H8) wait on the object-storage decision, so this step is honest
/// about it rather than showing an upload button that cannot work.
class _PhotosStep extends StatelessWidget {
  const _PhotosStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _StepBody(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.card,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Photo upload is coming next',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can finish and publish without photos, then add them once '
                'uploads are switched on. Until then your listing shows a '
                'generated cover.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---- step 5: review --------------------------------------------------

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.draft,
    required this.isEditing,
    required this.onJumpTo,
  });

  final PropertyDraft draft;
  final bool isEditing;
  final ValueChanged<int> onJumpTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeAmenities =
        draft.amenities.entries.where((e) => e.value).length;

    return _StepBody(
      children: [
        _ReviewCard(
          title: 'The basics',
          onEdit: () => onJumpTo(0),
          rows: [
            ('Name', draft.name.isEmpty ? '—' : draft.name),
            ('For', draft.genderType?.label ?? '—'),
            if (draft.description.trim().isNotEmpty)
              ('Description', draft.description.trim()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewCard(
          title: 'Location',
          onEdit: () => onJumpTo(1),
          rows: [
            ('Address', draft.addressLine),
            ('Locality', draft.locality),
            ('City', '${draft.city}, ${draft.state}'),
            ('Pincode', draft.pincode),
            (
              'Map pin',
              draft.latitude == null || draft.longitude == null
                  ? 'Not set'
                  : '${draft.latitude!.toStringAsFixed(5)}, '
                      '${draft.longitude!.toStringAsFixed(5)}',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewCard(
          title: 'Included',
          onEdit: () => onJumpTo(2),
          rows: [
            ('Amenities', '$activeAmenities selected'),
            ('Food', draft.foodIncluded ? 'Included' : 'Not included'),
            ('Notice period', '${draft.noticePeriodDays} days'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!isEditing)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: AppRadius.card,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'This saves as a draft. Add rooms and beds next, then '
                    'publish when you are ready for students to find it.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  final String title;
  final List<(String, String)> rows;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.titleSmall),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(label, style: theme.textTheme.bodySmall),
                  ),
                  Expanded(
                    child: Text(
                      value.isEmpty ? '—' : value,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---- shared step furniture ------------------------------------------

class _StepBody extends StatelessWidget {
  const _StepBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: children,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

/// A labelled text field.
///
/// Uses [initialValue] with an internal controller rather than being fully
/// controlled: rebuilding a controlled `TextField` on every keystroke fights
/// the cursor, and the draft is the source of truth for everything except the
/// text currently being typed.
class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.optional = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String? hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool optional;
  final TextCapitalization textCapitalization;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: theme.textTheme.titleSmall),
            if (widget.optional) ...[
              const SizedBox(width: AppSpacing.sm),
              Text('Optional', style: theme.textTheme.bodySmall),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// A selectable tile — used for gender type and notice period, where radio
/// buttons would be smaller targets and read as a form rather than a choice.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
