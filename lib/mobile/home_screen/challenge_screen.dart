import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/challenge.dart';

class MyChallengePage extends StatefulWidget {
  final String? selectedChallengeId;
  final String? nameChallenge;
  final String? descrChallenge;
  final String? answer;
  final List<String>? questions;
  const MyChallengePage(
      {Key? key,
      this.selectedChallengeId,
      this.nameChallenge,
      this.descrChallenge,
      this.questions,
      this.answer})
      : super(key: key);

  @override
  State<MyChallengePage> createState() => _MyChallengePageState();
}

class _MyChallengePageState extends State<MyChallengePage> {
  Challenge? challenge;
  String? _token = "";
  String? _idChallenge = "";
  String? _name = "";
  String? _descr = "";
  String? _exp = "";
  String? _answer = "";
  List<String>? _questions = [];
  bool isButtonPressed = false;
  int _selectedQuestionIndex = -1;

  @override
  void initState() {
    super.initState();
    getChallengeInfo().then((_) {
      callApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  Future<void> getChallengeInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _idChallenge = widget.selectedChallengeId;
      _name = widget.nameChallenge;
      _descr = widget.descrChallenge;
      _questions = widget.questions;
      print(
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      print(_questions);
      _exp = prefs.getString('exp');
    });
  }

  Future<void> callApi() async {
    String path =
        'http://${dotenv.env['API_URL']}/challenge/get/${widget.selectedChallengeId}';
    print(path);
    var response = await Dio().get(
      path,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      ),
    );
    var challengeData = response.data;
    print('Esta es la challengeData: ${challengeData}');
    var challenge = Challenge.fromJson(challengeData);
    print(
        'Este es el valor del challenge despues de hacerle FROMJSON: ${challenge.questions}');
    setState(() {
      this.challenge = challenge;
    });
  }

  Widget _buildChild(BuildContext context) {
    if (challenge == null) {
      // Muestra un indicador de carga mientras se obtiene la información del desafío
      return const CircularProgressIndicator();
    } else {
      // Muestra la información del desafío
      return Container(
        height: 550,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: SingleChildScrollView(
          // Wrap the column with SingleChildScrollView
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.headline1?.color,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'images/marker_advanced.png',
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _name ?? '',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _descr ?? '',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1?.color),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _questions?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final question = _questions![index];
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        question,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        question,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1?.color),
                        textAlign: TextAlign.left,
                      ),
                      leading: Radio(
                        value: index,
                        groupValue: _selectedQuestionIndex,
                        onChanged: (value) {
                          setState(() {
                            _selectedQuestionIndex = value as int;
                          });
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(width: 8),
                  if (isButtonPressed)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isButtonPressed = true;
                        });
                        Navigator.pushNamed(context, '/qr_screen');
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
