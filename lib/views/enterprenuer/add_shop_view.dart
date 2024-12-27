import 'package:flutter/material.dart';
import 'package:lrm_app/ViewModels/add_shop_view_model.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/enterprenuer/edit_shop_view.dart';
import 'package:lrm_app/views/enterprenuer/enterpreneur_view.dart';
import 'package:provider/provider.dart';

class AddShopView extends StatelessWidget {
  const AddShopView({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<ShopViewModel>(
            // Listen to changes in ShopViewModel
            builder: (context, shopViewModel, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextField('Name of shop',
                      controller: shopViewModel.shopNameController),
                  _buildTextField('Location of shop',
                      controller: shopViewModel.locationController),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () => shopViewModel.pickImage(),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.cartColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: shopViewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : shopViewModel.selectedImage == null
                                ? const Center(
                                    child: Text(
                                    'Choose a picture of the shop',
                                    style: TextStyle(color: AppColors.textgrey),
                                  ))
                                : Image.file(
                                    shopViewModel.selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                      ),
                    ),
                  ),
                  _buildTextField('Description of shop',
                      maxLines: 5,
                      controller: shopViewModel.descriptionController),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: shopViewModel.isLoading
                          ? null
                          : () => shopViewModel.addShop().then((_) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EnterpreneurView(),
                                  ),
                                );
                              }).catchError((e) {
                                // Handle error
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "Failed to add shop. Please try again."),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonOK,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: shopViewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add shop',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.cartColor,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String shopId = '6v9fd56lyd51103';
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditShopView(
                                    shopId: shopId,
                                  )));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: shopViewModel.isLoading
                        ? const CircularProgressIndicator(color: AppColors.textFieldground)
                        : const Text(
                            'Edit shop',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.cartColor,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool obscureText = false,
      TextInputType? keyboardType,
      int maxLines = 1,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
}
