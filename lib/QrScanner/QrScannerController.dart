
class QrScannerController {

  Uri? _uri;
  String? _nayaxID;

  QrScannerController(String url){
    try {
      _uri = Uri.parse(url);
      _parseUrl();
    }catch (e){
      _uri = null;
      _nayaxID = null;
    }
  }

  void _parseUrl(){
    _nayaxID = _uri?.queryParameters['nayaxDeviceID'];
  }

  String? getNayaxDeviceID(){
    return _nayaxID;
  }

}