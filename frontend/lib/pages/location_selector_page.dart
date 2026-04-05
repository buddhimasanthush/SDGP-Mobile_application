import 'package:flutter/material.dart';

class LocationSelectorPage extends StatefulWidget {
  const LocationSelectorPage({super.key});

  @override
  State<LocationSelectorPage> createState() => _LocationSelectorPageState();
}

class _LocationSelectorPageState extends State<LocationSelectorPage> {
  final List<Map<String, String>> locations = [
    {'name': 'My Home', 'address': '123 Main Street, City'},
    {'name': 'Office', 'address': '456 Business Avenue, Downtown'},
    {'name': 'Parents House', 'address': '789 Family Lane, Suburb'},
  ];

  String? selectedLocation = 'My Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Delivery Location',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0796DE),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return _LocationItem(
                  name: location['name']!,
                  address: location['address']!,
                  isSelected: selectedLocation == location['name'],
                  onTap: () {
                    setState(() {
                      selectedLocation = location['name'];
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedLocation);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0796DE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String name;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationItem({
    required this.name,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF4F4F4),
          border: Border.all(
            width: 2,
            color: isSelected
                ? const Color(0xFF0796DE)
                : const Color(0xFFEFEFEF),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected
                  ? const Color(0xFF0796DE)
                  : const Color(0xFF919191),
              size: 32,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: const Color(0xFF1E1E1E),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Color(0xFF919191),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0796DE),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
