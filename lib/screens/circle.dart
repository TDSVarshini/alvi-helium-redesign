import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'templates.dart';

/// Partner (QWatch Pro "Space of Love"), reframed around the haptic language.
class PartnerScreen extends StatelessWidget {
  const PartnerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    if (!app.partnerLinked) {
      return AlviPage(
        label: 'Partner',
        trailing: BarIcon(icon: Icons.mail_outline, label: 'Partner requests', onTap: () => Navigator.pushNamed(context, '/circle/partner/requests')),
        footer: [
          PrimaryButton('Invite your partner', onPressed: () => Navigator.pushNamed(context, '/circle/invite')),
          AlviLink('Preview a linked partner (sample)', onTap: () => app.update(() => app.partnerLinked = true)),
        ],
        children: const [
          SizedBox(height: Space.s24),
          Center(child: CoreIllustration(size: 180, pulsing: true)),
          SizedBox(height: Space.s32),
          Headline('Feel each other\'s day.', sub: 'Only one of you needs a band. Send a touch from the app, and share the parts of your day you choose.'),
        ],
      );
    }
    return AlviPage(
      label: 'Partner',
      sample: true,
      trailing: BarIcon(icon: Icons.more_horiz, label: 'Partner settings', onTap: () => Navigator.pushNamed(context, '/circle/partner/remove')),
      children: [
        const Headline('Priya'),
        Text('Together 214 days', style: AlviType.data(context, size: 11)),
        const SectionLabel('Send a touch'),
        for (final p in [HapticPattern.inZone, HapticPattern.goal, HapticPattern.breathe])
          HapticRow(p, subtitle: switch (p) { HapticPattern.inZone => 'Thinking of you', HapticPattern.goal => 'Proud of you', _ => 'Breathe with me' }, onPlay: () => toast(context, 'Sent to Priya (sample)')),
        const SectionLabel('Shared'),
        NavRow('Priya\'s day', onTap: () => Navigator.pushNamed(context, '/circle/partner/health')),
        NavRow('Dates', onTap: () => Navigator.pushNamed(context, '/circle/partner/dates')),
        NavRow('Milestones', onTap: () => Navigator.pushNamed(context, '/circle/partner/milestones')),
      ],
    );
  }
}

class PartnerHealthScreen extends StatefulWidget {
  const PartnerHealthScreen({super.key});
  @override
  State<PartnerHealthScreen> createState() => _PartnerHealthScreenState();
}

class _PartnerHealthScreenState extends State<PartnerHealthScreen> {
  int selected = 6;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final now = DateTime.now();
    return AlviPage(label: 'Priya\'s day', sample: true, children: [
      Row(children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Semantics(
              selected: i == selected,
              button: true,
              child: InkWell(
                onTap: () => setState(() => selected = i),
                child: Column(children: [
                  Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], style: AlviType.label(context)),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: i == selected ? c.ink : null),
                    child: Text('${now.subtract(Duration(days: 6 - i)).day}', style: AlviType.bodySmall(context, color: i == selected ? c.surface : c.ink)),
                  ),
                ]),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 24),
      const StatGrid([StatCell('Steps', '8,104'), StatCell('Distance', '6.0', unit: 'km'), StatCell('Energy', '389', unit: 'kcal')]),
      NavRow('Sleep', value: '7 h 05 m', chevron: false),
      NavRow('Heart rate', value: '64 bpm', chevron: false),
      NavRow('Oxygen', value: '98 %', chevron: false),
      const Disclaimer('Priya chooses what she shares. She can stop sharing at any time.'),
    ]);
  }
}

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    const ms = [(1, 'First day'), (20, 'Twenty days'), (50, 'Fifty days'), (100, 'One hundred days'), (200, 'Two hundred days'), (365, 'One year'), (500, 'Five hundred days'), (1000, 'One thousand days')];
    return AlviPage(label: 'Milestones', sample: true, children: [
      const Headline('214 days together.'),
      for (final m in ms)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
          child: Row(children: [
            Icon(m.$1 <= 214 ? Icons.check_circle_outline : Icons.lock_outline, color: m.$1 <= 214 ? c.readiness : c.inkMuted, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(m.$2, style: AlviType.body(context, color: m.$1 <= 214 ? c.ink : c.inkMuted))),
            Text(m.$1 <= 214 ? 'REACHED' : 'IN ${m.$1 - 214} DAYS', style: AlviType.data(context, size: 11)),
          ]),
        ),
    ]);
  }
}

