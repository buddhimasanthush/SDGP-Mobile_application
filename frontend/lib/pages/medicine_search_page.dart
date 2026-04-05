import 'package:flutter/material.dart';
import 'package:medifind_app/pages/cart_page.dart';

class MedicineSearchPage extends StatefulWidget {
  final String initialQuery;
  const MedicineSearchPage({super.key, this.initialQuery = ''});

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _allMedicines = [
    {
      'name': 'Panadol 500mg',
      'category': 'Pain Relief',
      'price': 150.0,
      'image': '💊',
      'description': 'For relief of pain and fever.',
    },
    {
      'name': 'Amoxicillin 250mg',
      'category': 'Antibiotics',
      'price': 450.0,
      'image': '💊',
      'description': 'Used to treat various bacterial infections.',
    },
    {
      'name': 'Cetirizine 10mg',
      'category': 'Allergy',
      'price': 120.0,
      'image': '💊',
      'description': 'Effective for hay fever and allergy symptoms.',
    },
    {
      'name': 'Metformin 500mg',
      'category': 'Diabetes',
      'price': 300.0,
      'image': '💊',
      'description': 'Used to control blood sugar levels.',
    },
    {
      'name': 'Atorvastatin 20mg',
      'category': 'Cholesterol',
      'price': 800.0,
      'image': '💊',
      'description': 'Used to lower cholesterol.',
    },
  ];

  List<Map<String, dynamic>> _filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _filterMedicines(widget.initialQuery);
  }

  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = _allMedicines;
      } else {
        _filteredMedicines = _allMedicines
            .where((m) =>
                m['name'].toLowerCase().contains(query.toLowerCase()) ||
                m['category'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFF0796DE),
        foregroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _filterMedicines,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartPage())),
          ),
        ],
      ),
      body: _filteredMedicines.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text(
                    'No medicines found',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Color(0xFF919191),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredMedicines.length,
              itemBuilder: (context, index) {
                final med = _filteredMedicines[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0796DE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            med['image'],
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med['name'],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              med['category'],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color(0xFF0796DE),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Rs. ${med['price'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${med['name']} added to cart')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002082),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(60, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Add', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
