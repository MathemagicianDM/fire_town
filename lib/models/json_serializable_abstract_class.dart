
abstract class JsonSerializable {
  factory JsonSerializable.fromJson(Map<String,dynamic> json) {
    throw UnimplementedError('fromJson must be implemented');
  }
  Map<String,dynamic> toJson(){
    throw UnimplementedError('toJson must be implemented, boyo');
  }
  String compositeKey(){
    throw UnimplementedError('compositeKey must be implemented, boyo');
  }
}

// class ProviderList<T extends JsonSerializable> extends StateNotifier<List<T>>
// {
//   final Box<String> myBox;
//   final T Function(Map<String,dynamic>) fromJson;

//  ProviderList({required this.myBox, required this.fromJson})
//       : super([]) {
//     _initializeBox();
//   }

//   Future<void> _initializeBox() async {
//     // Ensure the box is open before accessing its values
//     if (myBox.isOpen) {
//       List<T> loadedItems = myBox.values
//           .map((v) => fromJson(jsonDecode(v))) // Deserialize each value
//           .cast<T>()
//           .toList();
//       state = loadedItems;
//     } else {
//       // Handle the case where the box is closed, if needed
//       print("Box is not open.");
//     }
//   }
    
//   Future<void> add({required T addMe}) async {
  
//     String id = addMe.compositeKey();
//       await myBox.put(id, jsonEncode(addMe.toJson()));
//     state = myBox.values.map((v) =>
//          fromJson(jsonDecode(v))).cast<T>().toList();}

//   Future<void> bulkAdd({required List<T> items}) async {

      
//       for (int i = 0; i < items.length; i++) {
//         final item = items[i];
//         await add(addMe: item);
//       }
//   }

//   Future<void> delete(dynamic deleteID) async {
//     await deleteWithoutStateUpdate(deleteID);
//     refreshState();
//   }
  
//   Future<void> replaceWithoutStateUpdate(dynamic id, T replacement) async {
//     await myBox.put(id, jsonEncode(replacement.toJson()));
//   }
  
//   Future<void> deleteWithoutStateUpdate(dynamic id) async {
//     await myBox.delete(id);
//   }
  
//   // Refactored public methods
//   Future<void> replace({required dynamic replaceID, required T replacement}) async {
//     await replaceWithoutStateUpdate(replaceID, replacement);
//       refreshState();
//     }
  
//   // Helper to refresh the full state when needed
//   void refreshState() {
//     state = myBox.values
//         .map((v) => fromJson(jsonDecode(v)))
//         .cast<T>()
//         .toList();
//   }

//   List<T> getState() => state;
//   void setState(List<T> newState) => state = newState;
// }


