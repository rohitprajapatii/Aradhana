import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

import './../widgets/MD5Indicator.dart';
import '../../blocs/products_bloc.dart';
import '../../functions.dart';
import '../../models/app_state_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../checkout/cart/cart.dart';
import 'product_filter/filter_product.dart';
import 'product_grid/product_item4.dart';

class ProductsWidget extends StatefulWidget {
  final ProductsBloc productsBloc = ProductsBloc();
  final Map<String, dynamic> filter;
  final String name;
  AppStateModel model = AppStateModel();

  ProductsWidget({
    Key key,
    this.filter,
    this.name,
  }) : super(key: key);

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget>
    with TickerProviderStateMixin {
  var _isVisible;
  TabController _tabController;
  ScrollController _scrollController = new ScrollController();
  ScrollController _hideButtonController;
  var top = 0.0;
  Category selectedCategory;
  List<Category> subCategories;

  @override
  initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _isVisible = false;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isVisible)
          setState(() {
            _isVisible = false;
            print("**** $_isVisible up");
          });
      }
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_isVisible)
          setState(() {
            _isVisible = true;
            print("**** $_isVisible down");
          });
      }
    });
    widget.model.selectedRange =
        RangeValues(0, widget.model.blocks.maxPrice.toDouble());
    widget.productsBloc.productsFilter = widget.filter;
    subCategories = widget.model.blocks.categories
        .where((cat) =>
            cat.parent.toString() == widget.productsBloc.productsFilter['id'])
        .toList();
    if (subCategories.length != 0) {
      subCategories.insert(
          0, Category(name: 'All', id: int.parse(widget.filter['id'])));
    }
    _tabController = TabController(vsync: this, length: subCategories.length);
    _tabController.index = 0;
    widget.productsBloc.fetchAllProducts(widget.filter['id']);
    widget.productsBloc.fetchProductsAttributes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        widget.productsBloc.loadMore(subCategories[_tabController.index].id.toString());
      }
    });
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (widget.productsBloc.productsFilter['id'] !=
        subCategories[_tabController.index].id.toString()) {
      widget.productsBloc.productsFilter = new Map<String, dynamic>();
      widget.model.selectedRange =
          RangeValues(0, widget.model.blocks.maxPrice.toDouble());
      widget.productsBloc.fetchAllProducts(subCategories[_tabController.index].id.toString());
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
      setState(() {
        selectedCategory = subCategories[_tabController.index];
      });
    }
  }

  _onSelectSubcategory(int id) {
    widget.productsBloc.fetchAllProducts(id.toString());
    _scrollController.jumpTo(0.0);
    setState(() {
      selectedCategory = subCategories[_tabController.index];
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.productsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          controller: _hideButtonController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                  elevation: 0,
                  expandedHeight: 180.0,
                  floating: false,
                  pinned: true,
                  centerTitle: true,
                  title: _isVisible
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 55,
                                width: 220,
                                padding: EdgeInsets.all(8),
                                // margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50),
                                //color: Colors.orange,
                                // color: Colors.black,
                                child: TextField(
                                  /*onTap: () {
                                           showSearch(
                                             context: context,
                                         delegate: SearchProducts(onProductClick));
                                         },*/
                                  decoration: InputDecoration(
                                    hintText: 'Search products or suppliers',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.withOpacity(.8),
                                      fontSize: 16,
                                      fontFamily: 'Circular',
                                    ),
                                    fillColor: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.withOpacity(0.4)
                                        : Theme.of(context).canvasColor,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 0,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(6),
                                    prefixIcon: Icon(
                                      FontAwesomeIcons.search,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.tune,
                        semanticLabel: 'filter',
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => FilterProduct(
                                  productsBloc: widget.productsBloc,
                                  categories: subCategories,
                                  onSelectSubcategory: _onSelectSubcategory),
                            ));
                      },
                    ),
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            FlutterIcons.shopping_cart_fea,
                            semanticLabel: 'filter',
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => CartPage(),
                                ));
                          },
                        ),
                        Positioned(
                          // draw a red marble
                          top: 2,
                          right: 2.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CartPage(),
                                  ));
                            },
                            child: ScopedModelDescendant<AppStateModel>(
                                builder: (context, child, model) {
                              if (model.count != 0) {
                                return Card(
                                    elevation: 0,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    color: Colors.redAccent,
                                    child: Container(
                                        padding: EdgeInsets.all(2),
                                        constraints:
                                            BoxConstraints(minWidth: 20.0),
                                        child: Center(
                                            child: Text(
                                          model.count.toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              backgroundColor:
                                                  Colors.redAccent),
                                        ))));
                              } else
                                return Container();
                            }),
                          ),
                        )
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(parseHtmlString(widget.name)),
                    /*background: CachedNetworkImage(
                      imageUrl: selectedCategory.image,
                      imageBuilder: (context, imageProvider) => Ink.image(
                        child: InkWell(
                          onTap: () {
                            var filter = new Map<String, dynamic>();
                            filter['id'] = selectedCategory.id.toString();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductsWidget(
                                        filter: filter, name: selectedCategory.name)));
                          },
                        ),
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      placeholder: (context, url) =>
                          Container(color: Colors.transparent),
                      errorWidget: (context, url, error) => Container(color: Colors.black12),
                    ) ,*/
                  )),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 10),
                  unselectedLabelColor: Colors.white.withOpacity(.5),
                  labelColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 10.0,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: MD2Indicator(
                      //it begins here
                      indicatorHeight: 5,
                      indicatorColor: Colors.white,
                      indicatorSize: MD2IndicatorSize
                          .normal //3 different modes tiny-normal-full
                      ),
                  tabs: subCategories
                      .map<Widget>((Category category) => Tab(
                          text: category.name
                              .replaceAll(new RegExp(r'&amp;'), '&')))
                      .toList(),
                )),
                pinned: true,
              ),
            ];
          },
          body: StreamBuilder(
              stream: widget.productsBloc.allProducts,
              builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.length != 0) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: buildLisOfBlocks(snapshot),
                    );
                  } else {
                    return StreamBuilder<bool>(
                        stream: widget.productsBloc.isLoadingProducts,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return Center(child: CircularProgressIndicator());
                          } else
                            return Center(
                              child: Icon(
                                FlutterIcons.smile_o_faw,
                                size: 150,
                                color: Theme.of(context).focusColor,
                              ),
                            );
                        });
                  }
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return Center(child: CircularProgressIndicator());
              })),
    );
  }

  List<Widget> buildLisOfBlocks(AsyncSnapshot<List<Product>> snapshot) {
    List<Widget> list = new List<Widget>();

    /// UnComment this if you use rounded corner category list in body.
    //list.add(buildSubcategories());
    if (snapshot.data != null) {
      list.add(ProductGrid(products: snapshot.data));

      list.add(SliverPadding(
          padding: EdgeInsets.all(0.0),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            Container(
                height: 60,
                child: StreamBuilder(
                    stream: widget.productsBloc.hasMoreItems,
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      return snapshot.hasData && snapshot.data == false
                          ? Center(child: Text('No more products!'))
                          : Center(child: CircularProgressIndicator());
                    }
                    //child: Center(child: CircularProgressIndicator())
                    ))
          ]))));
    }

    return list;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => 53;
  @override
  double get maxExtent => 53;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      height: 60,
      color: Colors.orange,
      child: Column(
        children: <Widget>[
          _tabBar,
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
