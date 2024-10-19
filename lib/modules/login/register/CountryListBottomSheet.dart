import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBody.dart';
import 'package:flutter/material.dart';

class CountryListBottomSheet {
  static Future<dynamic> showItemSelectionSheet(context, String title, List<dynamic> list) async {
    var countryModel = await showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(top: 26),
            child: ItemList(title, list),
          );
        });
    return countryModel;
  }
}

class ItemList extends StatefulWidget {
  final String title;
  final List<dynamic> list;

  ItemList(this.title, this.list);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  var _searchEdit = new TextEditingController();
  String searchQuery;
  List<dynamic> filteredList;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    
    filteredList = widget.list;

    _searchEdit.addListener(() {
      searchQuery = _searchEdit.text;
      if (searchQuery.isEmpty) {
        filteredList = widget.list;
        setState(() {});
      } else {
        filteredList = widget.list.where((i) => i.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimensions.generalBottomSheetRadius),
        topRight: Radius.circular(AppDimensions.generalBottomSheetRadius),
      ),
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: BaseFormBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: AppDimensions.largeTopBottomPadding, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
                        child: Text(widget.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.generalPadding),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalTopPadding),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextFormField(
                          controller: _searchEdit,
                          decoration: InputDecoration( labelText: AppStrings.searchHint),
                          focusNode: _focusNode,
                        ),
                        Offstage(
                            offstage: (searchQuery?.isEmpty ?? true),
                            child: IconButton(
                                onPressed: () => _searchEdit.text = "",
                                icon: Icon(Icons.clear, color: Theme.of(context).accentColor)))
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      var _model = filteredList[index];
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pop(_model);
                            },
                            title: Text(_model,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
