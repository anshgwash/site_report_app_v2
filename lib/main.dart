import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_tab.dart';
import 'images_tab.dart';
import 'pdf_service.dart';
import 'providers/form_provider.dart';

void main() {
  runApp(const ProviderScope(child: SiteReportApp()));
}

class SiteReportApp extends StatelessWidget {
  const SiteReportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Site Report App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TF Site Report'),
        toolbarHeight: 25,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Form'),
            Tab(icon: Icon(Icons.image), text: 'Images'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [FormTab(formKey: formKey), ImagesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'save') {
              if (_tabController.index == 0) {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form data saved')),
                  );
                }
              }
            } else if (value == 'generate_pdf') {
              // Ensure formData is not null before using it
              if (formData == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form data is not loaded yet.')),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating PDF...')),
              );
              try {
                final pdfService = PdfService();
                await pdfService.generateSiteReportPdf(formData);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF generated successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error generating PDF: $e')),
                );
              }
            } else if (value == 'clear_form') {
              // Show confirmation dialog
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Form'),
                    content: const Text(
                      'Are you sure you want to clear all form data? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              );

              if (shouldClear == true) {
                ref.read(formStateProvider.notifier).clearForm();
                ref.read(formVersionProvider.notifier).increment();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form data cleared')),
                );
              }
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'save',
                  child: ListTile(
                    leading: Icon(Icons.save),
                    title: Text('Save Form'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'generate_pdf',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('Generate PDF'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_form',
                  child: ListTile(
                    leading: Icon(Icons.clear_all, color: Colors.red),
                    title: Text(
                      'Clear Form',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
