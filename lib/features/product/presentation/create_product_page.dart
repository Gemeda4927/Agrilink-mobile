import 'dart:io';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_state.dart';

import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/product/presentation/bloc/product_event.dart';
import 'package:agrilink/features/product/presentation/bloc/product_state.dart';

import 'package:agrilink/features/category/domain/entities/category.dart';
import 'package:agrilink/features/category/domain/entities/subcategory.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  // Controllers for optional fields
  final cityController = TextEditingController();

  List<Category> categories = [];
  List<SubCategory> subCategories = [];

  String? selectedCategoryId;
  String? selectedSubCategoryId;

  File? image;

  bool isCategoryLoading = false;
  bool isSubCategoryLoading = false;

  // Optional fields for product creation
  bool? withDelivery;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  void clearForm() {
    nameController.clear();
    amountController.clear();
    priceController.clear();
    descController.clear();
    cityController.clear();
    setState(() {
      selectedCategoryId = null;
      selectedSubCategoryId = null;
      subCategories = [];
      image = null;
      withDelivery = null;
    });
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Success!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your product is uploaded",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please browse marketplace",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      clearForm(); // Clear the form
                      context.goNamed(
                        RouteName.product,
                      ); // Navigate to marketplace
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Browse Marketplace",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.green),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget imagePickerTile() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
          color: Colors.green.shade50,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 42,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap to upload product image",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(image!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildOptionalFieldsCard() {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            decoration: inputDecoration(
              "City/Town",
              "e.g. Addis Ababa",
              Icons.location_city,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: withDelivery ?? false,
                  onChanged: (value) {
                    setState(() {
                      withDelivery = value;
                    });
                  },
                  title: const Text("With Delivery"),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showReviewAndAgreement() {
    if (selectedSubCategoryId == null || image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select an image"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    bool isAgreed = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Review Product",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(image!, height: 150, fit: BoxFit.cover),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                nameController.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.scale, size: 18),
                              const SizedBox(width: 6),
                              Text("Amount: ${amountController.text}"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.monetization_on_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text("Price: ${priceController.text} ETB"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.notes, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  descController.text.isEmpty
                                      ? "No description"
                                      : descController.text,
                                ),
                              ),
                            ],
                          ),
                          if (cityController.text.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_city, size: 18),
                                const SizedBox(width: 6),
                                Text("City: ${cityController.text}"),
                              ],
                            ),
                          ],
                          if (withDelivery != null && withDelivery!) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.delivery_dining, size: 18),
                                const SizedBox(width: 6),
                                const Text("Delivery Available: Yes"),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Agreement",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "I confirm that the product information is correct and complies with the marketplace guidelines.",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: isAgreed,
                                onChanged: (val) {
                                  setStateModal(() => isAgreed = val!);
                                },
                              ),
                              const Text("I Agree"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isAgreed
                                ? () {
                                    Navigator.pop(context);
                                    submit();
                                  }
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text("Confirm"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Post Product"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoading) {
            setState(() => isCategoryLoading = true);
          }

          if (state is CategoryLoaded) {
            setState(() {
              categories = state.categories;
              isCategoryLoading = false;
            });
          }

          if (state is SubCategoryLoaded) {
            setState(() {
              subCategories = state.subCategories;
              isSubCategoryLoading = false;
            });
          }

          if (state is CategoryError) {
            setState(() {
              isCategoryLoading = false;
              isSubCategoryLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildCard(
                child: DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  hint: Text(
                    isCategoryLoading
                        ? "Loading categories..."
                        : "Select Category",
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedCategoryId = value;
                      selectedSubCategoryId = null;
                      subCategories = [];
                      isSubCategoryLoading = true;
                    });

                    context.read<CategoryBloc>().add(LoadSubCategories(value));
                  },
                  decoration: inputDecoration(
                    "Category",
                    "Choose category",
                    Icons.dashboard,
                  ),
                ),
              ),
              buildCard(
                child: DropdownButtonFormField<String>(
                  value: selectedSubCategoryId,
                  hint: Text(
                    isSubCategoryLoading
                        ? "Loading subcategories..."
                        : "Select SubCategory",
                  ),
                  items: subCategories.map((sub) {
                    return DropdownMenuItem(
                      value: sub.id,
                      child: Text(sub.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubCategoryId = value;
                    });
                  },
                  decoration: inputDecoration(
                    "Sub Category",
                    "Choose sub category",
                    Icons.layers,
                  ),
                ),
              ),
              buildCard(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: inputDecoration(
                        "Product Name",
                        "e.g. Fresh Tomato",
                        Icons.inventory,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        "Amount (in kg/units)",
                        "e.g. 10",
                        Icons.scale,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        "Price (in ETB)",
                        "e.g. 500",
                        Icons.payments,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: inputDecoration(
                        "Description",
                        "Write product details...",
                        Icons.notes,
                      ),
                    ),
                  ],
                ),
              ),
              _buildOptionalFieldsCard(),
              buildCard(child: imagePickerTile()),
              const SizedBox(height: 10),
              BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state is ProductCreated) {
                    showSuccessDialog();
                  }

                  if (state is ProductError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ProductCreating) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: showReviewAndAgreement,
                      icon: const Icon(Icons.preview),
                      label: const Text("Review & Post"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() {
    // Validate numeric inputs
    final amount = int.tryParse(amountController.text.trim());
    final price = int.tryParse(priceController.text.trim());

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid price"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Get city from controller (empty string if not provided)
    final cityValue = cityController.text.trim().isEmpty
        ? null
        : cityController.text.trim();

    context.read<ProductBloc>().add(
      CreateProductEvent(
        name: nameController.text.trim(),
        amount: amount,
        price: price,
        description: descController.text.trim(),
        subCategoryId: selectedSubCategoryId!,
        image: image!,
        city: cityValue,
        withDelivery: withDelivery,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    priceController.dispose();
    descController.dispose();
    cityController.dispose();
    super.dispose();
  }
}
