import 'package:casting_call/BaseWidget.dart';
import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/actor/AuditionApplyList.dart';
import 'package:casting_call/src/view/audition/actor/OfferedAuditionList.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/*
* 매니지먼트 보유배우 받은 제안 목록
* */
class AgencyActorOfferedAuditionList extends StatefulWidget {
  final String genderType;

  const AgencyActorOfferedAuditionList({Key key, this.genderType})
      : super(key: key);

  @override
  _AgencyActorOfferedAuditionList createState() =>
      _AgencyActorOfferedAuditionList();
}

class _AgencyActorOfferedAuditionList
    extends State<AgencyActorOfferedAuditionList> with BaseUtilMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 배우 리스트 관련 변수
  ScrollController _scrollController;

  int _total = 0;
  int _limit = 20;

  List<dynamic> _actorList = [];
  bool _isLoading = true;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 50.0);
    _scrollController.addListener(_scrollListener);

    super.initState();

    // 배우 목록 api 조회
    requestActorListApi(context);
  }

  // 리스트뷰 스크롤 컨트롤러 이벤트 리스너
  _scrollListener() {
    print(_scrollController.position.extentAfter);
    print(_scrollController.offset);

    if (_total == 0 || _actorList.length >= _total) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isLoading = true;

        if (_isLoading) {
          requestActorListApi(context);
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
  * 배우목록조회 api 호출
  * */
  void requestActorListApi(BuildContext context) {
    final dio = Dio();

    // 배우목록조회 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();

    Map<String, dynamic> paging = new Map();
    paging[APIConstants.offset] = _actorList.length;
    paging[APIConstants.limit] = _limit;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.SEL_ACT_LIST;
    params[APIConstants.target] = targetData;
    params[APIConstants.paging] = paging;

    // 배우목록조회 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value != null) {
        if (value[APIConstants.resultVal]) {
          try {
            // 배우목록조회 성공
            setState(() {
              var _responseList = value[APIConstants.data];
              var _pagingData = _responseList[APIConstants.paging];

              _total = _pagingData[APIConstants.total];

              if (_responseList != null && _responseList.length > 0) {
                _actorList.addAll(_responseList[APIConstants.list]);
              }

              _isLoading = false;
            });
          } catch (e) {}
        }
      }
    });
  }

  Widget listItem(Map<String, dynamic> _data) {
    return Container(
        child: Visibility(
            child: GestureDetector(
                onTap: () {
                  addView(context, OfferedAuditionList());
                },
                child: Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 5, right: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _data[APIConstants.main_img_url] != null
                                      ? ClipOval(
                                          child: Image.network(
                                              _data[APIConstants.main_img_url],
                                              fit: BoxFit.cover,
                                              width: 50.0,
                                              height: 50.0),
                                        )
                                      : ClipOval(
                                          child: Icon(
                                          Icons.account_circle,
                                          color:
                                              CustomColors.colorFontLightGrey,
                                          size: 50,
                                        )),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text(_data[APIConstants.actor_name],
                                        style: CustomStyles.dark16TextStyle()),
                                  )
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    children: [
                                      Text('받은 제안',
                                          style:
                                              CustomStyles.normal14TextStyle()),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                            StringUtils.checkedString(_data[
                                                    APIConstants
                                                        .firstAuditionTarget_cnt]
                                                .toString()),
                                            style:
                                                CustomStyles.dark16TextStyle()),
                                      )
                                    ],
                                  )))
                        ])))));
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
          appBar: CustomStyles.defaultAppBar('보유 배우 지원 현황', () {
            Navigator.pop(context);
          }),
          body: NotificationListener<ScrollNotification>(
            child: SingleChildScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                key: ObjectKey(_actorList.length > 0 ? _actorList[0] : ""),
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(
                            top: 30, left: 15, right: 15, bottom: 20),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: CustomStyles.circle7BorderRadius(),
                            border: Border.all(
                                width: 1,
                                color: CustomColors.colorFontLightGrey)),
                        child: Row(children: [
                          Flexible(
                              child: TextField(
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      hintText: "배역을 검색해보세요",
                                      hintStyle:
                                          CustomStyles.normal16TextStyle()),
                                  style: CustomStyles.dark16TextStyle())),
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Image.asset(
                                      'assets/images/btn_search.png',
                                      width: 20,
                                      fit: BoxFit.contain)))
                        ])),
                    Divider(),
                    _actorList.length > 0
                        ? Container(
                            child: ListView.separated(
                                primary: false,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, bottom: 30),
                                shrinkWrap: true,
                                itemCount: _actorList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Map<String, dynamic> _data =
                                      _actorList[index];
                                  return listItem(_data);
                                },
                                separatorBuilder: (context, index) {
                                  return Divider();
                                }))
                        : Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Text('보유배우의 지원현황이 없습니다.',
                                style: CustomStyles.normal16TextStyle()))
                  ],
                )),
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (_total != 0 || _actorList.length < _total) {
                    setState(() {
                      _isLoading = true;

                      if (_isLoading) {
                        requestActorListApi(context);
                      }
                    });
                  }
                }
              }
              return true;
            },
          )),
    );
  }
}
