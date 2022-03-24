import 'package:flutter/material.dart';

class Player extends StatefulWidget {
  final Function onTap;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardSize = MediaQuery.of(context).size.height * 0.4;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              // color: Color(0xFF57D780),
              decoration: BoxDecoration(
                  color: const Color(0xFF57D780),
                  borderRadius: BorderRadius.circular(34)),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0B1220).withOpacity(0.0),
                    const Color(0xFF0B1220).withOpacity(0.9)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height - 150,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                                height: MediaQuery.of(context).padding.top),
                            // Header
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () => widget.onTap(),
                                    iconSize: 32,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "PLAYING NOW",
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyText1!
                                              .apply(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: cardSize,
                                width: cardSize,
                                child:
                                Image.asset("assets/thumb/XVztg3oXmX4.jpg"),
                              ),
                            ),
                            // Music info
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Wurkit (Original Mix)",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.headline5!.apply(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Kyle Watson",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.headline6!.apply(
                                              color: Colors.white
                                                  .withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: Column(
                      children: <Widget>[
                        SliderTheme(
                          data: const SliderThemeData(
                            trackHeight: 3,
                            thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            inactiveColor: Colors.white.withOpacity(0.1),
                            activeColor: Colors.white,
                            value: 0.5,
                            min: 0.0,
                            max: 100.0,
                            onChanged: (double value) {},
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "00:35",
                                style: textTheme.bodyText2!.apply(
                                    color: Colors.white.withOpacity(0.7)),
                              ),
                              Text(
                                "-02:05",
                                style: textTheme.bodyText2!.apply(
                                    color: Colors.white.withOpacity(0.7)),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onPressed: () {},
                                icon: Icon(
                                  Icons.repeat,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                              IconButton(
                                iconSize: 32,
                                onPressed: () {},
                                icon: const Icon(Icons.skip_previous,
                                    color: Colors.white),
                              ),
                              MaterialButton(
                                onPressed: () {},
                                color: Colors.white,
                                textColor: const Color(0xFF0B1220),
                                child: const Icon(Icons.pause, size: 32),
                                padding: const EdgeInsets.all(16),
                                shape: const CircleBorder(),
                                elevation: 0.0,
                              ),
                              IconButton(
                                iconSize: 32,
                                onPressed: () {},
                                icon:
                                const Icon(Icons.skip_next, color: Colors.white),
                              ),
                              IconButton(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onPressed: () {},
                                icon: Icon(
                                  Icons.shuffle,
                                  color: Colors.white.withOpacity(
                                      0.4), //Theme.of(context).accentColor.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}