import 'package:casting_call/res/CustomColors.dart';
import 'package:casting_call/res/CustomStyles.dart';
import 'package:casting_call/src/dialog/DialogAuditionAccept.dart';
import 'package:casting_call/src/dialog/DialogAuditionRefuse.dart';
import 'package:casting_call/src/net/APIConstants.dart';
import 'package:casting_call/src/net/RestClientInterface.dart';
import 'package:casting_call/src/util/StringUtils.dart';
import 'package:casting_call/src/view/audition/common/AuditionDetail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OfferedAuditionDetail extends StatefulWidget {
  final Map<String, dynamic> scoutData;

  const OfferedAuditionDetail({Key key, this.scoutData}) : super(key: key);

  @override
  _OfferedAuditionDetail createState() => _OfferedAuditionDetail();
}

class _OfferedAuditionDetail extends State<OfferedAuditionDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map<String, dynamic> _scoutData;

  @override
  void initState() {
    super.initState();

    _scoutData = widget.scoutData;
  }

  void showSnackBar(context, String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  /*
  * 수락 거절
  * */
  void requestReplyProposal(BuildContext context, String type, String msg) {
    final dio = Dio();

    // 배우프로필 이미지 수정 api 호출 시 보낼 파라미터
    Map<String, dynamic> targetData = new Map();
    targetData[APIConstants.auditionProposal_seq] =
        _scoutData[APIConstants.audition_prps_seq];
    targetData[APIConstants.state_type] = type;
    targetData[APIConstants.audition_prps_reply_contents] = msg;

    Map<String, dynamic> params = new Map();
    params[APIConstants.key] = APIConstants.UPD_APP_ANSWER;
    params[APIConstants.target] = targetData;

    // 수락 거절 api 호출
    RestClient(dio).postRequestMainControl(params).then((value) async {
      if (value == null) {
        // 에러 - 데이터 널
        showSnackBar(context, APIConstants.error_msg_server_not_response);
      } else {
        if (value[APIConstants.resultVal]) {
          try {
            // 수락 거절 성공
            setState(() {
              if (type == "수락") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuditionDetail(
                            castingSeq: _scoutData[APIConstants.casting_seq])));
              } else {
                Navigator.pop(context);
              }
            });
          } catch (e) {
            showSnackBar(context, APIConstants.error_msg_try_again);
          }
        } else {
          // 수락 거절 실패
          showSnackBar(context, APIConstants.error_msg_try_again);
        }
      }
    });
  }

  //========================================================================================================================
  // 메인 위젯
  //========================================================================================================================
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: CustomStyles.defaultTheme(),
        child: Scaffold(
            appBar: CustomStyles.defaultAppBar('받은 제안', () {
              Navigator.pop(context);
            }),
            body: Container(
                child: Column(children: [
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 30, left: 15, right: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 0,
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                      'assets/images/btn_mypage.png',
                                      fit: BoxFit.contain,
                                      width: 67,
                                      color: CustomColors.colorBgGrey),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    StringUtils.checkedString(_scoutData[
                                        APIConstants.production_name]),
                                    style: CustomStyles.normal16TextStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ))
                            ],
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            alignment: Alignment.centerLeft,
                            child: Text('제안 내용',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius:
                                    CustomStyles.circle7BorderRadius(),
                                border: Border.all(
                                    width: 1,
                                    color: CustomColors.colorFontLightGrey)),
                            child: Text(
                                StringUtils.checkedString(_scoutData[
                                    APIConstants.audition_prps_contents]),
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                            margin: EdgeInsets.only(top: 20, bottom: 10),
                            alignment: Alignment.centerLeft,
                            child: Text('제안한 오디션',
                                style: CustomStyles.normal14TextStyle())),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: CustomStyles.circle7BorderRadius(),
                              border: Border.all(
                                  width: 1,
                                  color: CustomColors.colorFontLightGrey)),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        StringUtils.checkedString(_scoutData[
                                            APIConstants.production_name]),
                                        style: CustomStyles.dark12TextStyle()),
                                    Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Text(
                                            StringUtils.checkedString(
                                                _scoutData[
                                                    APIConstants.casting_name]),
                                            style:
                                                CustomStyles.dark24TextStyle()))
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AuditionDetail(
                                                    castingSeq: _scoutData[
                                                        APIConstants
                                                            .casting_seq])),
                                      );
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text('공고보기',
                                            style: CustomStyles
                                                .normal14TextStyle())),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 0,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 55,
                              child: CustomStyles.greyBGSquareButtonStyle(
                                  '거절하기', () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      DialogAuditionRefuse(
                                    onClickedAgree: (value) {
                                      requestReplyProposal(
                                          context, "거절", value);
                                    },
                                  ),
                                );
                              })),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 55,
                              child: CustomStyles.darkGreyBGSquareButtonStyle(
                                  '수락하기', () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext _context) =>
                                      DialogAuditionAccept(
                                    onClickedAgree: (value) {
                                      requestReplyProposal(
                                          context, "수락", value);
                                    },
                                  ),
                                );
                              }))
                        ],
                      )))
            ]))));
  }
}
