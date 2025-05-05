#include "device_info_plus_windows_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>
#include <memory>
#include <sstream>

class DeviceInfoPlusWindowsPlugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    DeviceInfoPlusWindowsPlugin();

    virtual ~DeviceInfoPlusWindowsPlugin();

private:
    void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void DeviceInfoPlusWindowsPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar) {
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "dev.fluttercommunity.plus/device_info",
                    &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<DeviceInfoPlusWindowsPlugin>();

    channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result) {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

    registrar->AddPlugin(std::move(plugin));
}

DeviceInfoPlusWindowsPlugin::DeviceInfoPlusWindowsPlugin() {}

DeviceInfoPlusWindowsPlugin::~DeviceInfoPlusWindowsPlugin() {}

void DeviceInfoPlusWindowsPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name() == "getDeviceInfo") {
        std::ostringstream os;
        os << "Windows "
           << std::to_string(GetVersion());
        result->Success(flutter::EncodableValue(os.str()));
    } else {
        result->NotImplemented();
    }
}
