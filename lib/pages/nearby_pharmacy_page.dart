import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'payment_gateway_page.dart';

// ── Custom blue/white map style ───────────────────────────────────────────────
const _mapStyle = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#daeeff" }] },
  { "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#1a6fa8" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#ffffff" }] },
  { "featureType": "administrative", "elementType": "geometry", "stylers": [{ "visibility": "off" }] },
  { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{ "color": "#0796DE" }] },
  { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
  { "featureType": "poi.park", "elementType": "geometry", "stylers": [{ "color": "#b8e4c8" }] },
  { "featureType": "road", "elementType": "geometry", "stylers": [{ "color": "#ffffff" }] },
  { "featureType": "road", "elementType": "geometry.stroke", "stylers": [{ "color": "#c8e6f7" }] },
  { "featureType": "road", "elementType": "labels", "stylers": [{ "visibility": "off" }] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "color": "#b0d8f0" }] },
  { "featureType": "road.local", "stylers": [{ "visibility": "simplified" }] },
  { "featureType": "transit", "stylers": [{ "visibility": "off" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#0796DE" }] },
  { "featureType": "water", "elementType": "labels.text.fill", "stylers": [{ "color": "#ffffff" }] }
]
''';

// ── Pharmacy data ─────────────────────────────────────────────────────────────
class _Pharmacy {
  final String name;
  final String location;
  final String distance;
  final double price;
  final int available;
  final int total;
  final String notAvailable;
  final int accepted;
  final int cancelled;
  final double rating;
  final Color brandColor;
  final LatLng latLng;

  const _Pharmacy({
    required this.name,
    required this.location,
    required this.distance,
    required this.price,
    required this.available,
    required this.total,
    required this.notAvailable,
    required this.accepted,
    required this.cancelled,
    required this.rating,
    required this.brandColor,
    required this.latLng,
  });
}

const _pharmacies1km = [
  _Pharmacy(
      name: 'Union Chemists',
      location: 'Narahenpita',
      distance: '1km ahead',
      price: 4600,
      available: 4,
      total: 6,
      notAvailable: 'Lactaid, Simethicone',
      accepted: 56,
      cancelled: 4,
      rating: 4.8,
      brandColor: Color(0xFFD4A017),
      latLng: LatLng(6.8980, 79.8780)),
];
const _pharmacies5km = [
  _Pharmacy(
      name: 'Union Chemists',
      location: 'Narahenpita',
      distance: '1km ahead',
      price: 4600,
      available: 4,
      total: 6,
      notAvailable: 'Lactaid, Simethicone',
      accepted: 56,
      cancelled: 4,
      rating: 4.8,
      brandColor: Color(0xFFD4A017),
      latLng: LatLng(6.8980, 79.8780)),
  _Pharmacy(
      name: 'Healthguard',
      location: 'Colombo 5',
      distance: '1.5km ahead',
      price: 5200,
      available: 5,
      total: 6,
      notAvailable: 'Simethicone',
      accepted: 72,
      cancelled: 2,
      rating: 4.6,
      brandColor: Color(0xFF9B2AA0),
      latLng: LatLng(6.9050, 79.8820)),
  _Pharmacy(
      name: 'Osusala Pharmacy',
      location: 'Borella',
      distance: '3.2km ahead',
      price: 4350,
      available: 5,
      total: 6,
      notAvailable: 'Lactaid',
      accepted: 68,
      cancelled: 3,
      rating: 4.5,
      brandColor: Color(0xFF1565C0),
      latLng: LatLng(6.9180, 79.8760)),
];
const _pharmacies10km = [
  _Pharmacy(
      name: 'Union Chemists',
      location: 'Narahenpita',
      distance: '1km ahead',
      price: 4600,
      available: 4,
      total: 6,
      notAvailable: 'Lactaid, Simethicone',
      accepted: 56,
      cancelled: 4,
      rating: 4.8,
      brandColor: Color(0xFFD4A017),
      latLng: LatLng(6.8980, 79.8780)),
  _Pharmacy(
      name: 'Healthguard',
      location: 'Colombo 5',
      distance: '1.5km ahead',
      price: 5200,
      available: 5,
      total: 6,
      notAvailable: 'Simethicone',
      accepted: 72,
      cancelled: 2,
      rating: 4.6,
      brandColor: Color(0xFF9B2AA0),
      latLng: LatLng(6.9050, 79.8820)),
  _Pharmacy(
      name: 'Osusala Pharmacy',
      location: 'Borella',
      distance: '3.2km ahead',
      price: 4350,
      available: 5,
      total: 6,
      notAvailable: 'Lactaid',
      accepted: 68,
      cancelled: 3,
      rating: 4.5,
      brandColor: Color(0xFF1565C0),
      latLng: LatLng(6.9180, 79.8760)),
  _Pharmacy(
      name: 'Health Link',
      location: 'Maradana',
      distance: '4.5km ahead',
      price: 4900,
      available: 3,
      total: 6,
      notAvailable: 'Lactaid',
      accepted: 61,
      cancelled: 5,
      rating: 4.3,
      brandColor: Color(0xFF00897B),
      latLng: LatLng(6.9280, 79.8700)),
  _Pharmacy(
      name: 'Jeewaka Pharma',
      location: 'Wellawatte',
      distance: '5.8km ahead',
      price: 5100,
      available: 6,
      total: 6,
      notAvailable: '',
      accepted: 80,
      cancelled: 1,
      rating: 4.9,
      brandColor: Color(0xFFE53935),
      latLng: LatLng(6.8820, 79.8680)),
  _Pharmacy(
      name: 'Suncity Pharmacy',
      location: 'Dehiwala',
      distance: '7.1km ahead',
      price: 4750,
      available: 4,
      total: 6,
      notAvailable: 'Simethicone',
      accepted: 65,
      cancelled: 3,
      rating: 4.4,
      brandColor: Color(0xFFF57C00),
      latLng: LatLng(6.8600, 79.8700)),
  _Pharmacy(
      name: 'Ceylinco Medicare',
      location: 'Nugegoda',
      distance: '9.3km ahead',
      price: 5400,
      available: 5,
      total: 6,
      notAvailable: 'Lactaid',
      accepted: 74,
      cancelled: 2,
      rating: 4.7,
      brandColor: Color(0xFF6A1B9A),
      latLng: LatLng(6.8740, 79.9000)),
];

// Saved delivery addresses
const _savedAddresses = [
  {
    'label': 'My Home',
    'icon': Icons.home_rounded,
    'address': 'No. 12, Wijerama Rd, Nugegoda'
  },
  {
    'label': 'Office',
    'icon': Icons.business_rounded,
    'address': 'Level 4, BOC Tower, Colombo 01'
  },
  {
    'label': 'Mum\'s Place',
    'icon': Icons.favorite_rounded,
    'address': 'No. 5, Galle Rd, Dehiwala'
  },
];

// ── Page ──────────────────────────────────────────────────────────────────────
class NearbyPharmacyPage extends StatefulWidget {
  const NearbyPharmacyPage({super.key});
  @override
  State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
}

class _NearbyPharmacyPageState extends State<NearbyPharmacyPage>
    with TickerProviderStateMixin {
  int _stage = 0;
  bool _scanning = true;
  bool _showMarkers = false;
  _Pharmacy? _selected;
  String _deliveryLabel = 'My Home';

  GoogleMapController? _mapController;

  static const _userPos = LatLng(6.8935, 79.8780);
  static const _zoomLevels = [15.5, 13.5, 12.0];
  static const _radiusMetres = [1000.0, 5000.0, 10000.0];
  static const _stageLabels = ['1km', '5km', '10km'];

  late AnimationController _breatheCtrl;
  late Animation<double> _breatheAnim;
  late AnimationController _labelCtrl;
  late Animation<double> _labelAnim;
  String _currentLabel = '1km';
  String _nextLabel = '1km';

  Set<Circle> _buildCircles() {
    final r = _radiusMetres[_stage];
    return {
      Circle(
          circleId: const CircleId('r4'),
          center: _userPos,
          radius: r,
          strokeColor: const Color(0xFF0796DE).withOpacity(0.5),
          strokeWidth: 2,
          fillColor: Colors.transparent),
      Circle(
          circleId: const CircleId('r3'),
          center: _userPos,
          radius: r * 0.75,
          strokeColor: const Color(0xFF0796DE).withOpacity(0.35),
          strokeWidth: 1,
          fillColor: Colors.transparent),
      Circle(
          circleId: const CircleId('r2'),
          center: _userPos,
          radius: r * 0.50,
          strokeColor: const Color(0xFF0796DE).withOpacity(0.25),
          strokeWidth: 1,
          fillColor: Colors.transparent),
      Circle(
          circleId: const CircleId('r1'),
          center: _userPos,
          radius: r * 0.25,
          strokeColor: const Color(0xFF0796DE).withOpacity(0.18),
          strokeWidth: 1,
          fillColor: Colors.transparent),
    };
  }

  Set<Marker> _buildMarkers() => {};

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
        CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut));

    _labelCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _labelAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _labelCtrl, curve: Curves.easeInOut));

    _runScanSequence();
  }

  void _runScanSequence() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    _advanceStage(1);
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    _advanceStage(2);
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    _finishScan();
  }

  void _advanceStage(int next) {
    setState(() {
      _nextLabel = _stageLabels[next];
      _stage = next;
    });
    _currentLabel = _stageLabels[next - 1];
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _userPos, zoom: _zoomLevels[next])));
    _labelCtrl.forward(from: 0).then((_) {
      setState(() => _currentLabel = _nextLabel);
      _labelCtrl.reset();
    });
  }

  void _finishScan() {
    setState(() {
      _scanning = false;
      _showMarkers = true;
    });
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _labelCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationPickerSheet(
        currentLabel: _deliveryLabel,
        onSelect: (label) => setState(() => _deliveryLabel = label),
      ),
    );
  }

  List<_Pharmacy> get _currentPharmacies => _stage == 0
      ? _pharmacies1km
      : _stage == 1
          ? _pharmacies5km
          : _pharmacies10km;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          flex: 45,
          child: Stack(children: [
            GoogleMap(
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                ctrl.setMapStyle(_mapStyle);
              },
              initialCameraPosition:
                  const CameraPosition(target: _userPos, zoom: 15.5),
              mapType: MapType.normal,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              markers: _buildMarkers(),
              circles: _buildCircles(),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _breatheAnim,
                  builder: (_, __) => CustomPaint(
                    painter: _RingsPainter(scale: _breatheAnim.value),
                  ),
                ),
              ),
            ),
            if (_showMarkers)
              Positioned.fill(child: _buildPharmacyMarkerOverlay()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0796DE), Color(0x000796DE)],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      _scanning
                          ? 'Searching nearby\nPhamacies'
                          : 'Nearby\nPhamacies',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: _showLocationPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.location_on,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 3),
                          const Text('Send to ',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontFamily: 'Poppins')),
                          Text(_deliveryLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 15),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _breatheAnim,
                builder: (_, __) => Transform.scale(
                  scale: _breatheAnim.value,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFF0796DE), width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF0796DE).withOpacity(0.6),
                            blurRadius: 14,
                            spreadRadius: 5)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          flex: 55,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            child: Column(children: [
              Center(
                  child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 8),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(3)),
              )),
              if (_scanning) _buildScanningState() else _buildResultsState(),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildPharmacyMarkerOverlay() {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final positions = [
        Offset(w * 0.52, h * 0.42),
        Offset(w * 0.56, h * 0.36),
        Offset(w * 0.50, h * 0.28),
        Offset(w * 0.48, h * 0.22),
        Offset(w * 0.44, h * 0.55),
        Offset(w * 0.42, h * 0.68),
        Offset(w * 0.65, h * 0.50),
      ];
      return Stack(
          children:
              List.generate(min(positions.length, _pharmacies10km.length), (i) {
        final p = _pharmacies10km[i];
        final pos = positions[i];
        return Positioned(
          left: pos.dx - 28,
          top: pos.dy - 50,
          child: GestureDetector(
            onTap: () => setState(() => _selected = p),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child:
                    const Icon(Icons.add, color: Color(0xFF0796DE), size: 24),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12), blurRadius: 4)
                  ],
                ),
                child: Text(p.name,
                    style: const TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 9,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        );
      }));
    });
  }

  Widget _buildScanningState() => Expanded(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _labelAnim,
              builder: (_, __) => Stack(alignment: Alignment.center, children: [
                Opacity(
                    opacity: (1 - _labelAnim.value).clamp(0.0, 1.0),
                    child: Transform.translate(
                        offset: Offset(0, -22 * _labelAnim.value),
                        child: Text(_currentLabel,
                            style: const TextStyle(
                                color: Color(0xFF0796DE),
                                fontSize: 44,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800)))),
                Opacity(
                    opacity: _labelAnim.value,
                    child: Transform.translate(
                        offset: Offset(0, 22 * (1 - _labelAnim.value)),
                        child: Text(_nextLabel,
                            style: const TextStyle(
                                color: Color(0xFF0796DE),
                                fontSize: 44,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800)))),
              ]),
            ),
            const Text('Radius',
                style: TextStyle(
                    color: Color(0xFF9F9EA5),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 14),
            const Text('Scanning for pharmacies...',
                style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _stage >= i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: _stage >= i
                                  ? const Color(0xFF0796DE)
                                  : const Color(0xFFDDDDDD),
                              borderRadius: BorderRadius.circular(4)),
                        ))),
          ],
        )),
      );

  Widget _buildResultsState() {
    final pharmacies = _currentPharmacies;
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_selected != null ? _selected!.name : 'Nearby Pharmacies',
                style: const TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
            if (_selected != null)
              GestureDetector(
                  onTap: () => setState(() => _selected = null),
                  child: const Text('Show all',
                      style: TextStyle(
                          color: Color(0xFF0796DE),
                          fontSize: 12,
                          fontFamily: 'Poppins'))),
          ]),
        ),
        if (_selected != null)
          _buildSelectedCard(_selected!)
        else
          Expanded(
              child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82),
            itemCount: pharmacies.length,
            itemBuilder: (_, i) => _buildPharmacyCard(pharmacies[i]),
          )),
      ]),
    );
  }

  Widget _buildSelectedCard(_Pharmacy p) => Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                      color: p.brandColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(p.name[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700)),
                    Text('${p.available}/${p.total} Available',
                        style: const TextStyle(
                            color: Color(0xFF9F9EA5),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                    Text(p.location,
                        style: const TextStyle(
                            color: Color(0xFF9F9EA5),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                  ])),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (p.notAvailable.isNotEmpty)
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Not Available',
                          style: TextStyle(
                              color: Color(0xFF9F9EA5),
                              fontSize: 11,
                              fontFamily: 'Poppins')),
                      Text(p.notAvailable,
                          style: const TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                    ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Total',
                    style: TextStyle(
                        color: Color(0xFF9F9EA5),
                        fontSize: 11,
                        fontFamily: 'Poppins')),
                Text('RS.${p.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800)),
              ]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statChip('Accepted', '${p.accepted}%'),
              const SizedBox(width: 8),
              _statChip('Cancelled', '${p.cancelled}%'),
              const SizedBox(width: 8),
              _statChip('Rating', '${p.rating}'),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                // ── FIXED: open payment gateway instead of snackbar ──
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentGatewayPage(
                        amount: 'RS.${p.price.toStringAsFixed(0)}',
                        pharmacyName: p.name,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0796DE),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text('Confirm',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      );

  Widget _statChip(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFF0796DE),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontFamily: 'Poppins')),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _buildPharmacyCard(_Pharmacy p) => GestureDetector(
        onTap: () {
          setState(() => _selected = p);
          _mapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(p.latLng, 16));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3))
            ],
          ),
          child: Column(children: [
            Expanded(
                flex: 55,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: p.brandColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  child: Center(
                      child: Text(p.name[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w800))),
                )),
            Expanded(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            radius: 11,
                            backgroundColor: p.brandColor,
                            child: Text(p.name[0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(p.name,
                                style: const TextStyle(
                                    color: Color(0xFF2D2D2D),
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis)),
                      ]),
                      Text(p.distance,
                          style: const TextStyle(
                              color: Color(0xFF697282),
                              fontSize: 12,
                              fontFamily: 'Poppins')),
                      Text('RS.${p.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFF0796DE),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                )),
          ]),
        ),
      );
}

// ── Location picker bottom sheet ──────────────────────────────────────────────
class _LocationPickerSheet extends StatefulWidget {
  final String currentLabel;
  final void Function(String) onSelect;
  const _LocationPickerSheet(
      {required this.currentLabel, required this.onSelect});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late String _selected;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLabel;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Deliver to',
                style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Search or enter a new address...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF0796DE), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 8),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Saved addresses',
                  style: TextStyle(
                      color: Color(0xFF9F9EA5),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600))),
        ),
        ...(_savedAddresses).map((addr) {
          final label = addr['label'] as String;
          final icon = addr['icon'] as IconData;
          final address = addr['address'] as String;
          final isSelected = _selected == label;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = label);
              widget.onSelect(label);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0796DE).withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0796DE)
                        : const Color(0xFFEEEEEE),
                    width: isSelected ? 1.5 : 1),
              ),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0796DE)
                          : const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon,
                      color:
                          isSelected ? Colors.white : const Color(0xFF0796DE),
                      size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(label,
                          style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0796DE)
                                  : const Color(0xFF1A1A2E),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                      Text(address,
                          style: const TextStyle(
                              color: Color(0xFF9F9EA5),
                              fontSize: 11,
                              fontFamily: 'Poppins')),
                    ])),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: Color(0xFF0796DE), size: 20),
              ]),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFF0796DE), width: 1.5),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_location_alt_outlined,
                        color: Color(0xFF0796DE), size: 18),
                    SizedBox(width: 8),
                    Text('Add a new address',
                        style: TextStyle(
                            color: Color(0xFF0796DE),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Breathing rings painter ───────────────────────────────────────────────────
class _RingsPainter extends CustomPainter {
  final double scale;
  _RingsPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = min(cx, cy) * 0.80 * scale;
    final strokes = [0.75, 0.55, 0.38, 0.22];
    final fills = [0.07, 0.05, 0.04, 0.03];
    for (int i = 3; i >= 0; i--) {
      final r = maxR * ((i + 1) / 4);
      canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..color = Colors.white.withOpacity(fills[i])
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..color = Colors.white.withOpacity(strokes[i])
            ..style = PaintingStyle.stroke
            ..strokeWidth = i == 3 ? 2.0 : 1.2);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.scale != scale;
}
