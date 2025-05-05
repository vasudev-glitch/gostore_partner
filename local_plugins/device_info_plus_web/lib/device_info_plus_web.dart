import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';

class DeviceInfoPlusWebPlugin extends DeviceInfoPlatform {
  static void registerWith(Registrar registrar) {
    DeviceInfoPlatform.instance = DeviceInfoPlusWebPlugin();
  }

  @override
  Future<WebBrowserInfo> webBrowserInfo() async {
    return WebBrowserInfo(
      appCodeName: 'Mozilla',
      appName: 'GoStore',
      appVersion: '1.0',
      deviceMemory: 8,
      hardwareConcurrency: 4,
      language: 'en-US',
      languages: ['en-US', 'en'],
      maxTouchPoints: 5,
      platform: 'web',
      product: 'Gecko',
      productSub: '20030107',
      userAgent: 'custom-agent',
      vendor: 'Flutter',
      vendorSub: '',
    );
  }
}
