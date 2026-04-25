class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Yeh function Supabase (Database) se aanay walay data ko hamari class mein fit karega
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'No Name',
      // YAHAN CHANGE KIYA HAI: 'image_url' ki jagah 'img' kar diya hai
      imageUrl: json['img'] ?? '',
    );
  }
}