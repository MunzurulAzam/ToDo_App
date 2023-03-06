import 'package:todolist/bloc/todo_bloc.dart';
import 'package:todolist/constants.dart';
import 'package:todolist/lists/mod_category_list.dart';
import 'package:todolist/screens/search/group_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../reusables/custom_back_button.dart';
import '../reusables/popup_menu.dart';
import '../reusables/rename_sheet.dart';

/// Here, you can make changes to each individual task within a Category
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  static const tag = '/category';

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoBloc>(
      builder: (_, data, Widget? child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: kEdgePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomBackButton(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Search',
                            iconSize: kIconSize,
                            onPressed: () {
                              showSearch(
                                context: context,
                                delegate: GroupSearch(
                                    hintText: 'Search ${data.selected}'),
                              );
                            },
                            icon: const Icon(
                              Icons.search_rounded,
                              color: kTertiaryColor,
                            ),
                          ),
                          const PopUpMenu(),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    data.selected,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.only(
                                      bottom: 11,
                                      left: 5,
                                    ),
                                    alignment: Alignment.bottomLeft,
                                    tooltip: 'Rename',
                                    iconSize: kEditIconSize,
                                    onPressed: () {
                                      // Calls up the buttom sheet
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        shape: kRoundedBorder,
                                        context: context,
                                        builder: (context) => const RenameSheet(
                                          function: '/category',
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.mode_edit_rounded,
                                      color: kTertiaryColor,
                                    ),
                                  )
                                ],
                              ),
                              spacing(height: 3),
                              Text(
                                'TASKS (${data.groupLength})',
                                style: kText1,
                              ),
                            ],
                          ),
                        ),
                        spacing(),
                        const Expanded(
                          child: ModifiedCategoryList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  spacing({double height = 15}) {
    return SizedBox(
      height: height,
    );
  }
}