class DatesScreen extends StatelessWidget {
  const DatesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      label: 'Dates',
      sample: true,
      trailing: BarIcon(icon: Icons.add, label: 'Add a date', onTap: () => Navigator.pushNamed(context, '/circle/partner/dates/add')),
      children: [
        const DisplayNumeral(['214', 'days'], size: 88),
        Text('Together since 12 April 2026', style: AlviType.bodySmall(context)),
        const SectionLabel('Your dates'),
        if (app.partnerDates.isEmpty) Text('Add birthdays and anniversaries. Helium taps you both on the day.', style: AlviType.bodySmall(context)),
        for (final d in app.partnerDates) NavRow(d, chevron: false),
      ],
    );
  }
}

class AddDateScreen extends StatefulWidget {
  const AddDateScreen({super.key});
  @override
  State<AddDateScreen> createState() => _AddDateScreenState();
}

class _AddDateScreenState extends State<AddDateScreen> {
  final name = TextEditingController();
  DateTime? date;
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      label: 'Add a date',
      footer: [
        PrimaryButton('Save', onPressed: () {
          if (name.text.trim().isEmpty || date == null) return toast(context, 'Add a name and a date');
          app.update(() => app.partnerDates.insert(0, '${name.text.trim()} · ${date!.toIso8601String().substring(0, 10)}'));
          Navigator.pop(context);
        }),
      ],
      children: [
        AlviField(label: 'Name', hint: 'First trip together', controller: name),
        NavRow('Date', value: date == null ? 'Choose' : date!.toIso8601String().substring(0, 10), mono: true, onTap: () async {
          final d = await showDatePicker(context: context, firstDate: DateTime(1950), lastDate: DateTime(2100), initialDate: DateTime.now());
          if (d != null) setState(() => date = d);
        }),
        ToggleRow('Pin to top', value: app.toggle('partner.dateTop'), onChanged: (v) => app.setToggle('partner.dateTop', v)),
      ],
    );
  }
}

/// Stop sharing (QWatch Pro "Unpair Partner").
class RemovePartnerScreen extends StatelessWidget {
  const RemovePartnerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      label: 'Stop sharing',
      footer: [
        SecondaryButton('Stop sharing with Priya', destructive: true, onPressed: () {
          app.update(() => app.partnerLinked = false);
          Navigator.popUntil(context, (r) => r.settings.name == '/circle/partner' || r.isFirst);
        }),
      ],
      children: const [
        Headline('Before you stop.'),
        Para('You will no longer send touches or see each other\'s shared data. Shared dates and milestones disappear from both apps.', muted: true),
        Para('Link again with the same accounts within 180 days to restore them. After 180 days they are deleted.', muted: true),
      ],
    );
  }
}

class PartnerRequestsScreen extends StatelessWidget {
  const PartnerRequestsScreen({super.key});
  @override
  Widget build(BuildContext context) => const EmptyListScreen(label: 'Partner requests', title: 'No requests.', body: 'Invitations from your partner appear here for one day.', icon: Icons.mail_outline);
}

