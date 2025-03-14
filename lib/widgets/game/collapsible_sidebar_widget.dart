import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/species_data.dart';
import '../../utils/constants/text_styles.dart';
import 'chambers_section_widget.dart';
import 'population_section_widget.dart';
import 'resources_section_widget.dart';
import 'tasks_section_widget.dart';

class CollapsibleSidebarWidget extends StatefulWidget {
  const CollapsibleSidebarWidget({super.key});

  @override
  State<CollapsibleSidebarWidget> createState() =>
      _CollapsibleSidebarWidgetState();
}

class _CollapsibleSidebarWidgetState extends State<CollapsibleSidebarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 280.0, // Breite im ausgeklappten Zustand
      end: 60.0, // Breite im eingeklappten Zustand
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bildschirmgrößen abrufen
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    // Maximale Breite für kleinere Bildschirme anpassen
    final maxWidth = isSmallScreen ? size.width * 0.8 : 280.0;
    final minWidth = isSmallScreen ? 50.0 : 60.0;

    // Animation für dynamische Bildschirmgrößen anpassen
    _widthAnimation = Tween<double>(
      begin: maxWidth,
      end: minWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Spezies-Informationen
        final species =
            gameProvider.selectedSpeciesId != null
                ? SpeciesData.getById(gameProvider.selectedSpeciesId!)
                : null;

        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(-3, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Kolonie-Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: isSmallScreen ? 8.0 : 12.0,
                ),
                color:
                    species != null
                        ? _getSpeciesColor(species.color)
                        : AppColors.primary,
                child: Row(
                  children: [
                    // Toggle-Button
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.chevron_right : Icons.chevron_left,
                      ),
                      color:
                          species != null
                              ? _getSpeciesColor(
                                        species.color,
                                      ).computeLuminance() >
                                      0.5
                                  ? Colors.black87
                                  : Colors.white
                              : Colors.white,
                      onPressed: _toggleSidebar,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: isSmallScreen ? 20 : 24,
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              species?.name ?? 'Deine Kolonie',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    species != null
                                        ? _getSpeciesColor(
                                                  species.color,
                                                ).computeLuminance() >
                                                0.5
                                            ? Colors.black87
                                            : Colors.white
                                        : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (species != null)
                              Text(
                                species.scientificName,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color:
                                      species != null
                                          ? _getSpeciesColor(
                                                    species.color,
                                                  ).computeLuminance() >
                                                  0.5
                                              ? Colors.black54
                                              : Colors.white70
                                          : Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Scrollbarer Inhalt
              Expanded(
                child:
                    _isExpanded
                        ? SingleChildScrollView(
                          child: Column(
                            children: const [
                              // Ressourcen
                              ResourcesSectionWidget(),

                              // Population
                              PopulationSectionWidget(),

                              // Aufgabenverteilung
                              TasksSectionWidget(),

                              // Kammerbau
                              ChambersSectionWidget(),

                              SizedBox(height: AppDimensions.l),
                            ],
                          ),
                        )
                        : SingleChildScrollView(
                          child: Column(
                            children: [
                              // Minimierte Icons für jeden Abschnitt
                              _buildCollapsedSection(
                                icon: Icons.inventory_2_outlined,
                                label: 'Ressourcen',
                                onTap: () => _expandAndScrollTo(0),
                              ),
                              _buildCollapsedSection(
                                icon: Icons.people_outline,
                                label: 'Population',
                                onTap: () => _expandAndScrollTo(1),
                              ),
                              _buildCollapsedSection(
                                icon: Icons.assignment_outlined,
                                label: 'Aufgaben',
                                onTap: () => _expandAndScrollTo(2),
                              ),
                              _buildCollapsedSection(
                                icon: Icons.home_outlined,
                                label: 'Kammern',
                                onTap: () => _expandAndScrollTo(3),
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollapsedSection({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }

  void _expandAndScrollTo(int sectionIndex) {
    // Erst Sidebar erweitern, dann zu Abschnitt scrollen
    if (!_isExpanded) {
      setState(() {
        _controller.reverse();
        _isExpanded = true;
      });

      // Nach Animation zum gewünschten Abschnitt scrollen
      Future.delayed(const Duration(milliseconds: 300), () {
        // Hier muss später eine Scroll-Controller-Logik implementiert werden
      });
    }
  }

  Color _getSpeciesColor(String colorName) {
    switch (colorName) {
      case 'green':
        return AppColors.attaGreen;
      case 'yellow':
        return AppColors.oecophyllaYellow;
      case 'red':
        return AppColors.ecitonRed;
      case 'orange':
        return AppColors.solenopsisOrange;
      default:
        return AppColors.primary;
    }
  }
}
