import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/providers/settings_provider.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/notification_service.dart';

/// Onboarding screen for first-time users
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  bool _isLoading = false;
  String? _locationName;

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final locationService = LocationService();
      final result = await locationService.getCurrentLocation();
      
      if (result.isSuccess && result.latitude != null && result.longitude != null) {
        await ref.read(settingsProvider.notifier).updateSettings(
          latitude: result.latitude,
          longitude: result.longitude,
          locationName: result.locationName,
        );
        
        setState(() {
          _locationName = result.locationName;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not detect location: $e')),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _enableNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      final granted = await notificationService.requestPermissions();
      
      if (granted) {
        await ref.read(settingsProvider.notifier).updateSettings(
          notificationsEnabled: true,
        );
      }
    } catch (e) {
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsProvider.notifier).updateSettings(
      isOnboardingComplete: true,
    );
    
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: _buildCurrentPage(),
              ),
              _buildPageIndicator(),
              const SizedBox(height: 16),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _buildWelcomePage();
      case 1:
        return _buildLocationPage();
      case 2:
        return _buildNotificationPage();
      default:
        return _buildWelcomePage();
    }
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mosque,
            size: 64,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Bismillah',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Islamic Todo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Text(
          'Track your prayers, manage your tasks, and build consistency in your daily worship.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray600,
              ),
        ),
      ],
    );
  }

  Widget _buildLocationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.location_on,
            size: 64,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Set Your Location',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your location is needed to calculate accurate prayer times.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray600,
              ),
        ),
        const SizedBox(height: 32),
        if (_locationName != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  _locationName!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _detectLocation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLoading ? 'Detecting...' : 'Detect Location'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: _nextPage,
          child: const Text('Skip for now'),
        ),
      ],
    );
  }

  Widget _buildNotificationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.notifications_active,
            size: 64,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Prayer Reminders',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Never miss a prayer. Get notified before each prayer time.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray600,
              ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _enableNotifications,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.notifications),
            label: Text(_isLoading ? 'Enabling...' : 'Enable Notifications'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          child: const Text('Maybe later'),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.black : AppColors.gray300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButtons() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: _currentPage > 0
                ? TextButton(
                    onPressed: _previousPage,
                    child: const Text('Back'),
                  )
                : null,
          ),
          const Spacer(),
          SizedBox(
            width: 120,
            child: _currentPage < 2
                ? ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('Next'),
                  )
                : ElevatedButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Get Started'),
                  ),
          ),
        ],
      ),
    );
  }
}
