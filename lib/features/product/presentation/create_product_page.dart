import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

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

  List<Category> categories = [];
  List<SubCategory> subCategories = [];

  String? selectedCategoryId;
  String? selectedSubCategoryId;

  File? image;

  @override
  void initState() {
    super.initState();

    /// Load categories ONCE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(LoadCategories());
    });
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Product"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),

      /// ✅ ONLY LISTEN (no rebuild loop)
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoaded) {
            categories = state.categories;
          }

          if (state is SubCategoryLoaded) {
            subCategories = state.subCategories;
          }

          if (state is CategoryError) {
            _showError(state.message);
          }

          setState(() {});
        },

        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    /// show loader ONLY when categories empty
    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// CATEGORY
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              hint: const Text("Select Category"),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat.id, child: Text(cat.name));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                /// 🚨 prevent duplicate calls
                if (value == selectedCategoryId) return;

                setState(() {
                  selectedCategoryId = value;
                  selectedSubCategoryId = null;
                  subCategories.clear();
                });

                context.read<CategoryBloc>().add(LoadSubCategories(value));
              },
            ),

            const SizedBox(height: 12),

            /// SUBCATEGORY
            if (selectedCategoryId != null)
              DropdownButtonFormField<String>(
                value: selectedSubCategoryId,
                hint: const Text("Select SubCategory"),
                items: subCategories.map((sub) {
                  return DropdownMenuItem(value: sub.id, child: Text(sub.name));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubCategoryId = value;
                  });
                },
              ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            if (image != null) Image.file(image!, height: 100),

            const SizedBox(height: 20),

            BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state is ProductCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product created!")),
                  );

                  /// ✅ FIX GoRouter crash
                  context.goNamed('home');
                }

                if (state is ProductError) {
                  _showError(state.message);
                }
              },
              builder: (context, state) {
                if (state is ProductCreating) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Post Product"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (selectedSubCategoryId == null || image == null) {
      _showError("Fill all fields");
      return;
    }

    context.read<ProductBloc>().add(
      CreateProductEvent(
        name: nameController.text,
        amount: int.parse(amountController.text),
        price: int.parse(priceController.text),
        description: descController.text,
        subCategoryId: selectedSubCategoryId!,
        image: image!,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
