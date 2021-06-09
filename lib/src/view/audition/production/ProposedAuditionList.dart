import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../KCastingAppData.dart';
import 'ProposedAuditionDetail.dart';

/*
* 제안한 오디션
* */
class ProposedAuditionList extends StatefulWidget {
  @override
  _ProposedAuditionList createState() => _ProposedAuditionList();
}

class _ProposedAuditionList extends State<ProposedAuditionList>
    with SingleTickerProviderStateMixin, BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TabController _tabController;
  int _tabIndex = 0;

  // 프로젝트 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _proposalList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    requestProjectListApi(context);

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  _scrollListener() {
    if (_total == 0 || _proposalList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("comes to bottom $_isLoading");
        _isLoading = true;

        if (_isLoading) {
          print("RUNNING LOAD MORE");

          requestProjectListApi(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /*
  * 오디션 제안 목록 조회
  * */
  void requestProjectListApi(BuildContext context) {
    final dio = Dio();

    // 오디션 제안 목록 조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.production_seq] =
        KCastingAppData().myInfo[APIConstants.seq];

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _proposalList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_PAP_LIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 오디션 제안 목록 조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, '다시 시도해 주세요.');
      } else {
        if (value[APIConstants.resultVal]) {
          // 오디션 제안 목록 조회 성공
          var _responseList = value[APIConstants.data];

          var _pagingData = _responseList[APIConstants.paging];
          setState(() {
            _total = _pagingData[APIConstants.total];

            _proposalList.addAll(_responseList[APIConstants.list]);

            _isLoading = false;
          });
        } else {
          // 오디션 제안 목록 조회 실패
          showSnackBar(context, value[APIConstants.resultMsg]);
        }
      }
    });
  }

  Widget tabItem() {
    return Container(
        child: Column(children: [
      Wrap(children: [
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _proposalList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                      onTap: () {
                        addView(
                            context,
                            ProposedAuditionDetail(
                                scoutData: _proposalList[index]));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 15),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                alignment: Alignment.topCenter,
                                                child: (_proposalList[index][
                                                            APIConstants
                                                                .main_img_url] !=
                                                        null
                                                    ? ClipOval(
                                                        child: Image.network(
                                                            _proposalList[index]
                                                                [APIConstants
                                                                    .main_img_url],
                                                            fit: BoxFit.cover,
                                                            width: 30.0,
                                                            height: 30.0),
                                                      )
                                                    : Icon(
                                                        Icons.account_circle,
                                                        color: CustomColors
                                                            .colorFontLightGrey,
                                                        size: 30,
                                                      ))),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Column(children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        StringUtils.checkedString(
                                                            _proposalList[index]
                                                                [APIConstants
                                                                    .actor_name]),
                                                        style: CustomStyles
                                                            .normal16TextStyle(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 0,
                                                      child: Text(
                                                        StringUtils.checkedString(
                                                            _proposalList[index]
                                                                [APIConstants
                                                                    .audition_prps_state_type]),
                                                        style: CustomStyles
                                                            .normal16TextStyle(),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      StringUtils.checkedString(
                                                          _proposalList[index][
                                                              APIConstants
                                                                  .audition_prps_contents]),
                                                      style: CustomStyles
                                                          .normal14TextStyle(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))
                                              ]))
                                        ])),
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    margin: EdgeInsets.only(bottom: 10),
                                    alignment: Alignment.centerLeft,
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            CustomStyles.circle7BorderRadius(),
                                        border: Border.all(
                                            width: 0.5,
                                            color: CustomColors.colorBgGrey)),
                                    child: Row(children: [
                                      Expanded(
                                        child: Text(
                                            StringUtils.checkedString(
                                                _proposalList[index][
                                                    APIConstants.project_name]),
                                            style:
                                                CustomStyles.dark12TextStyle()),
                                      ),
                                      Expanded(
                                          flex: 0,
                                          child: Text(
                                              StringUtils.checkedString(
                                                  _proposalList[index][
                                                      APIConstants
                                                          .casting_name]),
                                              style: CustomStyles
                                                  .normal14TextStyle()))
                                    ]))
                              ]))));
            },
            separatorBuilder: (context, index) {
              return Divider(
                  height: 0.1, color: CustomColors.colorFontLightGrey);
            })
      ])
    ]));
  }

  /*
  * 메인 위젯
  * */
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomStyles.defaultAppBar('제안한 오디션', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: SingleChildScrollView(
                    child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  Container(
                      margin: EdgeInsets.only(top: 30.0, bottom: 30),
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text('제안한 오디션',
                          style: CustomStyles.normal24TextStyle())),
                  Expanded(flex: 0, child: tabItem()),
                  Visibility(
                      child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 50),
                          child: Text('제안한 오디션이 없습니다.\n배우들에게 오디션 제안을 해보세요!',
                              style: CustomStyles.normal16TextStyle(),
                              textAlign: TextAlign.center)),
                      visible: _proposalList.length > 0 ? false : true),

                  /*Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        color: CustomColors.colorWhite,
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          controller: _tabController,
                          indicatorPadding: EdgeInsets.zero,
                          labelStyle: CustomStyles.bold14TextStyle(),
                          unselectedLabelStyle:
                              CustomStyles.normal14TextStyle(),
                          tabs: [
                            Tab(text: '전체'),
                            Tab(text: '수락'),
                            Tab(text: '거절'),
                            Tab(text: '대기')
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Divider(
                          height: 0.1,
                          color: CustomColors.colorFontLightGrey,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: [
                          tabItem(),
                          tabItem(),
                          tabItem(),
                          tabItem()
                        ][_tabIndex],
                      ),*/
                ]))))));
  }
}
