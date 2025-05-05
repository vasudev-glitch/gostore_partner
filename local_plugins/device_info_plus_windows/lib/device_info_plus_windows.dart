import 'dart:typed_data';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';

class DeviceInfoPlusWindowsPlugin extends DeviceInfoPlatform {
  static void registerWith(_) {
    DeviceInfoPlatform.instance = DeviceInfoPlusWindowsPlugin();
  }

  @override
  Future<WindowsDeviceInfo> deviceInfo() async {
    return WindowsDeviceInfo(
      computerName: 'GoStore-PC',
      numberOfCores: 8,
      systemMemoryInMegabytes: 16384,
      deviceId: 'ABC123456789',
      majorVersion: 10,
      minorVersion: 0,
      buildNumber: 19045,
      platformId: 2,
      csdVersion: 'Service Pack 1',
      servicePackMajor: 1,
      servicePackMinor: 0,
      productType: 1,
      reserved: 0,
      installDate: DateTime.now(), // ✅ Corrected to DateTime
      registeredOwner: 'GoStore Admin',
      productId: 'XXXXX-XXXXX-XXXXX-XXXXX',
      editionId: 'Professional',
      displayVersion: '22H2',
      buildLab: '19045.2846.amd64fre.22h2_release',
      buildLabEx: '19041.1.amd64fre.vb_release.191206-1406',
      digitalProductId: Uint8List.fromList([1, 2, 3, 4, 5]), // ✅ Mock example
      productName: 'Windows 10 Pro',
      releaseId: '2009',
      suitMask: 768,
      userName: 'Admin',
    );
  }
}
