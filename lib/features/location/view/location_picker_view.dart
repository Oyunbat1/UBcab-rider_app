import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider_app/core/theme/app_theme.dart';
import 'package:rider_app/features/location/logic/location_controller.dart';


class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();
  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);
    try {
      final results = await locationFromAddress(q);
      if (results.isEmpty) {
        Get.snackbar('Search', 'Could not find: $q');
        return;
      }
      final first = results.first;
      final target = LatLng(first.latitude, first.longitude);
      final c = await _mapControllerCompleter.future;
      await c.animateCamera(
        CameraUpdate.newLatLngZoom(target, 17),
      );

    } catch (e) {
      Get.snackbar('Search Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pick destination',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        final pos = controller.state.currentPosition.value;
        if (pos == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.state.isLoading.value)
                  const CircularProgressIndicator(
                      color: AppTheme.primaryColor)
                else ...[
                  const Icon(Icons.location_off,
                      size: 48, color: AppTheme.textTertiary),
                  const SizedBox(height: 12),
                  const Text('Could not get your location'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.getCurrentLocation,
                    child: const Text('Try again'),
                  ),
                ],
              ],
            ),
          );
        }

        final initial = LatLng(pos.latitude, pos.longitude);

        return Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: initial, zoom: 16),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (c) {
                _mapController = c;
                if (!_mapControllerCompleter.isCompleted) {
                  _mapControllerCompleter.complete(c);
                }
                controller.onMapMoved(initial);
              },
              onCameraMove: (camera) {
                controller.state.pickedLatLng.value = camera.target;
              },
              onCameraIdle: () async {
                final c = await _mapControllerCompleter.future;
                final region = await c.getVisibleRegion();
                final center = LatLng(
                  (region.northeast.latitude + region.southwest.latitude) / 2,
                  (region.northeast.longitude + region.southwest.longitude) / 2,
                );
                controller.onMapMoved(center);
              },
            ),


            const Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: Icon(
                Icons.location_pin,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildSearchBar(),
            ),


            Positioned(
              right: 16,
              top: 80,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    final c = await _mapControllerCompleter.future;
                    c.animateCamera(
                      CameraUpdate.newLatLngZoom(initial, 16),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.my_location,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),


            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _buildConfirmCard(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchAddress,
                decoration: const InputDecoration(
                  hintText: 'Search address (e.g. Sukhbaatar Square)',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primaryColor),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward,
                        color: AppTheme.primaryColor),
                    onPressed: () => _searchAddress(_searchController.text),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmCard(LocationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.place, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  if (controller.state.isReverseGeocoding.value) {
                    return Row(
                      children: const [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading address...',
                          style: TextStyle(color: AppTheme.textTertiary),
                        ),
                      ],
                    );
                  }
                  final addr = controller.state.pickedAddress.value;
                  return Text(
                    addr.isEmpty ? 'Move map to pick a place' : addr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final picked = controller.state.pickedLatLng.value;
            final canConfirm = picked != null &&
                !controller.state.isReverseGeocoding.value;
            return ElevatedButton(
              onPressed: canConfirm
                  ? () {
                      final addr = controller.state.pickedAddress.value;
                      final firstLine = addr.isEmpty
                          ? 'Selected location'
                          : addr.split(',').first;
                      final rest = addr.isEmpty ? '' : addr;
                      Get.back(result: {
                        'title': firstLine,
                        'subtitle': rest,
                        'latitude': picked.latitude,
                        'longitude': picked.longitude,
                      });
                    }
                  : null,
              child: const Text('Confirm location'),
            );
          }),
        ],
      ),
    );
  }
}
