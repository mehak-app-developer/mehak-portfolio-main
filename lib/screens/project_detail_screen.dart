import 'package:flutter/material.dart';

import '../models/project_model.dart';

class ProjectDetailScreen extends StatefulWidget {
final ProjectModel project;

const ProjectDetailScreen({
super.key,
required this.project,
});

@override
State<ProjectDetailScreen> createState() =>
_ProjectDetailScreenState();
}

class _ProjectDetailScreenState
extends State<ProjectDetailScreen>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;
late Animation<double> _imageScaleAnimation;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1100),
);

_fadeAnimation = CurvedAnimation(
parent: _controller,
curve: Curves.easeOut,
);

_slideAnimation = Tween<Offset>(
begin: const Offset(0, 0.10),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
),
);

_imageScaleAnimation = Tween<double>(
begin: 0.90,
end: 1.0,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeOutBack,
),
);

_controller.forward();
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);

return Scaffold(
backgroundColor: const Color(0xFF0B1120),

appBar: AppBar(
backgroundColor: const Color(0xFF0B1120),
foregroundColor: Colors.white,
elevation: 0,
title: const Text(
'Project Details',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 1000,
),
child: FadeTransition(
opacity: _fadeAnimation,
child: SlideTransition(
position: _slideAnimation,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// =================================================
// PROJECT IMAGE
// =================================================

ScaleTransition(
scale: _imageScaleAnimation,
child: _buildProjectImage(),
),

const SizedBox(height: 30),

// =================================================
// TITLE
// =================================================

_AnimatedSection(
controller: _controller,
delay: 0.15,
child: Text(
widget.project.title,
style: theme
    .textTheme
    .headlineMedium
    ?.copyWith(
color: Colors.white,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(height: 18),

// =================================================
// YEAR + LOCATION
// =================================================

_AnimatedSection(
controller: _controller,
delay: 0.22,
child: Wrap(
spacing: 12,
runSpacing: 12,
children: [
_InfoChip(
icon:
Icons.calendar_month_outlined,
text: widget.project.year,
),
_InfoChip(
icon:
Icons.location_on_outlined,
text:
widget.project.location,
),
],
),
),

const SizedBox(height: 32),

// =================================================
// TECHNOLOGIES
// =================================================

_AnimatedSection(
controller: _controller,
delay: 0.30,
child: _buildContentSection(
title: 'Technologies',
icon: Icons.code_outlined,
child: Text(
widget.project.technologies,
style: const TextStyle(
color: Color(0xFF67E8F9),
fontSize: 16,
fontWeight: FontWeight.w600,
height: 1.5,
),
),
),
),

const SizedBox(height: 28),

// =================================================
// DESCRIPTION
// =================================================

_AnimatedSection(
controller: _controller,
delay: 0.40,
child: _buildContentSection(
title: 'Project Description',
icon:
Icons.description_outlined,
child: Text(
widget.project.description,
style: const TextStyle(
color: Colors.white70,
fontSize: 16,
height: 1.7,
),
),
),
),

const SizedBox(height: 28),

// =================================================
// OVERVIEW
// =================================================

_AnimatedSection(
controller: _controller,
delay: 0.50,
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Project Overview',
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight:
FontWeight.w700,
),
),
const SizedBox(height: 12),
_buildOverview(
widget.project,
),
],
),
),

const SizedBox(height: 40),

// =================================================
// BACK BUTTON
// =================================================

_AnimatedSection(
controller: _controller,
delay: 0.65,
child: SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: () {
Navigator.pop(context);
},
icon: const Icon(
Icons.arrow_back,
),
label: const Text(
'Back to Projects',
),
style:
ElevatedButton.styleFrom(
padding:
const EdgeInsets
    .symmetric(
vertical: 16,
),
backgroundColor:
const Color(
0xFF06B6D4,
),
foregroundColor:
Colors.white,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),
),
),
),
),

const SizedBox(height: 20),
],
),
),
),
),
),
),
);
}

// ===============================================================
// PROJECT IMAGE
// ===============================================================

Widget _buildProjectImage() {
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: const Color(0xFF06B6D4)
    .withValues(alpha: 0.10),
blurRadius: 30,
spreadRadius: 2,
offset: const Offset(0, 12),
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(24),
child: AspectRatio(
aspectRatio: 16 / 9,
child: Image.asset(
widget.project.imageUrl,
width: double.infinity,
fit: BoxFit.cover,
errorBuilder: (
context,
error,
stackTrace,
) {
return Container(
color: const Color(0xFF111827),
alignment: Alignment.center,
child: const Icon(
Icons.image_not_supported_outlined,
size: 60,
color: Colors.white54,
),
);
},
),
),
),
);
}

