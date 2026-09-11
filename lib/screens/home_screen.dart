import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/certification_model.dart';
import '../models/education_model.dart';
import '../models/project_model.dart';
import '../models/skill_model.dart';

import '../services/certification_service.dart';
import '../services/education_service.dart';
import '../services/message_service.dart';
import '../services/project_service.dart';
import '../services/skill_service.dart';

import 'project_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isSending = false;

  final List<GlobalKey> _sectionKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  // ============================================================
  // YOUR PERSONAL INFORMATION
  // ============================================================

  static const String name = 'Mehak Ishaq';

  static const String email = 'imehak237@gmail.com';

  static const String githubProfile =
      'https://github.com/mehak-app-developer';

  static const String linkedinProfile =
      'https://www.linkedin.com/in/mehak-ishaq-9b649b347';

  static const String location = 'Rawalpindi, Pakistan';

  // Project GitHub links
  static const String bloodCampGithub =
      'https://github.com/mehak-app-developer/blood_camp';

  static const String cyberSafeGithub =
      'https://github.com/mehak-app-developer/cybersafe-app';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  // ============================================================
  // OPEN URL
  // ============================================================

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showSnackBar(
          'Unable to open this link.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Unable to open link.',
        isError: true,
      );
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      _showSnackBar(
        'Please fill all contact fields.',
        isError: true,
      );
      return;
    }

    if (!RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    ).hasMatch(email)) {
      _showSnackBar(
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    if (message.length < 10) {
      _showSnackBar(
        'Message must contain at least 10 characters.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await MessageService.instance.sendMessage(
        name: name,
        email: email,
        message: message,
      );

      if (!mounted) return;

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      _showSnackBar(
        'Message sent successfully!',
      );
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Unable to send message.\n$e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF0891B2),
      ),
    );
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) return;

    final context = _sectionKeys[index].currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        alignment: 0.08,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildNavigation(isMobile),
            ),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildHeroSection(isMobile),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _buildAboutSection(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildEducationSection(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildSkillsSection(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildProjectsSection(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildCertificationSection(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildContactSection(isMobile),
            ),

            SliverToBoxAdapter(
              child: _buildFooter(),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      isMobile ? _buildMobileNavigation() : null,
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _buildNavigation(bool isMobile) {
    if (isMobile) {
      return const SizedBox(height: 4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120).withValues(alpha: 0.96),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Mehak.',
            style: TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Spacer(),

          _navButton(
            'Home',
                () => _scrollToSection(0),
          ),

          _navButton(
            'About',
                () => _scrollToSection(1),
          ),

          _navButton(
            'Education',
                () => _scrollToSection(2),
          ),

          _navButton(
            'Skills',
                () => _scrollToSection(3),
          ),

          _navButton(
            'Projects',
                () => _scrollToSection(4),
          ),

          _navButton(
            'Contact',
                () => _scrollToSection(5),
          ),
        ],
      ),
    );
  }

  Widget _navButton(
      String title,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE NAVIGATION
  // ============================================================

  Widget _buildMobileNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,
          children: [
            _mobileNavItem(
              Icons.home_outlined,
              'Home',
              0,
            ),

            _mobileNavItem(
              Icons.person_outline,
              'About',
              1,
            ),

            _mobileNavItem(
              Icons.code_outlined,
              'Projects',
              4,
            ),

            _mobileNavItem(
              Icons.mail_outline,
              'Contact',
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileNavItem(
      IconData icon,
      String title,
      int index,
      ) {
    return IconButton(
      onPressed: () => _scrollToSection(index),
      tooltip: title,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF22D3EE),
            size: 22,
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO SECTION
  // ============================================================

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      key: _sectionKeys[0],
      constraints: const BoxConstraints(
        minHeight: 650,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: isMobile ? 55 : 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: isMobile
              ? Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              _buildProfileImage(),

              const SizedBox(height: 40),

              _buildHeroText(true),
            ],
          )
              : Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildHeroText(false),
              ),

              const SizedBox(width: 60),

              Expanded(
                flex: 4,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildProfileImage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO TEXT
  // ============================================================

  Widget _buildHeroText(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF083344),
            borderRadius:
            BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF155E75),
            ),
          ),
          child: const Text(
            'FLUTTER DEVELOPER • APP DEVELOPER',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF67E8F9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'Hi, I\'m Mehak Ishaq',
          textAlign:
          isMobile
              ? TextAlign.center
              : TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 38 : 56,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'I build modern, user-friendly and meaningful digital experiences with Flutter.',
          textAlign:
          isMobile
              ? TextAlign.center
              : TextAlign.left,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isMobile ? 17 : 20,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          alignment: isMobile
              ? WrapAlignment.center
              : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () =>
                  _scrollToSection(4),
              icon: const Icon(
                Icons.work_outline,
              ),
              label: const Text(
                'View My Projects',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF06B6D4),
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            OutlinedButton.icon(
              onPressed: () =>
                  _scrollToSection(5),
              icon: const Icon(
                Icons.mail_outline,
              ),
              label: const Text(
                'Contact Me',
              ),
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Colors.white,
                side: const BorderSide(
                  color: Color(0xFF334155),
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        Wrap(
          alignment: isMobile
              ? WrapAlignment.center
              : WrapAlignment.start,
          spacing: 10,
          children: [
            _socialButton(
              icon: Icons.code,
              tooltip: 'GitHub',
              onTap: () =>
                  _openUrl(githubProfile),
            ),

            _socialButton(
              icon:
              Icons.business_center_outlined,
              tooltip: 'LinkedIn',
              onTap: () =>
                  _openUrl(linkedinProfile),
            ),

            _socialButton(
              icon: Icons.email_outlined,
              tooltip: 'Email',
              onTap: () =>
                  _openUrl('mailto:$email'),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10182B),
            boxShadow: [
              BoxShadow(
                color:
                const Color(0xFF00C8E8)
                    .withValues(
                  alpha: 0.08,
                ),
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
        ),

        Container(
          width: 400,
          height: 410,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(200),
            border: Border.all(
              color: const Color(0xFF00C8E8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                const Color(0xFF00C8E8)
                    .withValues(
                  alpha: 0.25,
                ),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(200),
            child: Container(
              color: const Color(0xFF0F172A),
              child: Image.asset(
                'assets/images/profile.jpg',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Center(
                    child: Icon(
                      Icons
                          .person_outline_rounded,
                      color: Colors.white54,
                      size: 90,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SOCIAL BUTTON
  // ============================================================

  Widget _socialButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius:
            BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1E293B),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white70,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutSection(bool isMobile) {
    return _sectionContainer(
      key: _sectionKeys[1],
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'About Me',
            'A little introduction',
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              isMobile ? 22 : 32,
            ),
            decoration: _cardDecoration(),
            child: isMobile
                ? Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _aboutIcon(),

                const SizedBox(height: 22),

                _aboutText(),
              ],
            )
                : Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _aboutIcon(),

                const SizedBox(width: 28),

                Expanded(
                  child: _aboutText(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutIcon() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF083344),
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.code_rounded,
        color: Color(0xFF22D3EE),
        size: 30,
      ),
    );
  }

  Widget _aboutText() {
    return const Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Flutter Developer & Creative Digital Professional',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 14),

        Text(
          'I am Mehak Ishaq, a Flutter Developer passionate about building modern, responsive and user-friendly mobile applications. I enjoy creating practical digital solutions with clean interfaces and smooth user experiences.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.7,
          ),
        ),

        SizedBox(height: 12),

        Text(
          'Along with Flutter and Dart, I work with Firebase, UI/UX design, graphic design, Canva, WordPress and SEO. I enjoy turning ideas into useful and visually engaging digital products.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EDUCATION
  // ============================================================

  Widget _buildEducationSection(
      bool isMobile,
      ) {
    return _sectionContainer(
      key: _sectionKeys[2],
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Education',
            'My academic journey',
          ),

          const SizedBox(height: 28),

          StreamBuilder<
              List<EducationModel>>(
            stream: EducationService
                .instance
                .getEducation(),

            builder: (
                context,
                snapshot,
                ) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return _loadingBox();
              }

              if (snapshot.hasError) {
                return _errorBox(
                  'Unable to load education data.\n\n'
                      'Firebase Error:\n${snapshot.error}',
                );
              }

              final education =
                  snapshot.data ?? [];

              if (education.isEmpty) {
                return _emptyBox(
                  'No education data available.',
                );
              }

              return Column(
                children:
                education.map((item) {
                  return Container(
                    width: double.infinity,
                    margin:
                    const EdgeInsets.only(
                      bottom: 16,
                    ),
                    padding: EdgeInsets.all(
                      isMobile ? 20 : 26,
                    ),
                    decoration:
                    _cardDecoration(),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFF083344,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .school_outlined,
                            color:
                            Color(0xFF22D3EE),
                          ),
                        ),

                        const SizedBox(
                          width: 18,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                item.name,
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 19,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                item.institute,
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white70,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                item.affiliation,
                                style:
                                const TextStyle(
                                  color:
                                  Color(
                                    0xFF67E8F9,
                                  ),
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                '${item.startYear} – ${item.endYear}',
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SKILLS
  // ============================================================

  Widget _buildSkillsSection(
      bool isMobile,
      ) {
    return _sectionContainer(
      key: _sectionKeys[3],
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Skills',
            'Technologies I work with',
          ),

          const SizedBox(height: 28),

          StreamBuilder<List<SkillModel>>(
            stream:
            SkillService.instance
                .getSkills(),

            builder: (
                context,
                snapshot,
                ) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return _loadingBox();
              }

              if (snapshot.hasError) {
                return _errorBox(
                  'Unable to load skills.\n\n'
                      'Firebase Error:\n${snapshot.error}',
                );
              }

              final skills =
                  snapshot.data ?? [];

              if (skills.isEmpty) {
                return _emptyBox(
                  'No skills available.\n\n'
                      'Firestore collection "skills" is empty.',
                );
              }

              return LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final columns =
                  isMobile
                      ? 1
                      : constraints.maxWidth >
                      900
                      ? 3
                      : 2;

                  final itemWidth =
                      (constraints.maxWidth -
                          ((columns - 1) *
                              16)) /
                          columns;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                    skills.map((skill) {
                      return SizedBox(
                        width: itemWidth,
                        child: _SkillCard(
                          skill: skill,
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROJECTS
  // ============================================================

  Widget _buildProjectsSection(
      bool isMobile,
      ) {
    return _sectionContainer(
      key: _sectionKeys[4],
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Projects',
            'Things I have built',
          ),

          const SizedBox(height: 12),

          const Text(
            'Explore my Flutter applications and development projects.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 28),

          StreamBuilder<List<ProjectModel>>(
            stream:
            ProjectService.instance
                .getProjects(),

            builder: (
                context,
                snapshot,
                ) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return _loadingBox();
              }

              if (snapshot.hasError) {
                return _errorBox(
                  'Unable to load projects.\n\n'
                      'Firebase Error:\n${snapshot.error}',
                );
              }

              final projects =
                  snapshot.data ?? [];

              /*
               * If Firebase projects are empty,
               * display the two portfolio projects
               * directly.
               */
              if (projects.isEmpty) {
                return _buildDefaultProjects(
                  isMobile,
                );
              }

              return LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final columns =
                  isMobile
                      ? 1
                      : constraints.maxWidth >
                      950
                      ? 2
                      : 1;

                  const spacing = 20.0;

                  final cardWidth =
                      (constraints.maxWidth -
                          ((columns - 1) *
                              spacing)) /
                          columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children:
                    projects.map((project) {
                      return SizedBox(
                        width: cardWidth,
                        child: _ProjectCard(
                          project: project,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProjectDetailScreen(
                                      project:
                                      project,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEFAULT PROJECTS
  // ============================================================

  Widget _buildDefaultProjects(
      bool isMobile,
      ) {
    return Column(
      children: [
        _PortfolioProjectCard(
          title: 'Blood Camp',
          description:
          'Book a blood camp slot, check in donors, and keep a safe record of blood group and last donation.',
          technologies:
          'Flutter • Dart • Firebase',
          icon: Icons.bloodtype_outlined,
          githubUrl: bloodCampGithub,
        ),

        const SizedBox(height: 20),

        _PortfolioProjectCard(
          title: 'CyberSafe',
          description:
          'A cybersecurity awareness and protection app that helps users identify, report, and stay safe from common online threats.',
          technologies:
          'Flutter • Dart • Firebase',
          icon: Icons.security_outlined,
          githubUrl: cyberSafeGithub,
        ),
      ],
    );
  }

  // ============================================================
  // CERTIFICATIONS
  // ============================================================

  Widget _buildCertificationSection(
      bool isMobile,
      ) {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Certifications',
            'Courses and achievements',
          ),

          const SizedBox(height: 28),

          StreamBuilder<
              List<CertificationModel>>(
            stream: CertificationService
                .instance
                .getCertifications(),

            builder: (
                context,
                snapshot,
                ) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return _loadingBox();
              }

              if (snapshot.hasError) {
                return _errorBox(
                  'Unable to load certifications.\n\n'
                      'Firebase Error:\n${snapshot.error}',
                );
              }

              final certifications =
                  snapshot.data ?? [];

              if (certifications.isEmpty) {
                return _emptyBox(
                  'No certifications available.',
                );
              }

              return Column(
                children:
                certifications.map(
                      (certificate) {
                    return Container(
                      width: double.infinity,
                      margin:
                      const EdgeInsets.only(
                        bottom: 16,
                      ),
                      padding: EdgeInsets.all(
                        isMobile ? 20 : 26,
                      ),
                      decoration:
                      _cardDecoration(),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFF083344,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                14,
                              ),
                            ),
                            child: const Icon(
                              Icons
                                  .verified_outlined,
                              color:
                              Color(0xFF22D3EE),
                              size: 27,
                            ),
                          ),

                          const SizedBox(
                            width: 18,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  certificate.title,
                                  style:
                                  const TextStyle(
                                    color:
                                    Colors.white,
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Text(
                                  certificate
                                      .organization,
                                  style:
                                  const TextStyle(
                                    color:
                                    Color(
                                      0xFF67E8F9,
                                    ),
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  certificate
                                      .description,
                                  style:
                                  const TextStyle(
                                    color:
                                    Colors.white70,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Text(
                                  '${certificate.year}',
                                  style:
                                  const TextStyle(
                                    color:
                                    Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT
  // ============================================================

  Widget _buildContactSection(
      bool isMobile,
      ) {
    return _sectionContainer(
      key: _sectionKeys[5],
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Contact',
            'Let\'s connect',
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              isMobile ? 20 : 32,
            ),
            decoration: _cardDecoration(),
            child: isMobile
                ? Column(
              children: [
                _contactIntro(),

                const SizedBox(
                  height: 30,
                ),

                _contactForm(),
              ],
            )
                : Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                  _contactIntro(),
                ),

                const SizedBox(
                  width: 60,
                ),

                Expanded(
                  child:
                  _contactForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT INTRO
  // ============================================================

  Widget _contactIntro() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Have a project or opportunity in mind?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Feel free to send me a message. I would be happy to connect and discuss ideas, projects or opportunities.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.7,
          ),
        ),

        const SizedBox(height: 25),

        _contactInfo(
          Icons.email_outlined,
          email,
        ),

        const SizedBox(height: 12),

        _contactInfo(
          Icons.location_on_outlined,
          location,
        ),

        const SizedBox(height: 25),

        // GitHub and LinkedIn
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _contactLinkButton(
              icon: Icons.code,
              title: 'GitHub',
              onTap: () =>
                  _openUrl(githubProfile),
            ),

            _contactLinkButton(
              icon:
              Icons.business_center_outlined,
              title: 'LinkedIn',
              onTap: () =>
                  _openUrl(linkedinProfile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contactInfo(
      IconData icon,
      String text,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF22D3EE),
          size: 21,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactLinkButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(
          color: Color(0xFF334155),
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT FORM
  // ============================================================

  Widget _contactForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          textInputAction:
          TextInputAction.next,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: _inputDecoration(
            'Your Name',
            Icons.person_outline,
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _emailController,
          keyboardType:
          TextInputType.emailAddress,
          textInputAction:
          TextInputAction.next,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: _inputDecoration(
            'Email Address',
            Icons.email_outlined,
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _messageController,
          maxLines: 5,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: _inputDecoration(
            'Your Message',
            Icons.message_outlined,
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
            _isSending
                ? null
                : _sendMessage,
            icon: _isSending
                ? const SizedBox(
              width: 18,
              height: 18,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.send_outlined,
            ),
            label: Text(
              _isSending
                  ? 'Sending...'
                  : 'Send Message',
            ),
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFF06B6D4),
              foregroundColor:
              Colors.white,
              disabledBackgroundColor:
              const Color(0xFF155E75),
              padding:
              const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,

      labelStyle:
      const TextStyle(
        color: Colors.white54,
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF22D3EE),
      ),

      filled: true,

      fillColor:
      const Color(0xFF0B1120),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Color(0xFF1E293B),
        ),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Color(0xFF1E293B),
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Color(0xFF22D3EE),
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 30,
      ),
      decoration:
      const BoxDecoration(
        color: Color(0xFF070D19),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'Mehak Ishaq',
            style: TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Flutter Developer • App Developer',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),

          SizedBox(height: 15),

          Text(
            '© 2026 Mehak Ishaq • Built with Flutter & Firebase',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CONTAINER
  // ============================================================

  Widget _sectionContainer({
    Key? key,
    required Widget child,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 1200,
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF67E8F9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: 55,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4),
            borderRadius:
            BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF111827),
      borderRadius:
      BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF1E293B),
      ),
      boxShadow: [
        BoxShadow(
          color:
          Colors.black.withValues(
            alpha: 0.12,
          ),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingBox() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF22D3EE),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFF87171),
            size: 30,
          ),

          const SizedBox(height: 12),

          SelectableText(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyBox(String message) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white60,
        ),
      ),
    );
  }
}

// =================================================================
// SKILL CARD
// =================================================================

class _SkillCard extends StatefulWidget {
  final SkillModel skill;

  const _SkillCard({
    required this.skill,
  });

  @override
  State<_SkillCard> createState() =>
      _SkillCardState();
}

class _SkillCardState
    extends State<_SkillCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final level =
        widget.skill.level.clamp(0, 5) / 5;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 220,
        ),

        curve: Curves.easeOut,

        transform:
        Matrix4.translationValues(
          0,
          _hovered ? -5 : 0,
          0,
        ),

        padding:
        const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color:
          const Color(0xFF111827),

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: _hovered
                ? const Color(
              0xFF0891B2,
            )
                : const Color(
              0xFF1E293B,
            ),
          ),

          boxShadow: _hovered
              ? [
            BoxShadow(
              color:
              const Color(
                0xFF06B6D4,
              ).withValues(
                alpha: 0.10,
              ),
              blurRadius: 18,
              offset:
              const Offset(
                0,
                8,
              ),
            ),
          ]
              : [],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.skill.name,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  '${widget.skill.level}/5',
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF67E8F9),
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              widget.skill.category,
              style:
              const TextStyle(
                color:
                Colors.white54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 15),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              child:
              TweenAnimationBuilder<
                  double>(
                tween: Tween(
                  begin: 0,
                  end: level.toDouble(),
                ),
                duration:
                const Duration(
                  milliseconds: 1000,
                ),
                curve:
                Curves.easeOutCubic,
                builder: (
                    context,
                    value,
                    child,
                    ) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor:
                    const Color(
                      0xFF1E293B,
                    ),
                    color:
                    const Color(
                      0xFF06B6D4,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// FIREBASE PROJECT CARD
// =================================================================

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
  });

  @override
  State<_ProjectCard> createState() =>
      _ProjectCardState();
}

class _ProjectCardState
    extends State<_ProjectCard> {
  bool _hovered = false;

  String? _getGithubUrl() {
    final title =
    widget.project.title.toLowerCase();

    if (title.contains('blood')) {
      return _HomeScreenState.bloodCampGithub;
    }

    if (title.contains('cyber')) {
      return _HomeScreenState.cyberSafeGithub;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final githubUrl =
    _getGithubUrl();

    return MouseRegion(
      cursor:
      SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: AnimatedScale(
        scale:
        _hovered ? 1.015 : 1,

        duration:
        const Duration(
          milliseconds: 220,
        ),

        curve: Curves.easeOut,

        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 220,
          ),

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFF111827,
            ),

            borderRadius:
            BorderRadius.circular(
              20,
            ),

            border: Border.all(
              color: _hovered
                  ? const Color(
                0xFF0891B2,
              )
                  : const Color(
                0xFF1E293B,
              ),
            ),

            boxShadow: _hovered
                ? [
              BoxShadow(
                color:
                const Color(
                  0xFF06B6D4,
                ).withValues(
                  alpha: 0.12,
                ),
                blurRadius: 25,
                offset:
                const Offset(
                  0,
                  12,
                ),
              ),
            ]
                : [],
          ),

          child: InkWell(
            onTap: widget.onTap,

            borderRadius:
            BorderRadius.circular(
              20,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius
                      .vertical(
                    top:
                    Radius.circular(
                      20,
                    ),
                  ),

                  child: AspectRatio(
                    aspectRatio:
                    16 / 9,

                    child: Image.asset(
                      widget.project
                          .imageUrl,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color:
                          const Color(
                            0xFF0B1120,
                          ),

                          child:
                          const Center(
                            child: Icon(
                              Icons
                                  .image_not_supported_outlined,
                              color:
                              Colors.white38,
                              size: 45,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .all(20),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.project
                                  .title,

                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 19,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons
                                .arrow_outward_rounded,
                            color:
                            Color(
                              0xFF22D3EE,
                            ),
                            size: 20,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .calendar_month_outlined,
                            color:
                            Colors.white38,
                            size: 16,
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          Text(
                            widget.project
                                .year,
                            style:
                            const TextStyle(
                              color:
                              Colors.white54,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          const Icon(
                            Icons
                                .location_on_outlined,
                            color:
                            Colors.white38,
                            size: 16,
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Expanded(
                            child: Text(
                              widget.project
                                  .location,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(
                        widget.project
                            .description,

                        maxLines: 3,

                        overflow:
                        TextOverflow
                            .ellipsis,

                        style:
                        const TextStyle(
                          color:
                          Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Container(
                        width:
                        double.infinity,

                        padding:
                        const EdgeInsets
                            .all(12),

                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFF0B1120,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),

                        child: Text(
                          widget.project
                              .technologies,

                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF67E8F9,
                            ),
                            fontSize: 12,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                            Text(
                              'View Project Details →',
                              style:
                              TextStyle(
                                color:
                                _hovered
                                    ? const Color(
                                  0xFF67E8F9,
                                )
                                    : const Color(
                                  0xFF22D3EE,
                                ),
                                fontSize:
                                14,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ),

                          if (githubUrl !=
                              null)
                            IconButton(
                              tooltip:
                              'View GitHub',

                              onPressed:
                                  () =>
                                  _openExternalUrl(
                                    githubUrl,
                                  ),

                              icon:
                              const Icon(
                                Icons.code,
                                color:
                                Color(
                                  0xFF67E8F9,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openExternalUrl(
      String url,
      ) async {
    final uri = Uri.parse(url);

    try {
      await launchUrl(
        uri,
        mode:
        LaunchMode
            .externalApplication,
      );
    } catch (_) {}
  }
}

// =================================================================
// DEFAULT PORTFOLIO PROJECT CARD
// =================================================================

class _PortfolioProjectCard
    extends StatefulWidget {
  final String title;
  final String description;
  final String technologies;
  final IconData icon;
  final String githubUrl;

  const _PortfolioProjectCard({
    required this.title,
    required this.description,
    required this.technologies,
    required this.icon,
    required this.githubUrl,
  });

  @override
  State<_PortfolioProjectCard> createState() =>
      _PortfolioProjectCardState();
}

class _PortfolioProjectCardState
    extends State<_PortfolioProjectCard> {
  bool _hovered = false;

  Future<void> _openGithub() async {
    final uri =
    Uri.parse(widget.githubUrl);

    try {
      await launchUrl(
        uri,
        mode:
        LaunchMode
            .externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
      SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 220,
        ),

        padding:
        const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color:
          const Color(0xFF111827),

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color: _hovered
                ? const Color(
              0xFF0891B2,
            )
                : const Color(
              0xFF1E293B,
            ),
          ),

          boxShadow: _hovered
              ? [
            BoxShadow(
              color:
              const Color(
                0xFF06B6D4,
              ).withValues(
                alpha: 0.12,
              ),
              blurRadius: 25,
              offset:
              const Offset(
                0,
                12,
              ),
            ),
          ]
              : [],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFF083344,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color:
                    const Color(
                      0xFF22D3EE,
                    ),
                    size: 30,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child: Text(
                    widget.title,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              widget.description,
              style:
              const TextStyle(
                color:
                Colors.white70,
                fontSize: 15,
                height: 1.7,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                12,
              ),

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFF0B1120,
                ),

                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child: Text(
                widget.technologies,
                style:
                const TextStyle(
                  color:
                  Color(0xFF67E8F9),
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              OutlinedButton.icon(
                onPressed:
                _openGithub,

                icon: const Icon(
                  Icons.code,
                  size: 19,
                ),

                label:
                const Text(
                  'View on GitHub',
                ),

                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  Colors.white,

                  side:
                  const BorderSide(
                    color:
                    Color(
                      0xFF334155,
                    ),
                  ),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 14,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}