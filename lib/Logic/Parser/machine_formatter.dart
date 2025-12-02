class MachineFormatter{
  static String formatMachineType(String? machineName) {
    if (machineName == null || machineName.isEmpty) return "Unknown";

    final index = machineName.indexOf(" ");
    if (index == -1) return machineName; // No space → return whole name

    return machineName.substring(0, index);
  }
}