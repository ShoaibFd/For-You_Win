//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bluetooth_print_plus/bluetooth_print_plus_plugin.h>
#include <open_file_linux/open_file_linux_plugin.h>
#include <printing/printing_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) bluetooth_print_plus_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BluetoothPrintPlusPlugin");
  bluetooth_print_plus_plugin_register_with_registrar(bluetooth_print_plus_registrar);
  g_autoptr(FlPluginRegistrar) open_file_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "OpenFileLinuxPlugin");
  open_file_linux_plugin_register_with_registrar(open_file_linux_registrar);
  g_autoptr(FlPluginRegistrar) printing_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PrintingPlugin");
  printing_plugin_register_with_registrar(printing_registrar);
}
