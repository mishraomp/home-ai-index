import 'package:flutter/material.dart';
import 'package:home_ai_index/data/services/api_quota_manager.dart';
import 'package:home_ai_index/presentation/viewmodels/settings_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/quota_warning_dialog.dart';
import 'package:provider/provider.dart';

/// Settings screen for managing API credentials.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _projectIdController = TextEditingController();
  bool _obscureApiKey = true;
  bool _hasLoadedCredentials = false;

  @override
  void initState() {
    super.initState();
    // Reset flag to ensure fresh load from database
    _hasLoadedCredentials = false;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _projectIdController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingCredentials(SettingsViewModel viewModel) async {
    if (_hasLoadedCredentials) return;

    // Always reload fresh from database
    final credentials = await viewModel.loadStoredCredentials();
    if (mounted) {
      setState(() {
        _apiKeyController.text = credentials['apiKey'] ?? '';
        _projectIdController.text = credentials['projectId'] ?? '';
        _hasLoadedCredentials = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(
        quotaManager: Provider.of<APIQuotaManager>(context, listen: false),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, child) {
            // Load existing credentials when screen builds
            _loadExistingCredentials(viewModel);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Text(
                      'Google Cloud Vision API',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your API credentials to enable image recognition with Google Cloud Vision.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Status indicator
                    if (viewModel.hasCredentials)
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'API credentials configured',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'No API credentials configured. Image recognition will use offline mode only.',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Quota Status Banner (if quota manager available)
                    /* if (viewModel.quotaStatus != null) ...[
                      QuotaStatusBanner(status: viewModel.quotaStatus!),
                      const SizedBox(height: 24),
                    ], */

                    // API Key field
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'API Key *',
                        hintText: 'Enter your Google Cloud Vision API key',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureApiKey
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureApiKey = !_obscureApiKey;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureApiKey,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an API key';
                        }
                        if (value.length < 20) {
                          return 'API key appears to be too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Project ID field (optional)
                    TextFormField(
                      controller: _projectIdController,
                      decoration: const InputDecoration(
                        labelText: 'Project ID (Optional)',
                        hintText: 'Enter your Google Cloud project ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Project ID is optional but recommended for better tracking',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (viewModel.errorMessage != null)
                      Card(
                        color: Colors.red[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(color: Colors.red[900]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Success message
                    if (viewModel.successMessage != null)
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.successMessage!,
                                  style: TextStyle(color: Colors.green[900]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (viewModel.errorMessage != null ||
                        viewModel.successMessage != null)
                      const SizedBox(height: 16),

                    // Save button
                    ElevatedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await viewModel.saveCredentials(
                                  apiKey: _apiKeyController.text,
                                  projectId: _projectIdController.text.isEmpty
                                      ? null
                                      : _projectIdController.text,
                                );
                              }
                            },
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        viewModel.isLoading ? 'Saving...' : 'Save Credentials',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    // Clear credentials button (if credentials exist)
                    if (viewModel.hasCredentials) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Clear Credentials?'),
                                    content: const Text(
                                      'Are you sure you want to clear your API credentials? '
                                      'You will need to re-enter them to use Cloud Vision.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Clear'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await viewModel.clearCredentials();
                                  _apiKeyController.clear();
                                  _projectIdController.clear();
                                }
                              },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear Credentials'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // API Usage Monitoring section
                    if (viewModel.hasCredentials) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'API Usage Monitoring',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Track your Google Cloud Vision API usage to monitor costs',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      _buildUsageCard(
                        icon: Icons.api,
                        title: 'API Calls This Month',
                        value: '${viewModel.quotaStatus?.currentUsage ?? 0}',
                        subtitle:
                            'of ${viewModel.quotaStatus?.freeLimit ?? 1000} free calls',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),

                      _buildUsageCard(
                        icon: Icons.info_outline,
                        title: 'Remaining Free Calls',
                        value:
                            '${viewModel.quotaStatus?.remainingFreeUnits ?? 0}',
                        subtitle: 'Resets monthly',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),

                      _buildUsageCard(
                        icon: Icons.attach_money,
                        title: 'Estimated Monthly Cost',
                        value:
                            '\$${viewModel.quotaStatus?.estimatedMonthlyCost.toStringAsFixed(2) ?? "0.00"}',
                        subtitle: 'Based on \$1.50 per 1,000 requests',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to detailed usage statistics page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Detailed usage statistics coming soon',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics_outlined),
                        label: const Text('View Detailed Statistics'),
                      ),

                      const SizedBox(height: 32),
                    ],

                    // Help section
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'How to get an API key',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildHelpStep(
                      1,
                      'Go to Google Cloud Console',
                      'console.cloud.google.com',
                    ),
                    _buildHelpStep(
                      2,
                      'Create or select a project',
                      'Enable billing for the project',
                    ),
                    _buildHelpStep(
                      3,
                      'Enable Cloud Vision API',
                      'APIs & Services > Enable APIs',
                    ),
                    _buildHelpStep(
                      4,
                      'Create API key',
                      'Credentials > Create Credentials > API key',
                    ),
                    _buildHelpStep(
                      5,
                      'Secure your key',
                      'Add application restrictions and API restrictions',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHelpStep(int step, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            child: Text('$step', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
