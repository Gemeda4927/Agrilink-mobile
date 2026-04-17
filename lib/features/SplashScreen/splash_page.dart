import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;
  bool _locationGranted = false;
  bool _locationServiceEnabled = false;
  String _locationStatus = '';
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Welcome to AgriLink',
      description: 'Connect with farmers, buyers, and agricultural experts in your region',
      imageUrl: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800',
      color: Colors.green,
    ),
    OnboardingItem(
      title: 'Fresh Produce Direct',
      description: 'Buy and sell fresh agricultural products directly from farmers',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
      color: Colors.orange,
    ),
    OnboardingItem(
      title: 'Smart Farming',
      description: 'Get AI-powered recommendations for better crop management',
      imageUrl: 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c7ad2?w=800',
      color: Colors.blue,
    ),
    OnboardingItem(
      title: 'Real-time Market',
      description: 'Access live market prices and weather updates for your area',
      imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      setState(() {
        _locationServiceEnabled = false;
        _locationGranted = false;
        _locationStatus = 'Location services are disabled. Please enable GPS/location to continue.';
        _isLoading = false;
      });
      _showLocationServiceDialog();
      return;
    }

    setState(() {
      _locationServiceEnabled = true;
    });

    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      setState(() {
        _locationGranted = true;
        _locationStatus = 'Location access granted! You can now proceed.';
        _isLoading = false;
      });
    } else if (status.isDenied) {
      setState(() {
        _locationGranted = false;
        _locationStatus = 'Location access is required for the best experience';
        _isLoading = false;
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _locationGranted = false;
        _locationStatus = 'Location permission permanently denied. Please enable in settings.';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationServiceBeforeProceed() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      _showLocationServiceDialog();
      return;
    }

    PermissionStatus status = await Permission.location.status;
    
    if (status.isGranted) {
      setState(() {
        _locationGranted = true;
        _locationServiceEnabled = true;
        _locationStatus = 'Location access granted!';
        _isLoading = false;
      });
      _navigateToLogin();
    } else if (status.isDenied) {
      setState(() {
        _isLoading = false;
      });
      _requestLocationPermission();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isLoading = false;
      });
      _showSettingsDialog();
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Location Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location services are required for AgriLink to provide you with:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Local weather forecasts\n'
                '• Nearby market prices\n'
                '• Farming tips for your region\n'
                '• Connect with local farmers\n',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enable location services to continue.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin();
              },
              child: const Text('Skip Anyway'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                _checkLocationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Location Not Enabled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You haven\'t enabled location access. For the best experience with AgriLink, '
                'we recommend enabling location to get:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                '✓ Local weather updates\n'
                '✓ Real-time market prices\n'
                '✓ Region-specific farming advice\n'
                '✓ Nearby farmer connections\n',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can continue without location, but some features may be limited.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin();
              },
              child: const Text('Continue Without Location'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Enable Location'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      _showLocationServiceDialog();
      return;
    }

    PermissionStatus status = await Permission.location.request();

    setState(() {
      _isLoading = false;
      if (status.isGranted) {
        _locationGranted = true;
        _locationServiceEnabled = true;
        _locationStatus = 'Location access granted!';
        _navigateToLogin();
      } else if (status.isDenied) {
        _locationGranted = false;
        _locationStatus = 'Location access is needed for local farming information';
        _showLocationWarningDialog();
      } else if (status.isPermanentlyDenied) {
        _locationGranted = false;
        _locationStatus = 'Please enable location in app settings';
        _showSettingsDialog();
      }
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'Location permission has been permanently denied. '
            'Please enable it in settings to get personalized farming recommendations and local market prices.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin();
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() {
    if (mounted) {
      context.go(RouteName.login);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button at top right
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),

              // Onboarding Carousel
              Expanded(
                flex: 2,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingItems.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: _buildOnboardingPage(_onboardingItems[index]),
                    );
                  },
                ),
              ),

              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? Colors.green
                          : Colors.green.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Location Section
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location Icon and Title - FIXED ROW HERE
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: _locationGranted && _locationServiceEnabled
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(  // IMPORTANT: This Expanded prevents overflow
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location Required',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _locationStatus.isEmpty
                                          ? 'Enable location for best experience'
                                          : _locationStatus,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _locationGranted && _locationServiceEnabled
                                            ? Colors.green
                                            : Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Location Benefits
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (!_locationGranted || !_locationServiceEnabled)
                                    ? Colors.orange.shade200
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                _BenefitItem(
                                  icon: Icons.wb_sunny,
                                  text: 'Local weather forecasts',
                                ),
                                SizedBox(height: 6),
                                _BenefitItem(
                                  icon: Icons.attach_money,
                                  text: 'Market prices near you',
                                ),
                                SizedBox(height: 6),
                                _BenefitItem(
                                  icon: Icons.grass,
                                  text: 'Farming tips for your region',
                                ),
                                SizedBox(height: 6),
                                _BenefitItem(
                                  icon: Icons.people,
                                  text: 'Connect with local farmers',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Warning message if location not enabled
                          if (!_locationGranted || !_locationServiceEnabled)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      !_locationServiceEnabled
                                          ? 'Location services are disabled. Please enable GPS.'
                                          : 'Location permission not granted. Some features will be limited.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _navigateToLogin,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Skip for Now', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _checkLocationServiceBeforeProceed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Continue',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.agriculture, size: 60, color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imageUrl;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.color,
  });
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}