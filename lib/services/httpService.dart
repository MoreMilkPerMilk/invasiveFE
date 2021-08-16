import 'package:http/http.dart' as http;
import 'package:invasive_fe/models.dart';

var API_URL = 'http://invasivesys.uqcloud.net:80';

/// communicate with backend server to HTTP GET all weed instances.
Future<List<Location>> getAllLocations() async {
  final response = await http.get(Uri.parse(API_URL + "/locations"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);
    var result = Location.parseLocationList(response.body);
    result.forEach((element) {
      print(element);
    });

    return result;
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  } else {
    return [];
  }
}
