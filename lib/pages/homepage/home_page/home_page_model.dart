import '/flutter_flow/flutter_flow_util.dart';
import '/pages/homepage/blogs/article_card1/article_card1_widget.dart';
import '/pages/homepage/blogs/article_card2/article_card2_widget.dart';
import '/pages/homepage/chart_card/chart_card_widget.dart';
import '/pages/homepage/navigation/navigation_widget.dart';
import '/pages/homepage/value_list_item/value_list_item_widget.dart';
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Column widget.
  ScrollController? columnController;
  // Model for ValueListItem component.
  late ValueListItemModel valueListItemModel;
  // Model for ChartCard component.
  late ChartCardModel chartCardModel;
  // State field(s) for Row widget.
  ScrollController? rowController;
  // State field(s) for ListView widget.
  ScrollController? listViewController;
  // Model for ArticleCard1 component.
  late ArticleCard1Model articleCard1Model;
  // Model for ArticleCard2 component.
  late ArticleCard2Model articleCard2Model;
  // Model for Navigation component.
  late NavigationModel navigationModel;

  @override
  void initState(BuildContext context) {
    columnController = ScrollController();
    valueListItemModel = createModel(context, () => ValueListItemModel());
    chartCardModel = createModel(context, () => ChartCardModel());
    rowController = ScrollController();
    listViewController = ScrollController();
    articleCard1Model = createModel(context, () => ArticleCard1Model());
    articleCard2Model = createModel(context, () => ArticleCard2Model());
    navigationModel = createModel(context, () => NavigationModel());
  }

  @override
  void dispose() {
    columnController?.dispose();
    valueListItemModel.dispose();
    chartCardModel.dispose();
    rowController?.dispose();
    listViewController?.dispose();
    articleCard1Model.dispose();
    articleCard2Model.dispose();
    navigationModel.dispose();
  }
}
