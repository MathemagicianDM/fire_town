import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/town_extension/town_locations.dart';
import '../models/person_model.dart';
import '../models/location_role_model.dart';
import '../enums_and_maps.dart';

class PDFExportService {
  static const double _margin = 40;
  static const double _cardWidth = 250;
  static const double _cardHeight = 180;
  
  /// Export a single shop to PDF
  static Future<bool> exportShopToPDF({
    required Shop shop,
    required List<Person> allPeople,
    required List<LocationRole> allRoles,
    String? filename,
  }) async {
    final pdf = pw.Document();
    
    // Get staff for this shop
    final staffData = _getShopStaff(shop, allPeople, allRoles);
    
    // Generate pages for this shop
    await _addShopPages(pdf, shop, staffData);
    
    // Save PDF with file picker
    final bytes = await pdf.save();
    final cleanShopName = shop.name.replaceAll(RegExp(r'[^\w\s-]'), '');
    final defaultFileName = filename ?? '${cleanShopName}_shop_export.pdf';
    
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Shop PDF',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsBytes(bytes);
      return true;
    }
    return false;
  }
  
  /// Export a single location (government/market) to PDF
  static Future<bool> exportLocationToPDF({
    required Informational location,
    required List<Person> allPeople,
    required List<LocationRole> allRoles,
    String? filename,
  }) async {
    final pdf = pw.Document();
    
    // Get staff for this location
    final staffData = _getLocationStaff(location, allPeople, allRoles);
    
    // Generate pages for this location
    await _addLocationPages(pdf, location, staffData);
    
    // Save PDF with file picker
    final bytes = await pdf.save();
    final cleanLocationName = location.name.replaceAll(RegExp(r'[^\w\s-]'), '');
    final defaultFileName = filename ?? '${cleanLocationName}_export.pdf';
    
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save ${location.name} PDF',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsBytes(bytes);
      return true;
    }
    return false;
  }

  /// Export all locations (shops, government, market) in town to PDF
  static Future<bool> exportAllLocationsToPDF({
    required List<Location> locations,
    required List<Person> allPeople,
    required List<LocationRole> allRoles,
    String? filename,
  }) async {
    final pdf = pw.Document();
    
    // Filter locations to only shops, government, and market
    final exportableLocations = locations.where((loc) => 
      loc.locType == LocationType.shop ||
      loc.locType == LocationType.government ||
      loc.locType == LocationType.market
    ).toList();
    
    if (exportableLocations.isEmpty) return false;
    
    // Sort locations: government first, then shops, then market last
    exportableLocations.sort((a, b) {
      if (a.locType == LocationType.government && b.locType != LocationType.government) return -1;
      if (a.locType != LocationType.government && b.locType == LocationType.government) return 1;
      if (a.locType == LocationType.market && b.locType != LocationType.market) return 1;
      if (a.locType != LocationType.market && b.locType == LocationType.market) return -1;
      return a.name.compareTo(b.name); // Alphabetical within same type
    });
    
    // Calculate page numbers for each location first
    final Map<int, int> locationPageNumbers = {};
    int currentPage = 2; // Start after TOC (page 1)
    
    for (int i = 0; i < exportableLocations.length; i++) {
      locationPageNumbers[i] = currentPage;
      final staffData = exportableLocations[i] is Shop 
        ? _getShopStaff(exportableLocations[i] as Shop, allPeople, allRoles)
        : _getLocationStaff(exportableLocations[i] as Informational, allPeople, allRoles);
      
      // Each location gets 1 page for details + pages for staff (4 staff per page)
      int locationPages = 1; // Details page
      if (staffData.isNotEmpty) {
        final totalStaff = staffData.values.expand((list) => list).length;
        final staffPages = (totalStaff / 4).ceil(); // 4 staff cards per page
        locationPages += staffPages;
      }
      
      currentPage += locationPages;
    }
    
    // Add table of contents with correct page numbers
    await _addAllLocationsTableOfContents(pdf, exportableLocations, locationPageNumbers);
    
    // Add each location
    for (int i = 0; i < exportableLocations.length; i++) {
      final location = exportableLocations[i];
      if (location is Shop) {
        final staffData = _getShopStaff(location, allPeople, allRoles);
        await _addShopPages(pdf, location, staffData);
      } else if (location is Informational) {
        final staffData = _getLocationStaff(location, allPeople, allRoles);
        await _addLocationPages(pdf, location, staffData);
      }
    }
    
    // Save PDF with file picker
    final bytes = await pdf.save();
    final defaultFileName = filename ?? 'town_locations_export.pdf';
    
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Town Locations PDF',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsBytes(bytes);
      return true;
    }
    return false;
  }

  /// Get organized staff data for a shop
  static Map<Role, List<Person>> _getShopStaff(Shop shop, List<Person> allPeople, List<LocationRole> allRoles) {
    final Map<Role, List<Person>> staffByRole = {};
    
    // Get all roles for this shop
    final shopRoles = allRoles.where((role) => role.locationID == shop.id).toList();
    
    // Group by role
    for (final role in shopRoles) {
      final person = allPeople.firstWhere(
        (p) => p.id == role.myID,
        orElse: () => throw Exception('Person not found for role'),
      );
      
      if (!staffByRole.containsKey(role.myRole)) {
        staffByRole[role.myRole] = [];
      }
      staffByRole[role.myRole]!.add(person);
    }
    
    return staffByRole;
  }

  /// Get organized staff data for a location (government/market)
  static Map<Role, List<Person>> _getLocationStaff(Informational location, List<Person> allPeople, List<LocationRole> allRoles) {
    final Map<Role, List<Person>> staffByRole = {};
    
    // Get all roles for this location
    final locationRoles = allRoles.where((role) => role.locationID == location.id).toList();
    
    // Group by role
    for (final role in locationRoles) {
      final person = allPeople.firstWhere(
        (p) => p.id == role.myID,
        orElse: () => throw Exception('Person not found for role'),
      );
      
      if (!staffByRole.containsKey(role.myRole)) {
        staffByRole[role.myRole] = [];
      }
      staffByRole[role.myRole]!.add(person);
    }
    
    return staffByRole;
  }
  
  /// Add table of contents for all locations export
  static Future<void> _addAllLocationsTableOfContents(pw.Document pdf, List<Location> locations, Map<int, int> locationPageNumbers) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(_margin),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Text(
                      'Town Locations Directory',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Table of Contents',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 15),
                  ...locations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final location = entry.value;
                    final pageNumber = locationPageNumbers[index] ?? (index + 2);
                    final typeString = location is Shop 
                      ? _shopTypeToString(location.type)
                      : _locationTypeToString(location.locType);
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Link(
                        destination: '${location.id}',
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                '${index + 1}. ${location.name} ($typeString)',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.blue700,
                                  decoration: pw.TextDecoration.underline,
                                ),
                              ),
                            ),
                            pw.Text(
                              'Page $pageNumber',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.blue700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            _buildPageFooter(context),
          ],
        ),
      ),
    );
  }

  
  /// Add pages for a single location (government/market)
  static Future<void> _addLocationPages(pw.Document pdf, Informational location, Map<Role, List<Person>> staffData) async {
    // Location header page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(_margin),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Anchor(name: '${location.id}'),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildLocationHeader(location),
                  pw.SizedBox(height: 20),
                  _buildLocationDescription(location),
                ],
              ),
            ),
            _buildPageFooter(context),
          ],
        ),
      ),
    );
    
    // Staff pages
    if (staffData.isNotEmpty) {
      await _addLocationStaffPages(pdf, location, staffData);
    }
  }

  /// Add pages for a single shop
  static Future<void> _addShopPages(pw.Document pdf, Shop shop, Map<Role, List<Person>> staffData) async {
    // Shop header page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(_margin),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Anchor(name: '${shop.id}'),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildShopHeader(shop),
                  pw.SizedBox(height: 20),
                  _buildShopDescriptions(shop),
                  pw.SizedBox(height: 20),
                  _buildServicesSection(shop),
                ],
              ),
            ),
            _buildPageFooter(context),
          ],
        ),
      ),
    );
    
    // Staff pages
    if (staffData.isNotEmpty) {
      await _addStaffPages(pdf, shop, staffData);
    }
  }
  
  /// Build shop header section
  static pw.Widget _buildShopHeader(Shop shop) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            shop.name,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _shopTypeToString(shop.type),
            style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            shop.blurbText,
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  /// Build shop descriptions (inside/outside traits)
  static pw.Widget _buildShopDescriptions(Shop shop) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Outside description
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Outside Description',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...shop.outsideTraits.map((trait) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• ${trait.description}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                )).toList(),
                if (shop.outsideTraits.isEmpty)
                  pw.Text(
                    'No outside traits available',
                    style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        // Inside description
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Inside Description',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...shop.insideTraits.map((trait) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• ${trait.description}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                )).toList(),
                if (shop.insideTraits.isEmpty)
                  pw.Text(
                    'No inside traits available',
                    style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build services section
  static pw.Widget _buildServicesSection(Shop shop) {
    if (shop.services.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey600),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Services & Goods',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'No services listed',
              style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      );
    }
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Services & Goods',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
              ...shop.services.map((service) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(service.description, style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(service.price.toString(), style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(service.quantity.toString(), style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Add staff pages with NPC cards
  static Future<void> _addStaffPages(pw.Document pdf, Shop shop, Map<Role, List<Person>> staffData) async {
    final allStaff = <Person>[];
    final roleLabels = <String>[];
    
    // Flatten staff data for layout
    for (final entry in staffData.entries) {
      final role = entry.key;
      final people = entry.value;
      
      for (int i = 0; i < people.length; i++) {
        allStaff.add(people[i]);
        roleLabels.add(_roleToString(role)); // Label all people with their role
      }
    }
    
    // Create pages with 2 cards per row
    for (int i = 0; i < allStaff.length; i += 4) { // 4 cards per page (2 rows of 2)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(_margin),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Page header
                    pw.Text(
                      '${shop.name} - Staff',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    
                    // First row (2 cards)
                    if (i < allStaff.length)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNPCCard(allStaff[i], roleLabels[i]),
                          if (i + 1 < allStaff.length)
                            _buildNPCCard(allStaff[i + 1], roleLabels[i + 1])
                          else
                            pw.SizedBox(width: _cardWidth),
                        ],
                      ),
                    
                    pw.SizedBox(height: 20),
                    
                    // Second row (2 cards)
                    if (i + 2 < allStaff.length)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNPCCard(allStaff[i + 2], roleLabels[i + 2]),
                          if (i + 3 < allStaff.length)
                            _buildNPCCard(allStaff[i + 3], roleLabels[i + 3])
                          else
                            pw.SizedBox(width: _cardWidth),
                        ],
                      ),
                  ],
                ),
              ),
              _buildPageFooter(context),
            ],
          ),
        ),
      );
    }
  }
  
  /// Build individual NPC card
  static pw.Widget _buildNPCCard(Person person, String roleLabel) {
    return pw.Container(
      width: _cardWidth,
      height: _cardHeight,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Role label (if provided)
          if (roleLabel.isNotEmpty) ...[
            pw.Text(
              roleLabel,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
            ),
            pw.SizedBox(height: 4),
          ],
          
          // Name
          pw.Text(
            '${person.firstName} ${person.surname}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          
          // Basic info
          pw.Text(
            '${person.ancestry}, ${_ageToString(person.age)}, ${_pronounsToString(person.pronouns)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          
          pw.SizedBox(height: 8),
          
          // Personality
          pw.Text(
            'Personality:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '• ${person.quirk1}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            '• ${person.quirk2}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          
          pw.SizedBox(height: 6),
          
          // Physical traits
          if (person.physicalTraits.isNotEmpty) ...[
            pw.Text(
              'Appearance:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            ...person.physicalTraits.take(2).map((trait) => pw.Text(
              '• ${trait.description}',
              style: const pw.TextStyle(fontSize: 9),
            )).toList(),
          ],
          
          // Clothing traits
          if (person.clothingTraits.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Clothing:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            ...person.clothingTraits.take(1).map((trait) => pw.Text(
              '• ${trait.description}',
              style: const pw.TextStyle(fontSize: 9),
            )).toList(),
          ],
        ],
      ),
    );
  }
  
  /// Build location header section
  static pw.Widget _buildLocationHeader(Informational location) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            location.name,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _locationTypeToString(location.locType),
            style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// Build location description section
  static pw.Widget _buildLocationDescription(Informational location) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Location Details',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'This is the ${location.name.toLowerCase()} location where residents can access various services and interact with government officials or market vendors.',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Add staff pages for location with NPC cards
  static Future<void> _addLocationStaffPages(pw.Document pdf, Informational location, Map<Role, List<Person>> staffData) async {
    final allStaff = <Person>[];
    final roleLabels = <String>[];
    
    // Flatten staff data for layout
    for (final entry in staffData.entries) {
      final role = entry.key;
      final people = entry.value;
      
      for (int i = 0; i < people.length; i++) {
        allStaff.add(people[i]);
        roleLabels.add(_roleToString(role)); // Label all people with their role
      }
    }
    
    // Create pages with 2 cards per row
    for (int i = 0; i < allStaff.length; i += 4) { // 4 cards per page (2 rows of 2)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(_margin),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Page header
                    pw.Text(
                      '${location.name} - Staff',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    
                    // First row (2 cards)
                    if (i < allStaff.length)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNPCCard(allStaff[i], roleLabels[i]),
                          if (i + 1 < allStaff.length)
                            _buildNPCCard(allStaff[i + 1], roleLabels[i + 1])
                          else
                            pw.SizedBox(width: _cardWidth),
                        ],
                      ),
                    
                    pw.SizedBox(height: 20),
                    
                    // Second row (2 cards)
                    if (i + 2 < allStaff.length)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNPCCard(allStaff[i + 2], roleLabels[i + 2]),
                          if (i + 3 < allStaff.length)
                            _buildNPCCard(allStaff[i + 3], roleLabels[i + 3])
                          else
                            pw.SizedBox(width: _cardWidth),
                        ],
                      ),
                  ],
                ),
              ),
              _buildPageFooter(context),
            ],
          ),
        ),
      );
    }
  }

  /// Helper method to convert location type to string
  static String _locationTypeToString(LocationType type) {
    switch (type) {
      case LocationType.government:
        return 'Government';
      case LocationType.market:
        return 'Market';
      case LocationType.shop:
        return 'Shop';
      case LocationType.temple:
        return 'Temple';
      case LocationType.civic:
        return 'Civic Building';
      case LocationType.info:
        return 'Information Center';
      case LocationType.hireling:
        return 'Hireling Hall';
      default:
        return type.toString().split('.').last.toUpperCase();
    }
  }

  /// Helper method to convert shop type to string
  static String _shopTypeToString(ShopType type) {
    switch (type) {
      case ShopType.tavern:
        return 'Tavern';
      case ShopType.herbalist:
        return 'Herbalist';
      case ShopType.temple:
        return 'Temple';
      case ShopType.smith:
        return 'Smithy';
      case ShopType.generalStore:
        return 'General Store';
      case ShopType.jeweler:
        return 'Jeweler';
      case ShopType.clothier:
        return 'Clothier';
      case ShopType.magic:
        return 'Magic Shop';
    }
  }
  
  /// Helper method to convert role to string
  static String _roleToString(Role role) {
    switch (role) {
      case Role.owner:
        return 'Owner';
      case Role.waitstaff:
        return 'Waitstaff';
      case Role.cook:
        return 'Cook';
      case Role.entertainment:
        return 'Entertainment';
      case Role.tavernKeeper:
        return 'Tavern Keeper';
      case Role.apprentice:
        return 'Apprentice';
      case Role.journeyman:
        return 'Journeyman';
      // Government roles
      case Role.liegeGovernment:
        return 'Liege';
      case Role.nobleGovernment:
        return 'Noble';
      case Role.government:
        return 'Government Official';
      case Role.minorNoble:
        return 'Minor Noble';
      case Role.townGuard:
        return 'Town Guard';
      case Role.guardCaptainGovernment:
        return 'Guard Captain';
      case Role.guardViceCaptainGovernment:
        return 'Guard Vice Captain';
      case Role.guardWarrantGovernment:
        return 'Guard Warrant';
      case Role.guardConstableGovernment:
        return 'Guard Constable';
      case Role.merchantCouncellorGovernment:
        return 'Merchant Councillor';
      case Role.presidentGovernment:
        return 'President';
      case Role.luminaryGovernment:
        return 'Luminary';
      case Role.hierophantRulerGovernment:
        return 'Hierophant Ruler';
      case Role.elderGovernment:
        return 'Elder';
      case Role.courier:
        return 'Courier';
      case Role.festivalMinisterGovernmentUniversal:
        return 'Festival Minister';
      case Role.spyMinisterGovernmentUniversal:
        return 'Spy Minister';
      case Role.guildMinisterGovernmentUniversal:
        return 'Guild Minister';
      case Role.diplomatMinisterGovernmentUniversal:
        return 'Diplomat Minister';
      case Role.magicMinisterGovernmentUniversal:
        return 'Magic Minister';
      case Role.warMinisterGovernmentUniversal:
        return 'War Minister';
      case Role.infrastructureMinisterGovernmentUniversal:
        return 'Infrastructure Minister';
      case Role.justiceMinisterGovernmentUniversal:
        return 'Justice Minister';
      case Role.mintMinisterGovernmentUniversal:
        return 'Mint Minister';
      case Role.stewardGovernmentUniversal:
        return 'Steward';
      case Role.scribe:
        return 'Scribe';
      default:
        // For any unknown roles, format nicely by removing "Role." and capitalizing
        String roleStr = role.toString().split('.').last;
        
        // Remove common suffixes that are redundant
        if (roleStr.endsWith('Government')) {
          roleStr = roleStr.substring(0, roleStr.length - 'Government'.length);
        }
        if (roleStr.endsWith('GovernmentUniversal')) {
          roleStr = roleStr.substring(0, roleStr.length - 'GovernmentUniversal'.length);
        }
        
        // Convert camelCase to Title Case
        return roleStr.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim().split(' ').map((word) => 
          word[0].toUpperCase() + word.substring(1).toLowerCase()
        ).join(' ');
    }
  }
  
  /// Helper method to convert age to string
  static String _ageToString(AgeType age) {
    switch (age) {
      case AgeType.quiteYoung:
        return 'Very Young';
      case AgeType.young:
        return 'Young';
      case AgeType.adult:
        return 'Adult';
      case AgeType.middleAge:
        return 'Middle-aged';
      case AgeType.old:
        return 'Elderly';
      case AgeType.quiteOld:
        return 'Very Elderly';
    }
  }
  
  /// Build page footer with page number
  static pw.Widget _buildPageFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Page ${context.pageNumber}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  /// Helper method to convert pronouns to string
  static String _pronounsToString(PronounType pronouns) {
    switch (pronouns) {
      case PronounType.heHim:
        return 'he/him';
      case PronounType.sheHer:
        return 'she/her';
      case PronounType.theyThem:
        return 'they/them';
      case PronounType.heThey:
        return 'he/they';
      case PronounType.sheThey:
        return 'she/they';
      case PronounType.any:
        return 'any';
    }
  }
}