/// Family (QWatch Pro "Family Ranking").
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final sorted = [...Sample.family]..sort((a, b) => int.parse(b[1].replaceAll(',', '')).compareTo(int.parse(a[1].replaceAll(',', ''))));
    return AlviPage(
      label: 'Family',
      sample: true,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        BarIcon(icon: Icons.ios_share, label: 'Share', onTap: () => toast(context, 'Share sheet opens here')),
        BarIcon(icon: Icons.person_add_alt, label: 'Invite', onTap: () => Navigator.pushNamed(context, '/circle/invite')),
      ]),
      children: [
        const Headline('Steps today.', sub: 'A friendly ranking. Cheer each other on.'),
        for (var i = 0; i < sorted.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
            child: Row(children: [
              SizedBox(width: 28, child: Text('${i + 1}', style: AlviType.data(context, size: 13))),
              Expanded(child: Text(sorted[i][0], style: AlviType.body(context))),
              Text(sorted[i][1], style: AlviType.stat(context, size: 20)),
              const SizedBox(width: 12),
              Semantics(
                button: true,
                label: 'Cheer ${sorted[i][0]}, ${sorted[i][2]} cheers',
                child: InkWell(
                  onTap: () => toast(context, 'Cheered ${sorted[i][0]}'),
                  child: Row(children: [Icon(Icons.favorite_border, size: 18, color: c.heart), const SizedBox(width: 4), Text(sorted[i][2], style: AlviType.data(context, size: 11))]),
                ),
              ),
            ]),
          ),
        NavRow('Requests', onTap: () => Navigator.pushNamed(context, '/circle/requests')),
        NavRow('Cheers you received', onTap: () => Navigator.pushNamed(context, '/circle/cheers')),
        NavRow('My code', onTap: () => Navigator.pushNamed(context, '/circle/my-code')),
      ],
    );
  }
}

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context) => EmptyListScreen(
      label: 'Requests', title: 'No requests yet.', body: 'When someone invites you, it appears here.', icon: Icons.group_outlined,
      action: 'Invite someone', onAction: () => Navigator.pushNamed(context, '/circle/invite'));
}

class CheersScreen extends StatelessWidget {
  const CheersScreen({super.key});
  @override
  Widget build(BuildContext context) => const EmptyListScreen(label: 'Cheers', title: 'No cheers yet.', body: 'When family cheer your day, you will see it here.', icon: Icons.favorite_border);
}

/// Invite someone (QWatch Pro "Choose a Pair").
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final email = TextEditingController();
  @override
  Widget build(BuildContext context) => AlviPage(
        label: 'Invite',
        trailing: BarIcon(icon: Icons.qr_code_scanner, label: 'Scan a code', onTap: () => toast(context, 'Camera scanner opens here')),
        footer: [
          PrimaryButton('Send invitation', onPressed: () {
            if (!email.text.contains('@')) return toast(context, 'Check the email address');
            Navigator.pushReplacementNamed(context, '/circle/invite/sent', arguments: email.text.trim());
          }),
        ],
        children: [
          const Headline('Who do you want to invite?', sub: 'Enter the email they use for ALVI.'),
          const SizedBox(height: 24),
          AlviField(label: 'Email', hint: 'name@example.com', controller: email, keyboard: TextInputType.emailAddress),
        ],
      );
}

class InviteSentScreen extends StatelessWidget {
  const InviteSentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final to = ModalRoute.of(context)?.settings.arguments as String? ?? 'them';
    return AlviPage(lead: TopBarLead.close, footer: [PrimaryButton('Got it', onPressed: () => Navigator.pop(context))], children: [
      const SizedBox(height: 48),
      Headline('Invitation sent to $to.', sub: 'If they do not accept within one day, it is cancelled.'),
      const Para('They sign in to ALVI and accept from Today or from Partner.', muted: true),
    ]);
  }
}

class MyCodeScreen extends StatelessWidget {
  const MyCodeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'My code', footer: [SecondaryButton('Save image', onPressed: () => toast(context, 'Saved to photos (sample)'))], children: [
      const SizedBox(height: 24),
      Center(child: CodePattern(seed: app.email.isEmpty ? 'sample' : app.email)),
      const SizedBox(height: 24),
      Center(child: Text('Scan to add ${app.nickname}.', style: AlviType.insight(context))),
      const Disclaimer('Sample pattern. A scannable code is generated once accounts are connected.'),
    ]);
  }
}
