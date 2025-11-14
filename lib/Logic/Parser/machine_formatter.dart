class MachineFormatter{
  static String formatMachineType(String machineName){
    int indexOfSpace = machineName.indexOf(" ");
    return machineName.substring(0,indexOfSpace);
  }
}