// ===============================================================
// CONTENT SECTION
// ===============================================================

Widget _buildContentSection({
required String title,
required IconData icon,
required Widget child,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: const Color(0xFF111827),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFF1F2937),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: const Color(0xFF083344),
borderRadius:
BorderRadius.circular(12),
),
child: Icon(
icon,
color: const Color(0xFF22D3EE),
size: 21,
),
),
const SizedBox(width: 13),
Text(
title,
style: const TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.w700,
),
),
],
),
const SizedBox(height: 18),
child,
],
),
);
}

// ===============================================================
// PROJECT OVERVIEW
// ===============================================================

Widget _buildOverview(
ProjectModel project,
) {
final title = project.title.toLowerCase();

List<String> points;

if (title.contains('bano qabil')) {
points = [
'Student registration and profile management',
'Free IT course application workflow',
'Class and attendance information',
'Assignments and academic progress',
'Firebase Authentication and Firestore integration',
];
} else if (title.contains('cybersafe')) {
points = [
'Cyber crime awareness content',
'Complaint management workflow',
'User and guest navigation flows',
'Modern responsive mobile interface',
'Flutter-based UI/UX implementation',
];
} else if (title.contains('restaurant')) {
points = [
'Restaurant database management',
'Menu and food record management',
'Order record handling',
'SQL database operations',
'Academic DBMS project implementation',
];
} else {
points = [
'Responsive website structure',
'HTML page development',
'CSS styling and layout',
'JavaScript functionality',
'Academic Web Technology implementation',
];
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: const Color(0xFF111827),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFF1F2937),
),
),
child: Column(
children: List.generate(
points.length,
(index) {
return _OverviewItem(
text: points[index],
index: index,
);
},
),
),
);
}
}

// ===============================================================
// ANIMATED SECTION
// ===============================================================

class _AnimatedSection extends StatelessWidget {
final AnimationController controller;
final double delay;
final Widget child;

const _AnimatedSection({
required this.controller,
required this.delay,
required this.child,
});

@override
Widget build(BuildContext context) {
final animation = CurvedAnimation(
parent: controller,
curve: Interval(
delay,
(delay + 0.30).clamp(0.0, 1.0),
curve: Curves.easeOutCubic,
),
);

final slide = Tween<Offset>(
begin: const Offset(0, 0.08),
end: Offset.zero,
).animate(animation);

return FadeTransition(
opacity: animation,
child: SlideTransition(
position: slide,
child: child,
),
);
}
}

// ===============================================================
// OVERVIEW ITEM ANIMATION
// ===============================================================

class _OverviewItem extends StatefulWidget {
final String text;
final int index;

const _OverviewItem({
required this.text,
required this.index,
});

@override
State<_OverviewItem> createState() =>
_OverviewItemState();
}

class _OverviewItemState
extends State<_OverviewItem>
with SingleTickerProviderStateMixin {
late AnimationController _controller;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: Duration(
milliseconds: 500 + (widget.index * 100),
),
);

Future.delayed(
Duration(
milliseconds: 250 + (widget.index * 100),
),
() {
if (mounted) {
_controller.forward();
}
},
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final animation = CurvedAnimation(
parent: _controller,
curve: Curves.easeOutCubic,
);

final slide = Tween<Offset>(
begin: const Offset(-0.08, 0),
end: Offset.zero,
).animate(animation);

return Padding(
padding: const EdgeInsets.only(
bottom: 14,
),
child: FadeTransition(
opacity: animation,
child: SlideTransition(
position: slide,
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.check_circle_outline,
color: Color(0xFF22D3EE),
size: 21,
),
const SizedBox(width: 12),
Expanded(
child: Text(
widget.text,
style: const TextStyle(
color: Colors.white70,
fontSize: 15,
height: 1.5,
),
),
),
],
),
),
),
);
}
}

// ===============================================================
// INFO CHIP
// ===============================================================

class _InfoChip extends StatelessWidget {
final IconData icon;
final String text;

const _InfoChip({
required this.icon,
required this.text,
});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 10,
),
decoration: BoxDecoration(
color: const Color(0xFF111827),
borderRadius: BorderRadius.circular(30),
border: Border.all(
color: const Color(0xFF1F2937),
),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
size: 18,
color: const Color(0xFF22D3EE),
),
const SizedBox(width: 8),
Text(
text,
style: const TextStyle(
color: Colors.white70,
fontWeight: FontWeight.w500,
),
),
],
),
);
}
}
