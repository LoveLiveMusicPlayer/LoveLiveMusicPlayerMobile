import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:get/get.dart';

import '../../routes.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.lightBlue,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage("images/drawer/logo.png")),
              const SizedBox(height: 12),
              const Text("LoveLiveMusicPlayer",
                  style: TextStyle(fontSize: 20, color: Colors.red)),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Image(
                      image: AssetImage("images/drawer/logo_lovelive.png"),
                      width: 130,
                      height: 40),
                  Image(
                      image: AssetImage("images/drawer/logo_allstars.png"),
                      width: 130,
                      height: 40)
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkResponse(
                    highlightColor: Colors.transparent,
                    radius: 0.0,
                    onTap: () async {
                      var data = await Get.toNamed(Routes.routeScan);
                      if (data != null) {
                        Get.toNamed(Routes.routeTransform, arguments: IOWebSocketChannel.connect(Uri.parse(data)));
                      }
                    },
                    child: const Image(
                        image: AssetImage("images/drawer/logo_us.png"),
                        width: 130,
                        height: 40),
                  ),
                  const Image(
                      image: AssetImage("images/drawer/logo_aqours.png"),
                      width: 130,
                      height: 40)
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Image(
                      image: AssetImage("images/drawer/logo_nijigasaki.png"),
                      width: 130,
                      height: 40),
                  Image(
                      image: AssetImage("images/drawer/logo_liella.png"),
                      width: 130,
                      height: 40)
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              Column(
                children: [],
              )
            ],
          ),
        ));
  }
}
