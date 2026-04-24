import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';

/// Professional Map Viewer Screen with OpenStreetMap Integration
class MapViewerScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? address;

  const MapViewerScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.address,
  });

  @override
  State<MapViewerScreen> createState() => _MapViewerScreenState();
}

class _MapViewerScreenState extends State<MapViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _isError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isError = true;
              _isLoading = false;
            });
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildMapHtml());
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    final action = message.message;
    switch (action) {
      case 'copyCoordinates':
        _copyCoordinates();
        break;
      case 'shareLocation':
        _shareLocation();
        break;
      case 'getDirections':
        _getDirections();
        break;
      default:
        debugPrint('Unknown action: $action');
    }
  }

  String _buildMapHtml() {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final name = widget.locationName ?? 'Your Location';
    final address = widget.address ?? 'Exact Location';
    final latStr = lat.toStringAsFixed(6);
    final lngStr = lng.toStringAsFixed(6);

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes">
  <title>Map Location</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    html, body {
      height: 100%;
      width: 100%;
      overflow: hidden;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    }
    
    #map {
      height: 100%;
      width: 100%;
      background: #f5f5f5;
    }
    
    /* Custom Controls */
    .custom-controls {
      position: absolute;
      bottom: 20px;
      right: 20px;
      z-index: 1000;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    
    .control-btn {
      background: white;
      border: none;
      border-radius: 12px;
      width: 50px;
      height: 50px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      font-size: 22px;
      font-weight: bold;
      color: #2E7D32;
    }
    
    .control-btn:hover {
      transform: scale(1.05);
      box-shadow: 0 6px 16px rgba(0,0,0,0.2);
    }
    
    .control-btn:active {
      transform: scale(0.95);
    }
    
    .map-type-indicator {
      background: linear-gradient(135deg, #2E7D32, #1B5E20);
      color: white;
      padding: 8px 16px;
      border-radius: 25px;
      font-size: 12px;
      font-weight: 600;
      text-align: center;
      margin-bottom: 5px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
      letter-spacing: 0.5px;
    }
    
    /* Custom Info Window */
    .custom-info-window {
      padding: 20px;
      min-width: 280px;
      max-width: 320px;
      background: white;
      border-radius: 20px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.15);
      animation: slideUp 0.3s ease;
    }
    
    @keyframes slideUp {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
    
    .info-title {
      font-size: 20px;
      font-weight: 700;
      color: #2E7D32;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .info-address {
      font-size: 13px;
      color: #666;
      margin-bottom: 16px;
      line-height: 1.4;
    }
    
    .info-coordinates {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-bottom: 16px;
      padding: 12px;
      background: linear-gradient(135deg, #f5f5f5, #eeeeee);
      border-radius: 12px;
    }
    
    .coordinate-item {
      text-align: center;
    }
    
    .coordinate-label {
      font-size: 10px;
      color: #999;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 4px;
    }
    
    .coordinate-value {
      font-size: 14px;
      font-weight: 600;
      color: #333;
      font-family: 'Courier New', monospace;
    }
    
    .info-actions {
      display: flex;
      gap: 10px;
    }
    
    .action-button {
      flex: 1;
      padding: 10px;
      border: none;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
    }
    
    .action-button:active {
      transform: scale(0.97);
    }
    
    .action-button.primary {
      background: linear-gradient(135deg, #2E7D32, #1B5E20);
      color: white;
    }
    
    .action-button.secondary {
      background: linear-gradient(135deg, #2196F3, #1976D2);
      color: white;
    }
    
    .action-button.tertiary {
      background: linear-gradient(135deg, #9C27B0, #7B1FA2);
      color: white;
    }
    
    /* Custom Marker Animation */
    .custom-marker {
      animation: bounce 0.5s ease;
    }
    
    @keyframes bounce {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-10px); }
    }
    
    /* Loading Overlay */
    .loading-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(255,255,255,0.95);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 2000;
    }
    
    .loading-spinner {
      width: 50px;
      height: 50px;
      border: 4px solid #f3f3f3;
      border-top: 4px solid #2E7D32;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    
    @media (max-width: 768px) {
      .custom-controls {
        bottom: 15px;
        right: 15px;
        gap: 10px;
      }
      .control-btn {
        width: 45px;
        height: 45px;
        font-size: 20px;
      }
      .custom-info-window {
        min-width: 260px;
        padding: 16px;
      }
      .info-title {
        font-size: 18px;
      }
    }
  </style>
</head>
<body>
  <div id="map"></div>
  
  <div class="custom-controls">
    <div class="map-type-indicator" id="mapTypeIndicator">📍 Street View</div>
    <button class="control-btn" id="zoomInBtn" title="Zoom In">+</button>
    <button class="control-btn" id="zoomOutBtn" title="Zoom Out">−</button>
    <button class="control-btn" id="satelliteBtn" title="Satellite View">🛰️</button>
    <button class="control-btn" id="resetBtn" title="My Location">📍</button>
    <button class="control-btn" id="fullscreenBtn" title="Fullscreen">⛶</button>
  </div>

  <script>
    var map;
    var marker;
    var isSatellite = false;
    var streetLayer;
    var satelliteLayer;
    var currentZoom = 16;
    
    var lat = $lat;
    var lng = $lng;
    var locationName = '$name';
    var locationAddress = '$address';
    var latStr = '$latStr';
    var lngStr = '$lngStr';
    
    // Initialize map
    function initMap() {
      // Street map layer (OpenStreetMap)
      streetLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19,
        className: 'street-layer'
      });
      
      // Satellite layer
      satelliteLayer = L.tileLayer('https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', {
        subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
        maxZoom: 20,
        attribution: '© Google',
        className: 'satellite-layer'
      });
      
      // Create map with default street view
      map = L.map('map', {
        center: [lat, lng],
        zoom: currentZoom,
        zoomControl: false,
        fadeAnimation: true,
        zoomAnimation: true,
        markerZoomAnimation: true
      });
      
      streetLayer.addTo(map);
      
      // Custom marker with pulsing effect
      var pulsingIcon = L.divIcon({
        html: '<div style="position: relative;"><div style="background: #FF0000; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 0 0 rgba(255,0,0,0.7); animation: pulse 1.5s infinite;"></div></div>' +
          '<style>' +
          '@keyframes pulse {' +
          '  0% { box-shadow: 0 0 0 0 rgba(255,0,0,0.7); }' +
          '  70% { box-shadow: 0 0 0 15px rgba(255,0,0,0); }' +
          '  100% { box-shadow: 0 0 0 0 rgba(255,0,0,0); }' +
          '}' +
          '</style>',
        iconSize: [16, 16],
        className: 'custom-marker',
        popupAnchor: [0, -8]
      });
      
      marker = L.marker([lat, lng], { icon: pulsingIcon }).addTo(map);
      
      // Create beautiful popup content
      var popupContent = 
        '<div class="custom-info-window">' +
        '<div class="info-title">📍 ' + locationName + '</div>' +
        '<div class="info-address">' + locationAddress + '</div>' +
        '<div class="info-coordinates">' +
        '<div class="coordinate-item"><div class="coordinate-label">LATITUDE</div><div class="coordinate-value">' + latStr + '</div></div>' +
        '<div class="coordinate-item"><div class="coordinate-label">LONGITUDE</div><div class="coordinate-value">' + lngStr + '</div></div>' +
        '</div>' +
        '<div class="info-actions">' +
        '<button onclick="copyCoords()" class="action-button primary">📋 Copy</button>' +
        '<button onclick="getDir()" class="action-button secondary">🧭 Directions</button>' +
        '<button onclick="shareLoc()" class="action-button tertiary">📤 Share</button>' +
        '</div>' +
        '</div>';
      
      marker.bindPopup(popupContent, {
        maxWidth: 320,
        minWidth: 280,
        className: 'custom-popup'
      }).openPopup();
      
      updateIndicator();
      
      // Add scale control
      L.control.scale({ metric: true, imperial: false, position: 'bottomleft' }).addTo(map);
    }
    
    function updateIndicator() {
      var indicator = document.getElementById('mapTypeIndicator');
      if(indicator) {
        indicator.innerHTML = isSatellite ? '🛰️ Satellite View' : '📍 Street View';
        indicator.style.background = isSatellite ? 
          'linear-gradient(135deg, #2196F3, #1976D2)' : 
          'linear-gradient(135deg, #2E7D32, #1B5E20)';
      }
    }
    
    // Zoom In with animation
    document.getElementById('zoomInBtn').addEventListener('click', function() {
      currentZoom = Math.min(map.getZoom() + 1, 19);
      map.setZoom(currentZoom);
    });
    
    // Zoom Out with animation
    document.getElementById('zoomOutBtn').addEventListener('click', function() {
      currentZoom = Math.max(map.getZoom() - 1, 3);
      map.setZoom(currentZoom);
    });
    
    // Toggle Satellite/Street View with smooth transition
    document.getElementById('satelliteBtn').addEventListener('click', function() {
      if(isSatellite) {
        map.removeLayer(satelliteLayer);
        streetLayer.addTo(map);
        isSatellite = false;
      } else {
        map.removeLayer(streetLayer);
        satelliteLayer.addTo(map);
        isSatellite = true;
      }
      updateIndicator();
      
      // Visual feedback
      var btn = document.getElementById('satelliteBtn');
      btn.style.transform = 'scale(1.1)';
      setTimeout(function() { btn.style.transform = 'scale(1)'; }, 200);
    });
    
    // Reset View
    document.getElementById('resetBtn').addEventListener('click', function() {
      map.setView([lat, lng], 16);
      marker.openPopup();
      currentZoom = 16;
      
      // Visual feedback
      var btn = document.getElementById('resetBtn');
      btn.style.transform = 'scale(1.1)';
      setTimeout(function() { btn.style.transform = 'scale(1)'; }, 200);
    });
    
    // Fullscreen mode
    document.getElementById('fullscreenBtn').addEventListener('click', function() {
      var elem = document.documentElement;
      if (!document.fullscreenElement) {
        elem.requestFullscreen().catch(err => {
          console.log('Error attempting fullscreen:', err);
        });
      } else {
        document.exitFullscreen();
      }
    });
    
    // Handle fullscreen change
    document.addEventListener('fullscreenchange', function() {
      setTimeout(function() {
        map.invalidateSize();
      }, 100);
    });
    
    // Functions for Flutter communication
    function copyCoords() {
      if(window.FlutterChannel) {
        window.FlutterChannel.postMessage('copyCoordinates');
        // Visual feedback on button
        event.target.style.transform = 'scale(0.95)';
        setTimeout(function() { event.target.style.transform = 'scale(1)'; }, 100);
      }
    }
    
    function getDir() {
      if(window.FlutterChannel) window.FlutterChannel.postMessage('getDirections');
    }
    
    function shareLoc() {
      if(window.FlutterChannel) window.FlutterChannel.postMessage('shareLocation');
    }
    
    // Initialize map when page loads
    window.addEventListener('load', initMap);
  </script>
</body>
</html>
  ''';
  }

  Future<void> _copyCoordinates() async {
    final coordinates =
        '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}';

    try {
      await FlutterClipboard.copy(coordinates);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Coordinates copied: $coordinates')),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to copy coordinates');
    }
  }

  Future<void> _getDirections() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open Google Maps');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open directions');
    }
  }

  Future<void> _shareLocation() async {
    final locationName = widget.locationName ?? 'Shared Location';
    final lat = widget.latitude.toStringAsFixed(6);
    final lng = widget.longitude.toStringAsFixed(6);
    final mapsUrl =
        'https://www.google.com/maps?q=${widget.latitude},${widget.longitude}';

    final shareText =
        '''
📍 $locationName
🌍 Coordinates: $lat, $lng
🗺️ View on Maps: $mapsUrl
''';

    try {
      await Share.share(shareText, subject: 'Location: $locationName');
    } catch (e) {
      _showErrorSnackBar('Failed to share location');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                icon: Icons.copy,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'Copy Coordinates',
                subtitle:
                    '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                onTap: () {
                  Navigator.pop(context);
                  _copyCoordinates();
                },
              ),
              _buildOptionTile(
                icon: Icons.directions,
                iconColor: const Color(0xFF2196F3),
                iconBgColor: const Color(0xFFE3F2FD),
                title: 'Get Directions',
                subtitle: 'Open in Google Maps',
                onTap: () {
                  Navigator.pop(context);
                  _getDirections();
                },
              ),
              _buildOptionTile(
                icon: Icons.share,
                iconColor: const Color(0xFF9C27B0),
                iconBgColor: const Color(0xFFF3E5F5),
                title: 'Share Location',
                subtitle: 'Share with others',
                onTap: () {
                  Navigator.pop(context);
                  _shareLocation();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }

  void _reloadMap() {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    _controller.loadHtmlString(_buildMapHtml());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.locationName ?? 'Location Map',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (widget.address != null)
              Text(
                widget.address!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsBottomSheet,
            tooltip: 'More options',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadMap,
            tooltip: 'Refresh map',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isError)
            _buildErrorState()
          else
            WebViewWidget(controller: _controller),
          if (_isLoading && !_isError) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load map',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your internet connection',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _reloadMap,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading map...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
