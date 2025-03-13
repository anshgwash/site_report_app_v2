import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_tab.dart';
import 'images_tab.dart';
import 'pdf_service.dart';
import 'providers/form_provider.dart';

void main() {
  runApp(
    // Wrap the entire app with ProviderScope to enable Riverpod
    const ProviderScope(child: SiteReportApp()),
  );
}

class SiteReportApp extends StatelessWidget {
  const SiteReportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Site Report App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
    // Access the form data through Riverpod
    final formData = ref.watch(formStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TF Site Report'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Form'),
            Tab(icon: Icon(Icons.image), text: 'Images'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating PDF...')),
              );

              try {
                // Generate and share PDF using the form data from Riverpod
                final pdfService = PdfService();
                await pdfService.generateSiteReportPdf(formData);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF generated successfully!')),
                );
              } catch (e) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error generating PDF: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [FormTab(formKey: formKey), ImagesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Form data saved')));
            }
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
