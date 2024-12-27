import 'package:flutter/material.dart';
import 'package:lrm_app/ViewModels/add_menu_view_model.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:provider/provider.dart';

class AddView extends StatelessWidget {
  const AddView({Key? key}) : super(key: key);

  Widget _buildTextField(String hint,
      {TextEditingController? controller,
      bool obscureText = false,
      TextInputType? keyboardType,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.textFieldground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Name shop',
                  controller: viewModel.shopNameController),
              _buildTextField('Name of dish',
                  controller: viewModel.dishNameController),
              _buildTextField(
                'Price of dish',
                controller: viewModel.priceController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'Rating',
                controller: viewModel.ratingController,
                keyboardType: TextInputType.number,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InkWell(
                  onTap: viewModel.pickImage,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.cartColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: viewModel.selectedImage == null
                        ? const Center(
                            child: Text(
                              'Choose a picture of the dish',
                              style: TextStyle(color: AppColors.textgrey),
                            ),
                          )
                        : Image.file(
                            viewModel.selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
              ),
              _buildTextField(
                'Description of dish',
                controller: viewModel.descriptionController,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => viewModel.addDish(context, 'zn65203drj9o1m4'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonOK,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.cartColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
