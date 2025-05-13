import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/profile_service.dart';
import '../../data/models/profile_model.dart';
import '../widgets/interestwidget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_about_section_widget.dart';

class GetProfilePage extends StatefulWidget {
  const GetProfilePage({super.key});

  @override
  _GetProfilePageState createState() => _GetProfilePageState();
}

class _GetProfilePageState extends State<GetProfilePage> {
  ProfileModel? _profileData;
  String? _errorMessage;
  bool _isLoading = true;

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile({bool isRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      if (!isRefresh) {
        _errorMessage = null;
      }
    });

    try {
      final profile = await _profileService.fetchProfile();
      if (!mounted) return;

      if (profile != null) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = "Could not load profile. Please try again.";
          _isLoading = false;
          _profileData = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains("Failed to load profile")
            ? e.toString()
            : "An error occurred: $e. Using offline data if available.";
        _isLoading = false;
        _profileData ??= null;
      });
    }
  }

  Future<void> _logout() async {
    if (!mounted) return;
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF162329),
          title: const Text('Confirm Logout',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to logout?',
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await _profileService.logoutUser();
        if (mounted) {
          context.goNamed("landing");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Logout failed: $e'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "Loading...";
    if (!_isLoading && _profileData != null) {
      appBarTitle = "@${_profileData!.username}";
    } else if (_errorMessage != null && !_isLoading) {
      appBarTitle = "Profile";
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 2.4,
          colors: [
            Color(0xFF1F4247),
            Color(0xFF0D1D23),
            Color(0xFF09141A),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GoRouter.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => GoRouter.of(context).pop(),
                )
              : null,
          title: Text(appBarTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 22),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _profileData == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 50),
                          const SizedBox(height: 15),
                          Text(
                            _errorMessage ?? "Failed to load profile data.",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            label: const Text("Retry",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () => _loadProfile(isRefresh: false),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12)),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadProfile(isRefresh: true),
                    color: Colors.white,
                    backgroundColor: Colors.transparent,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        if (_errorMessage != null &&
                            _profileData != null &&
                            !_errorMessage!
                                .toLowerCase()
                                .contains("failed to load profile"))
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            color: Colors.orangeAccent,
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center),
                          ),
                        ProfileHeaderWidget(profile: _profileData!),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              ProfileAboutSectionWidget(profile: _profileData!),
                              const SizedBox(height: 16),
                              InterestDisplaySection(
                                interestsData: _profileData!.interests,
                                showEditButton: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
