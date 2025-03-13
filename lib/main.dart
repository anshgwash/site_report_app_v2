import 'package:flutter/material.dart';
import 'form_tab.dart';
import 'images_tab.dart';
import 'pdf_service.dart';

void main() {
  runApp(const SiteReportApp());
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formKey = GlobalKey<FormState>();

  // Create a model to hold all form data
  Map<String, dynamic> formData = {};

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
                // Generate and share PDF
                final pdfService = PdfService();
                await pdfService.generateSiteReportPdf(formData);
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
        children: [
          FormTab(
            formKey: formKey,
            formData: formData,
            onFormDataChanged: (newData) {
              setState(() {
                formData = newData;
              });
            },
          ),
          ImagesTab(
            formData: formData,
            onImagesChanged: (newData) {
              setState(() {
                formData = newData;
              });
            },
          ),
        ],
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
